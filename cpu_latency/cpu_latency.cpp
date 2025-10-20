#ifndef	_GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <dirent.h>
#include <poll.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/prctl.h>

#define	ATRACE_TAG	ATRACE_TAG_AUDIO

#include <utils/Trace.h>

extern int clock_nanosleep(clockid_t clock_id, int flags,
                           const struct timespec *request,
                           struct timespec *remain);

#define SEC_TO_NSEC	(1000000000)
#define MSEC_TO_NSEC	(1000000)
#define USEC_TO_NSEC	(1000)

#define NUM_CPUS	(4)
#define SCHED_PRIORITY	(2)
#define BUFFER_SIZE	(4096 / (int)sizeof(struct timespec))
#define	BUFFER_TIMEOUT	(SEC_TO_NSEC)

struct testcase
{
	long cycles;		// scheduled cycles
	long max_latency;	// max_latency latency in ns
	long interval;		// scheduing latency in ns
	long threshold;		// latency threshold in ns
	long thres_count;	// cycles hitting threshold
	unsigned int cpu;	// CPU affinity mask
	int mode;		// 0: nanosleep(relative)
				// 1: clock_nanosleep(relative)
				// 2: clock_nanosleep(absolute)

	int id;			// 0 <= id <= tc_count
	pid_t pid;		// pid of child testcase, or 0
	struct testcase *next;	// test case linkedlist
};

static char name[16];		// process name "cpu_latency<n>"

static int finish;		// finish the current process
static long timeout;		// global testcase timeout

static int ts_count;		// scheduling timestamps
static struct timespec tss[BUFFER_SIZE];

static int tc_count;		// global testcase number
static struct testcase *tc_head;// the head of testcases linkedlist
static struct testcase *tc_curr;// the tail of testcases linkedlist
static struct testcase **tcs;	// an array copy of testcases
static struct pollfd *fds;	// pipes from children to parent

static void new_testcase(void);
static void check_testcase(void);
static long strtons(const char *optarg);
static void set_interval(long interval);
static void set_threshold(long threshold);
static void set_cpu(unsigned int cpu);
static void set_mode(int mode);
static void signal_handler(int sig);
static void init_signal(void);
static void reset_name(void);
static void init_sched(void);
static void init_affinity(void);
static void close_fds(int pipefd);
static void latency_daemon(void);
static void process_timestamps(int id);
static void usage(void);

void new_testcase(void)
{
	struct testcase * tc = (struct testcase *)malloc(sizeof(struct testcase));
	if(tc == NULL) {
		fprintf(stderr, "No enough memory\n");
		exit(1);
	}
	memset(tc, 0, sizeof(struct testcase));

	if(tc_head == NULL) {
		tc_head = tc_curr = tc;
	} else {
		tc_curr->next = tc;
		tc_curr = tc;
	}
	printf("Create testcase #%d\n", tc_count);
	tc_curr->id = tc_count++;
}

void check_testcase(void)
{
	if(tc_head == NULL)
		new_testcase();
}

long strtons(const char *optarg)
{
	char *endptr;
	long ns = strtol(optarg, &endptr, 10);
	if(endptr != NULL) {
		switch(*endptr) {
		case 's':
		case 'S':
			ns *= SEC_TO_NSEC;
			break;
		case 'u':
		case 'U':
			ns *= USEC_TO_NSEC;
			break;
		case 'm':
		case 'M':
			ns *= MSEC_TO_NSEC;
			break;
		default:
			break;
		}
	}
	return ns;
}

void set_interval(long interval)
{
	check_testcase();

	if(interval < 0)
		interval = 0;
	if(interval >= SEC_TO_NSEC)
		interval = SEC_TO_NSEC - 1;

	tc_curr->interval = interval;
	printf("\tInterval : %ld ns\n", interval);
}

void set_threshold(long threshold)
{
	check_testcase();

	if(threshold < 0)
		threshold = 0;

	tc_curr->threshold = threshold;
	printf("\tThreshold: %ld ns\n", threshold);
}

void set_cpu(unsigned int cpu)
{
	check_testcase();

	if(cpu >= (1 << NUM_CPUS))
		cpu = (1 << NUM_CPUS) - 1;

	tc_curr->cpu = cpu;
	printf("\tCPU map  : %1x\n", cpu);
}

void set_mode(int mode)
{
	check_testcase();

	if(mode < 0 || mode > 2)
		mode = 0;

	tc_curr->mode = mode;
	printf("\tnanosleep: %d\n", mode);
}

