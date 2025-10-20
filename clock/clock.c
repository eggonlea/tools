#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>

struct timeval tv1[MAX_CLOCKS + 1];
struct timeval tv2[MAX_CLOCKS + 1];
struct timeval tv;
struct timespec tp;

void printtime(int, char *);

void printtime(int id, char *IF)
{
	switch(id) {
	case CLOCK_REALTIME:
	case CLOCK_MONOTONIC:
	case CLOCK_MONOTONIC_RAW:
	case CLOCK_PROCESS_CPUTIME_ID:
	case CLOCK_THREAD_CPUTIME_ID:
		clock_gettime(id, &tp);
		tv2[id].tv_sec = tp.tv_sec;
		tv2[id].tv_usec = tp.tv_nsec / 1000;
		break;
	case MAX_CLOCKS:
		gettimeofday (&tv2[id], NULL);
		break;
	default:
		fprintf(stderr, "ERROR: WRONG CLOCK ID: %d\n", id);
		break;
	}

	if(tv1[id].tv_sec != 0 || tv1[id].tv_usec != 0) {
		timersub(&tv2[id], &tv1[id], &tv);
		printf("%ld.%06ld%s", tv.tv_sec, tv.tv_usec, IF);
	}

	tv1[id].tv_sec = tv2[id].tv_sec;
	tv1[id].tv_usec = tv2[id].tv_usec;
}

int main (int argc, char **argv)
{
	int i = 0;
	printf("| gettimeofday | clock_gettime (CLOCK_REALTIME|MONOTONIC|RAW|PROCESS|THREAD)\n");
	while(1) {
		printf("%4d ", i++);
		printtime(MAX_CLOCKS, " ");
		printtime(CLOCK_REALTIME, " ");
		printtime(CLOCK_MONOTONIC, " ");
		printtime(CLOCK_MONOTONIC_RAW, " ");
		printtime(CLOCK_PROCESS_CPUTIME_ID, " ");
		printtime(CLOCK_THREAD_CPUTIME_ID, "\n");
		sleep(1);
	}

	return 0;
}

