#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define N	3
#define M	100

int main()
{
	int fd[N];
	char fname[N][10];

	fprintf(stdout, "start\n");

	int i, j;
	for(i=0; i<N; i++) {
		sprintf(fname[i], "%d.out", i);
		//fd[i] = dup2(creat(fname[i], S_IRWXU), i+3);
		fd[i] = i+3;
		write(fd[i], &(fd[i]), sizeof(fd[i]));
	}

	for(j='0'; j<M; j++) {
		i = j % N;
		write(fd[i], &j, sizeof(j));
	}

	for(i=0; i<N; i++) {
		close(fd[i]);
	}

	fprintf(stderr, "stop\n");

	return 0;
}