void signal_handler(int sig)
{
	if(sig == SIGINT || sig == SIGALRM || sig == SIGPIPE)
		finish = 1;
}

void init_signal(void)
{
#if defined(__LP64__)
	struct sigaction sa = {0};
#else
	struct sigaction sa;
	memset(&sa, 0, sizeof(struct sigaction));
#endif
	sa.sa_handler = signal_handler;
	sigaction(SIGINT, &sa, NULL);
	sigaction(SIGALRM, &sa, NULL);
	sigaction(SIGPIPE, &sa, NULL);

	if(timeout > 0) {
		struct itimerval val;
		val.it_interval.tv_sec = 0;
		val.it_interval.tv_usec = 0;
		val.it_value.tv_sec = timeout;
		val.it_value.tv_usec = 0;
		setitimer(ITIMER_REAL, &val, NULL);
	}
}

void reset_name(void)
{
	snprintf(name, 16, "cpu_latency%d", tc_curr->id);
	prctl(PR_SET_NAME, (unsigned long) name, 0, 0, 0);
}

void init_sched(void)
{
	struct sched_param param = {0};
	param.sched_priority = SCHED_PRIORITY;

	/* set realtime scheduling for daemon */
	sched_setscheduler(0, SCHED_FIFO, &param);
}

void init_affinity(void)
{
	/* check if the sesired scheduler is actually set */
	printf("[%d] SCHED_FIFO(%d) set? %d\n", tc_curr->id, SCHED_FIFO, sched_getscheduler(0));

	if(tc_curr->cpu > 0) {
		cpu_set_t mask;
		CPU_ZERO(&mask);
		int i;
		for(i=0; i<NUM_CPUS; ++i)
			if(tc_curr->cpu & (1 << i))
				CPU_SET(i, &mask);
		/* set process affinity to core 0 */
		sched_setaffinity(0, sizeof(mask), &mask);
		/* check if the desired CPU is actually set */
		sched_getaffinity(0, sizeof(mask), &mask);
		printf("[%d] CPU#%1x afinity set? ", tc_curr->id, tc_curr->cpu);
		for(i=0; i<NUM_CPUS; ++i)
			if(CPU_ISSET(i, &mask))
				printf("%1x", i);
		printf("\n");
	}
}

/*
 * The daemon process needs to close all of
 * its inherited fds in order for its parent to die
 * successfully when running in kernel_submit.
 */
void close_fds(int pipefd)
{
	DIR *dp;
	struct dirent *ep;

	dp = opendir("/proc/self/fd/");

	if(dp != NULL) {
		while((ep = readdir(dp))) {
			int fd = atoi(ep->d_name);
			if(fd != pipefd)
				close(fd);
		}
		closedir(dp);
	}
}

void latency_daemon(void)
{
	int pipes[2];
	if(pipe2(pipes, O_NONBLOCK)) {
		fprintf(stderr, "Failed to create pipe.\n");
		exit(1);
	}

	printf("PAGESIZE: %d %d\n", fcntl(pipes[0], F_GETPIPE_SZ), fcntl(pipes[1], F_GETPIPE_SZ));

	/* spawn daemon process */
	pid_t pid = fork();

	/* parent */
	if(pid) {
		close(pipes[1]);
		tc_curr->pid = pid;
		fds[tc_curr->id].fd = pipes[0];
		fds[tc_curr->id].events = POLLIN | POLLHUP;
		fds[tc_curr->id].revents = 0;
		tcs[tc_curr->id] = tc_curr;
		printf("\tParent leaving #%d [%d]...\n", tc_curr->id, pid);
		return;
	}

	/* child */
	close(pipes[0]);
	setsid();
	reset_name();
	init_sched();
	init_affinity();
	close_fds(pipes[1]);

	int mode = tc_curr->mode;
	int interval = tc_curr->interval;

	struct timespec req;
	clock_gettime(CLOCK_MONOTONIC, &req);

	struct timespec ts;
	ts.tv_sec = 0;
	ts.tv_nsec = interval;
	ts_count = 0;

	long elapsed = 0;
	long delta = 0;
	long old_delta = -1;

	struct timespec last = {0};
	/* loop until being killed */
	while(!finish) {
		if(mode == 2) {
			req.tv_nsec += interval;
			if(req.tv_nsec >= SEC_TO_NSEC) {
				++(req.tv_sec);
				req.tv_nsec -= SEC_TO_NSEC;
			}
			clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &req, NULL);
		} else if(mode == 1) {
			clock_nanosleep(CLOCK_MONOTONIC, 0, &ts, NULL);
		} else {
			nanosleep(&ts, NULL);
		}

		elapsed += interval;
		struct timespec curr;
		clock_gettime(CLOCK_MONOTONIC, &curr);

#ifdef ENABLE_ATRACE_INFO
		/* check if wakeup from sleep is delayed */
		if(ATRACE_ENABLED() && last.tv_sec != 0) {
			delta = curr.tv_nsec - last.tv_nsec;
			delta += (curr.tv_sec - last.tv_sec) * SEC_TO_NSEC;
			delta -= interval;
			delta /= MSEC_TO_NSEC;
			if(delta != old_delta) {
				ATRACE_INT(name, delta);
				old_delta = delta;
			}
		}
#endif
		last = curr;

		/* send buffered data to main process */
		tss[ts_count] = curr;
		++ts_count;
		if(ts_count >= BUFFER_SIZE || elapsed >= BUFFER_TIMEOUT) {
			write(pipes[1], tss, ts_count * sizeof(struct timespec));
			ts_count = 0;
			elapsed = 0;
#ifdef ENABLE_ATRACE_INFO
			atrace_update_tags();	/* FIXME: improve with a callback */
#endif
		}
	}

	if(ts_count > 0) {
		write(pipes[1], tss, tc_count * sizeof(struct timespec));
	}
	close(pipes[1]);
	exit(0);
}

