#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>

#ifdef USE_FDATASYNC
#define	FSYNC	fdatasync
#else

#ifdef USE_DUMMYSYNC
#define	FSYNC	fdummysync

static int fdummysync(int fd)
{
	return fd & 0;
}

#else /* USE_FSYNC */
#define	FSYNC	fsync
#endif

#endif

static void *stress_fsync(void *arg);

void *stress_fsync(void *arg)
{
	int id = (int)arg;
	char fname[128];
	sprintf(fname, "/data/fsync/fsync.dat.%d", id);
	int fd = open(fname, O_RDWR | O_CREAT, S_IRWXU);
	if (fd < 0) {
		fprintf(stderr, "Failed to open fsync.dat\n");
		return NULL;
	}

	int buf = 0;
	if (lseek(fd, - sizeof(int), SEEK_END) >= 0) {
		if (read(fd, &buf, sizeof(int)) > 0) {
			fprintf(stderr, "#%d read buf = %d\n", id, buf);
		}
	}

	lseek(fd, 0, SEEK_END);
	while (1) {
		++buf;
		if (write(fd, &buf, sizeof(int)) > 0 && FSYNC(fd) == 0) {
			fprintf(stderr, "#%d write buf = %d\n", id, buf);
		} else {
			fprintf(stderr, "### Failed to write new data to %s\n", fname);
			break;
		}
	}

	close(fd);

	return NULL;
}

int main(int argc, char *argv[])
{
	int n = 0;
	
	if (argc > 1)
		n = atoi(argv[1]);

	if (n < 0 || n > 255)
		n = 1;

	pthread_t *threads = (pthread_t *)malloc(n * sizeof(pthread_t));

	int i;
	for (i=0; i<n; i++)
		pthread_create(&(threads[i]), NULL, stress_fsync, (void *)i);

	for (i=0; i<n; i++)
		pthread_join(threads[i], NULL);

	return 0;
}

