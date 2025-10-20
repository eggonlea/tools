#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <pthread.h>

#define KB 1024
#define MB (KB*KB)
#define GB (MB*KB)

#define	DEFAULT_SIZE	MB
#define	DEFAULT_LOOP	10
#define	DEFAULT_TIMEOUT	9999000
#define	DEFAULT_THREADS	4
#define	DEFAULT_VERBOSE	0
#define	DURATION_SIZE	(10 * MB)
#define DURATION_THRES	8192
#define	DURATION_END	(-1)

static int g_size;
static int g_loop;
static int g_timeout;
static int g_threads;
static int g_verbose;
static long **g_durations;

long get_us(void);
void * vmalloc(void *);

long get_us() {
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC_RAW, &ts);
	return ts.tv_sec * 1000000 + ts.tv_nsec / 1000;
}

void * vmalloc(void *arg) {
	long id = (long)arg;
	size_t size = g_size;
	int loop = g_loop;
	int timeout = g_timeout;
	int verbose = g_verbose;
	long *durations = NULL;
	long count = 0;
	long score = 0;

	if(verbose != 0)
		durations = g_durations[id];

	long begin = get_us();
	long current = begin;
	long last;
	do {
		last = current;
		int j;
		void *addr;
		for(j=loop; j>0; j--) {
			addr = malloc(size);
			if(verbose != 0 && count < DURATION_SIZE)
				durations[count++] = (long)addr;
			free(addr);
		}
		current = get_us();
		if(verbose != 0 && count < DURATION_SIZE)
			durations[count++] = current - last;
		score++;
	} while (current - begin < timeout);

	return (void *)score;
}

int main(int argc, char *argv[]) {
	if(argc == 1) {
		g_size = DEFAULT_SIZE;
		g_loop = DEFAULT_LOOP;
		g_timeout = DEFAULT_TIMEOUT;
		g_threads = DEFAULT_THREADS;
		g_verbose = DEFAULT_VERBOSE;
	} else if (argc == 6) {
		g_size = atoi(argv[1]);
		g_loop = atoi(argv[2]);
		g_timeout = atoi(argv[3]);
		g_threads = atoi(argv[4]);
		g_verbose = atoi(argv[5]);
	} else {
		fprintf(stderr, "Usage: %s [size loop timeout threads verbose]\n", argv[0]);
		return 1;
	}

	fprintf(stderr, "size=%d, loop=%d, timeout=%d, threads=%d, verbose=%d\n",
		       g_size,  g_loop,  g_timeout,  g_threads,  g_verbose);

	long begin = get_us();

	long *scores = (long *)malloc(sizeof(long) * g_threads);
	if(scores == NULL) {
		fprintf(stderr, "Error: no enough memory for scores\n");
		return 1;
	}

	pthread_t *threads = (pthread_t *)malloc(sizeof(pthread_t) * g_threads);
	if(threads == NULL) {
		fprintf(stderr, "Error: no enough memory for threads\n");
		return 1;
	}

	long i;
	if(g_verbose != 0) {
		g_durations = (long **)malloc(sizeof(long *) * g_threads);
		if(g_durations == NULL) {
			fprintf(stderr, "Error: no enough memory for verbose\n");
			return 1;
		}
		for(i=0; i<g_threads; i++) {
			g_durations[i] = (long *)malloc(sizeof(long) * DURATION_SIZE);
			if(g_durations[i] == NULL) {
				fprintf(stderr, "Error: no enough memory for verboses\n");
				return 1;
			}
			memset(g_durations[i], DURATION_END, sizeof(long) * DURATION_SIZE);
		}
	}

	for(i=0; i<g_threads; i++) {
		pthread_create(&(threads[i]), NULL, vmalloc, (void *)i);
	}

	long score = 0;
	for(i=0; i<g_threads; i++) {
		pthread_join(threads[i], (void **)(&(scores[i])));
		score += scores[i];
		fprintf(stderr, "[%ld]: %ld K\n", i, scores[i] * g_loop / 1000);
	}

	fprintf(stderr, "score=%ld K in %ld ms\n", score * g_loop / 1000, (get_us() - begin) / 1000);

	if(g_verbose != 0) {
		for(i=0; i<g_threads; i++) {
			long last = 0;
			long j;
			for(j=0; j<DURATION_SIZE; j++) {
				if(g_durations[i][j] == DURATION_END)
					break;
				else if(g_durations[i][j] < DURATION_THRES)
					printf("[%ld]: \t %ld us\n", i, g_durations[i][j]);
				else if(g_durations[i][j] == last)
					printf("[%ld]: %p\n", i, (void *)(g_durations[i][j]));
				else {
					last = g_durations[i][j];
					printf("[%ld]: %p *\n", i, (void *)last);
				}
			}
			free(g_durations[i]);
		}
		free(g_durations);
	}

	free(threads);
	free(scores);

	return 0;
}

