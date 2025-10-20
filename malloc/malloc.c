#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int fd;

unsigned long v2p(unsigned long va)
{
	off_t offset;
	unsigned long long pa;
	unsigned long long page;
	offset = (va / 4096) * sizeof(unsigned long long);
	lseek(fd, offset, SEEK_SET);
	read(fd, &page, sizeof(unsigned long long));
	return ((page & 0x7fffffffffffff) * 4096) + (va % 4096);
}

int main(int argc, char *argv[])
{
	unsigned int i, n, m, x;
	char *c;

	if(argc < 2) {
		fprintf(stderr, "Usage: %s <n> [-v|-V] (for n MB)\n", argv[0]);
		fprintf(stderr, "\t-v for virtual address mode)\n");
		fprintf(stderr, "\t-V for Verification mode)\n");
		return 1;
	}

	n = atoi(argv[1]);
	if (n <= 0) {
		n = 1;
		fprintf(stderr, "Reset n to minimum value: %d\n", n);
	} else if (n > 1024 * 4) {
		n = 1024 * 4;
		fprintf(stderr, "Reset n to maximum value: %d\n", n);
	}

	c = malloc(n*1024*1024);
	if(c == NULL) {
		fprintf(stderr, "Failed to allocate %d MB memory\n", n);
		return 1;
	}

	if (argc == 3 && !strcmp(argv[2], "-v")) {
		fprintf(stderr, "virtual mode detected.\n");
		i = 0;
		while (c != NULL) {
			fprintf(stdout, "[%d]0x%08x\n", n + i, c);
			fprintf(stderr, "Allocated %d (%d + %d) MB\r", n + i, n, i);
			c = malloc(1024 * 1024);
			i++;
		}
		fprintf(stderr, "\nExit.\n");
		return 0;
	}

	for(i=0; i<n; i++) {
		memset(c + i * 1024 * 1024, 0x5c, 1024 * 1024);
		fprintf(stderr, "Processing %d MB...\r", i+1);
	}
	fprintf(stderr, "\nDone.\n");

	if (argc == 3 && !strcmp(argv[2], "-V")) {
		fprintf(stderr, "Verification mode detected.\n");
		fd = open("/proc/self/pagemap", O_RDONLY);
		m = 0;
		while (1) {
			x = 0;
			fprintf(stderr, "Processing %d round...\r", m);
			for(i=0; i<n*1024*1024; i++) {
				if (*(c+i) != 0x5c) {
					if(((unsigned long)c+i) % 4096 == 0) {
						fprintf(stderr, "\n%d:[%d] v:0x%08x p:0x%08x == %d\n", m, i, c+i, v2p(c+i), *(c+i));
					}
					fprintf(stdout, "%d:[%d]0x%08x == %d\n", m, i, c+i, *(c+i));
					*(c+i) = 0x5c;
					x++;
				}
			}
			if (x > 0)
				fprintf(stderr, "!!! %d error found.\n", x);
			for(i=10; i>0; i--) {
				fprintf(stderr, "Sleep... %d seconds...\r", i);
				sleep(1);
			}
			m++;
		}
	}

	return 0;
}

