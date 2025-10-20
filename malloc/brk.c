#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
	unsigned int i, n, m;
	char *c;

	if(argc < 3) {
		fprintf(stderr, "Usage: %s <size> <count>\n", argv[0]);
		return 1;
	}

	n = atoi(argv[1]);
	if (n <= 0) {
		n = 1;
		fprintf(stderr, "Reset n to minimum value: %d\n", n);
	} else if (n > 1024 * 1024 * 4) {
		n = 1024 * 1024 * 4;
		fprintf(stderr, "Reset n to maximum value: %d\n", n);
	}

	m = atoi(argv[2]);
	if (m <= 0) {
		m = 1;
		fprintf(stderr, "Reset m to minimum value: %d\n", m);
	} else if (m > 1024 * 1024 * 4) {
		m = 1024 * 1024 * 4;
		fprintf(stderr, "Reset m to maximum value: %d\n", m);
	}

	for(i = 0; i < m; i++)
		c = malloc(n);

	return 0;
}