void process_timestamps(int id)
{
	struct testcase *tc_curr = tcs[id];
	long cycles = tc_curr->cycles;
	long interval = tc_curr->interval;
	long threshold = tc_curr->threshold;
	long thres_count = tc_curr->thres_count;
	long max_latency = tc_curr->max_latency;

	ssize_t ret = read(fds[id].fd, tss, BUFFER_SIZE * sizeof(struct timespec));
	if(ret <= 0)
		return;

	ts_count = (int)ret / sizeof(struct timespec);

	int i;
	for(i=1; i<ts_count; ++i) {
		long delta = tss[i].tv_nsec - tss[i-1].tv_nsec;
		delta += (tss[i].tv_sec - tss[i-1].tv_sec) * SEC_TO_NSEC;
		++cycles;
		if(delta > max_latency) {
			max_latency = delta;
			printf("[%d] new max_latency latency: %.6f ms at %ld cycles\n", id,
				delta / (1000000.0f), cycles);
		}

		if(threshold > 0 && delta - interval >= threshold) {
			printf("[%d] reach threshold: %.6f ms for %ld / %ld times\n", id,
				delta / (1000000.0f), ++thres_count, cycles);
		}
	}

	tc_curr->cycles = cycles;
	tc_curr->thres_count = thres_count;
	tc_curr->max_latency = max_latency;
}

void usage(void)
{
	printf("CPU latency test\n");
	printf("\tThis spawns a background process to begin measuring latency.\n");
	printf("\tPrints worst case latencies as they occur to stdout.\n");
	printf("\tUsage: cpu_latency [-t <s>] <[-s] [-i <ns>] [-n <ns>] [-c <cpu>]> [<-s> ...] ...\n\n");
	printf("\tExample 1: cpu_latency -i 1ms -n 500us -c 1      # 1ms±0.5ms@CPU0\n");
	printf("\tExample 2: cpu_latency -i 1u -c 1 -s -i 2us -c 2 # 1us@CPU0 + 2us@CPU1\n");
	printf("\tExample 3: cpu_latency -s -i 1MS -s -i 2M        # 1ms + 2ms\n");
	printf("\tExample 4: cpu_latency -t -i 10666666 -c 0xe     # 10.666666ms@CPU123\n\n");
	printf("-t <s>: timeout\n");
	printf("\tstop the test after <s> seconds. <s> should be a positive number.\n");
	printf("-s    : start a new test\n");
	printf("\tMultiple tests can be added, followed by extra parameters as below.\n");
	printf("-i <n>: interval (nanosecond)\n");
	printf("\tTarget scheduling interval <n>.\n");
	printf("\t<n> can be a non-negative number, followed by [s|S|ms|MS|us|US|ns|NS].\n");
	printf("-n <n>: threshold (nanosecond)\n");
	printf("\tAlso prints cases reaching the threshold <n>.\n");
	printf("\t<n> can be a non-negative number, followed by [s|S|ms|MS|us|US|ns|NS].\n");
	printf("-c <c>: set CPU affinity\n");
	printf("\tTry to run at specified CPU(s) with mask <c> other than default.\n");
	printf("\t<c> can be an oct, dec or hex number. Default is 0 - same effect as 0xf.\n");
	printf("-m <m>: choose nanosleep mode\n");
	printf("\tm=0|1|2 means nanosleep(relative)|clock_nanosleep(relative|absolute).\n");
	printf("-h    : print this message\n\n");
}

