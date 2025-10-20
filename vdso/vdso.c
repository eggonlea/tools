#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <time.h>

static int running;

void event_handler (int);
void event_handler (int signum __attribute__ ((unused)))
{
	running = 0;
}

/* gettimeofday */
unsigned long bench_gettimeofday(void);
unsigned long bench_gettimeofday(void)
{
	unsigned long i = 0;
	struct timeval cur;
	running = 1;
	do{
		i++;
		gettimeofday (&cur, NULL);
	}while(running);
	return i;
}

unsigned long bench_SYS_gettimeofday(void);
unsigned long bench_SYS_gettimeofday(void)
{
	unsigned long i = 0;
	struct timeval cur;
	running = 1;
	do{
		i++;
		syscall(SYS_gettimeofday, &cur, NULL);
	}while(running);
	return i;
}

/* clock_gettime */
unsigned long bench_clock_gettime(clockid_t);
unsigned long bench_clock_gettime(clockid_t clk_id)
{
	unsigned long i = 0;
	struct timespec cur;
	running = 1;
	do{
		i++;
		clock_gettime(clk_id, &cur);
	}while(running);
	return i;
}

unsigned long bench_SYS_clock_gettime(clockid_t);
unsigned long bench_SYS_clock_gettime(clockid_t clk_id)
{
	unsigned long i = 0;
	struct timespec cur;
	running = 1;
	do{
		i++;
		syscall(SYS_clock_gettime, clk_id, &cur);
	}while(running);
	return i;
}

/* main */
void set_timer(int);
void set_timer(int n)
{
	struct sigaction sa;
	struct itimerval timer;
	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = &event_handler;
	sigaction(SIGALRM, &sa, NULL);
	timer.it_value.tv_sec = n;
	timer.it_value.tv_usec = 0;
	timer.it_interval.tv_sec = 0;
	timer.it_interval.tv_usec = 0;
	setitimer(ITIMER_REAL, &timer, NULL);
}

int main (int argc, char **argv)
{
	int n = 0;

	switch(argc) {
	case 2:
		n = atoi(argv[1]);
	case 1:
		if(n <= 0 || n >= 60)
			n = 1;
		break;
	default:
		fprintf(stderr, "Usage: %s [seconds]\n", argv[0]);
		exit(1);
	}

#define BENCH1(x) \
do { \
	set_timer(n); \
	printf("%20s(%25s): %'12lu in %d seconds\n", #x, " ", bench_##x(), n); \
} while (0)

#define BENCH2(x, y) \
do { \
	set_timer(n); \
	printf("%20s(%25s): %'12lu in %d seconds\n", #x, #y, bench_##x(y), n); \
} while (0)

	BENCH1(gettimeofday);
	BENCH1(SYS_gettimeofday);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_REALTIME);
	BENCH2(SYS_clock_gettime, CLOCK_REALTIME);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_REALTIME_COARSE);
	BENCH2(SYS_clock_gettime, CLOCK_REALTIME_COARSE);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_MONOTONIC);
	BENCH2(SYS_clock_gettime, CLOCK_MONOTONIC);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_MONOTONIC_COARSE);
	BENCH2(SYS_clock_gettime, CLOCK_MONOTONIC_COARSE);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_MONOTONIC_RAW);
	BENCH2(SYS_clock_gettime, CLOCK_MONOTONIC_RAW);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_PROCESS_CPUTIME_ID);
	BENCH2(SYS_clock_gettime, CLOCK_PROCESS_CPUTIME_ID);
	printf("\n");

	BENCH2(clock_gettime, CLOCK_THREAD_CPUTIME_ID);
	BENCH2(SYS_clock_gettime, CLOCK_THREAD_CPUTIME_ID);
	printf("\n");

	return 0;
}

