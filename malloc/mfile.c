#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define KB 1024
#define MB (KB*KB)
#define GB (MB*KB)

char touch(char *);

char touch(char *mem) {
	return *mem + 1;
}

int main(int argc, char *argv[]) {
	int i;
	int fd;
	int prot;
	int flag;
	char *mem;
	size_t size;

	if(argc == 2) {
		fd = -1;
		size = atoi(argv[1]) * MB;
		prot = PROT_READ | PROT_WRITE;
		flag = MAP_ANONYMOUS | MAP_PRIVATE;
	} else if(argc == 3) {
		fd = open(argv[1], O_RDONLY);
		size = atoi(argv[2]) * MB;
		prot = PROT_READ;
		flag = MAP_SHARED;
	} else {
		fprintf(stderr, "Usage: %s [file] <size MB>\n", argv[0]);
		return 1;
	}

	mem = mmap(NULL , size, prot, flag, fd, 0);
	if(mem == MAP_FAILED) {
		fprintf(stderr, "Failed to mmap...\n");
		return 2;
	}

	printf("Touching memory...\n");
	for(i=0; i<(int)size; i++) {
		if(fd == -1)
			*mem++ = 0;
		else
			touch(mem++);
	}

	printf("Endless loop...\n");
	while(1)
		sleep(1);

	return 0;
}