int main(int argc, char *argv[])
{
printf("+++ %s(%x & %llx = %llx / %llx / %llx) ###\n", __func__,
	ATRACE_TAG,
	atrace_get_enabled_tags(),
	ATRACE_ENABLED(),
	atrace_is_tag_enabled(ATRACE_TAG),
	atrace_get_enabled_tags() & ATRACE_TAG);

	atrace_update_tags();

printf("=== %s(%x & %llx = %llx / %llx / %llx) ###\n", __func__,
	ATRACE_TAG,
	atrace_get_enabled_tags(),
	ATRACE_ENABLED(),
	atrace_is_tag_enabled(ATRACE_TAG),
	atrace_get_enabled_tags() & ATRACE_TAG);

ATRACE_BEGIN("### WRITE ###");
ATRACE_END();
	exit(0);

	if(argc == 1) {
		usage();
		exit(1);
	}

	int c;
	while((c = getopt(argc, argv, "si:n:c:t:m:h")) != -1) {
		switch (c) {
		case 's':
			new_testcase();
			break;
		case 'i':
			set_interval(strtons(optarg));
			break;
		case 'n':
			set_threshold(strtons(optarg));
			break;
		case 'c':
			set_cpu((unsigned int)strtol(optarg, NULL, 0));
			break;
		case 't':
			timeout = strtol(optarg, NULL, 0);
			printf("Timeout: %ld s\n", timeout);
			break;
		case 'm':
			set_mode((int)strtol(optarg, NULL, 0));
			break;
		case 'h':
			usage();
			exit(0);
			break;
		default:
			usage();
			exit(2);
			break;
		}
	}

	tcs = (struct testcase **)malloc(tc_count * sizeof(struct testcase *));
	if(tcs == NULL) {
		fprintf(stderr, "Failed to malloc testcases.\n");
		exit(1);
	}

	fds = (struct pollfd *)malloc(tc_count * sizeof(struct pollfd));
	if(fds == NULL) {
		fprintf(stderr, "Failed to malloc fds.\n");
		exit(1);
	}

	init_signal();
	init_sched();

	for(tc_curr = tc_head; tc_curr != NULL; tc_curr = tc_curr->next) {
		printf("\tTestcase #%d creating...\n", tc_curr->id);
		latency_daemon();
		printf("\tTestcase #%d created: [%d]\n", tc_curr->id, tc_curr->pid);
	}

#ifdef ENABLE_ATRACE_INFO
	printf("ATRACE enabled\n");
#endif

	printf("Enter while loop\n");
	while(!finish) {
#ifdef ENABLE_ATRACE_INFO
		atrace_update_tags();	/* FIXME: optimize this with a callback */
#endif
		int ret = poll(fds, tc_count, -1);
		if(ret < 0) {
			fprintf(stderr, "Poll'ing error: %d\n", ret);
			finish = 1;
		} else if(ret > 0) {
			int i;
			for(i=0; i<tc_count; ++i) {
				if(fds[i].revents & POLLHUP) {
					int pid = tcs[i]->pid;
					printf("Detect pipe closed from testcase #%d\n", i);
					finish = 1;
				}
				if(fds[i].revents & POLLIN) {
					fds[i].revents = 0;
					process_timestamps(i);
				}
			}
		}
	}
	printf("While loop ended\n");

	for(tc_curr = tc_head; tc_curr != NULL; tc_curr = tc_curr->next) {
		int pid = tc_curr->pid;
		printf("killing [%d] %d...\n", tc_curr->id, pid);
		kill(pid, SIGINT);
		printf("\twaitpid(%d) returns %d\n", pid, waitpid(pid, NULL, 0));
		process_timestamps(tc_curr->id);
	}

	for(tc_curr = tc_head; tc_curr != NULL; tc_curr = tc_curr->next) {
		printf("[%d] max_latency: %.6f ms, reach threshold: for %ld / %ld times\n", tc_curr->id,
			tc_curr->max_latency / (1000000.0f), tc_curr->thres_count, tc_curr->cycles);
	}

	int i;
	for(i=0; i<tc_count; ++i) {
		close(fds[i].fd);
		free(tcs[i]);
	}
	free(fds);
	free(tcs);

	return 0;
}
