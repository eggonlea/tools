#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pthread.h>

#define BUFSIZE	(512 * 1024)

#ifdef USE_FDATASYNC
#define	FSYNC	fdatasync
#define NAME	"fdatasync"
#else

#ifdef USE_DUMMYSYNC
#define	FSYNC	fdummysync
#define NAME	"fdummysync"
static int fdummysync(int fd)
{
	return fd & 0;
}

#else /* USE_FSYNC */
#define	FSYNC	fsync
#define NAME	"fsync"
#endif

#endif

static void *stress_fsync(void *arg);

static int finished = 0;
static int old[255];
static int count[255];

void *stat_report(void *arg)
{
	int i;
	int n = (int)arg;
	for(i=0; i<n; i++)
		count[i] = 0;

	char buf[BUFSIZE];
	while (!finished) {
		buf[0] = '\0';
		for (i=0; i<n; i++) {
			char id[64];
			if (count[i] <= old[i]) {
				fprintf(stderr, "Thread %d blocked\n", i);
				sprintf(id, "*%d* ", count[i]);
			} else {
				old[i] = count[i];
				sprintf(id, "%d ", count[i]);
			}

			strcat(buf, id);
		}
		fprintf(stderr, "%s\n", buf);

		sleep(1);
	}

	return NULL;
}

void *stress_fsync(void *arg)
{
	int i = 0;
	int id = (int)arg;
	char ftemp[128];
	char fname[128];
	char fold[128];
	char buf[BUFSIZE];
	sprintf(ftemp, "/data/fsync/" NAME ".tmp.%d", id);
	for (i=BUFSIZE-1; i>=0; i--)
		buf[i] = i;

	for (i=0; i<BUFSIZE; i++) {
		if (i > 0)
			unlink(fold);

		int fd = open(ftemp, O_RDWR | O_CREAT, S_IRWXU);
		if (fd < 0) {
			fprintf(stderr, "Failed to open ftemp.dat\n");
			break;
		}

		if (write(fd, buf, i+1) <= 0 || FSYNC(fd) < 0) {
			fprintf(stderr, "### Failed to write %d data to %s\n", i+1, ftemp);
			break;
		}

		close(fd);
		sprintf(fname, "/data/fsync/" NAME ".dat.%d.%d", id, i);
		strcpy(fold, fname);
		if (rename(ftemp, fname) != 0) {
			fprintf(stderr, "### Failed to rename %s to %s\n", ftemp, fname);
			break;
		}
		count[id-1] = i;
	}

	return NULL;
}

int main(int argc, char *argv[])
{
	int n = 0;
	
	if (argc > 1)
		n = atoi(argv[1]);

	if (n < 0 || n > 255)
		n = 1;

	pthread_t *threads = (pthread_t *)malloc((n+1) * sizeof(pthread_t));

	pthread_create(&(threads[0]), NULL, stat_report, (void *)n);

	int i;
	for (i=1; i<=n; i++)
		pthread_create(&(threads[i]), NULL, stress_fsync, (void *)i);

	for (i=1; i<=n; i++)
		pthread_join(threads[i], NULL);

	finished = 1;
	pthread_join(threads[0], NULL);

	return 0;
}

