#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	int i;
	if(argc < 2) {
		fprintf(stderr, "Usage: int <n> [filename]\n");
		return -1;
	}

	i = atoi(argv[1]);
	int fd = 1;
	if(argc == 3) {
		fprintf(stderr, "Open [%s]\n", argv[2]);
		fd = open(argv[2], O_WRONLY);
		if(fd < 0) {
			fprintf(stderr, "Failed to open [%s]\n", argv[2]);
			exit(-1);
		}
	}
	fprintf(stderr, "Write [%d]\n", i);
	write(fd, &i, sizeof(i));
	sleep(3);
	if(fd > 1) {
		fprintf(stderr, "Close [%d]\n", fd);
		close(fd);
	}

	return 0;
}

