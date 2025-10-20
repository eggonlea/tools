#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
#define N	(1024 * 1024)
	int i, j, n, m, x;
	char buf[N];
	FILE *fr;
	FILE *fw;

	if(argc < 2) {
		fprintf(stderr, "Usage: %s <n> (for n MB)\n", argv[0]);
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

	memset(buf, 0x5c, N);
	fr = fopen("r", "w+");
	fw = fopen("w", "w+");
	if(fw == NULL || fr == NULL) {
		fprintf(stderr, "Error to create files.\n");
		return 1;
	}

	for(i=0; i<n; i++) {
		fwrite(buf, N, 1, fr);
		fwrite(buf, N, 1, fw);
		fprintf(stderr, "Processing %d MB...\r", i+1);
	}
	fprintf(stderr, "\nDone.\n");

	fprintf(stderr, "Verification mode started.\n");
	m = 0;
	while (1) {
		fprintf(stderr, "Processing %d round (R)...\r", m);
		x = 0;
		rewind(fr);
		for(i=0; i<n; i++) {
			fread(buf, N, 1, fr);
			for(j=0; j<N; j++) {
				if (*(buf+j) != 0x5c) {
					if(x == 0)
						fprintf(stderr, "\n(R)%d:[%d][%d] == %d\n", m, i, j, *(buf+j));
					fprintf(stdout, "(R)%d:[%d][%d] == %d\n", m, i, j, *(buf+j));
				x++;
				}
			}
		}
		if (x > 0)
			fprintf(stderr, "!!! %d error found.\n", x);

		fprintf(stderr, "Processing %d round (W)...\r", m);
		x = 0;
		rewind(fw);
		for(i=0; i<n; i++)
			fwrite(buf, N, 1, fw);
		rewind(fw);
		for(i=0; i<n; i++) {
			fread(buf, N, 1, fw);
			for(j=0; j<N; j++) {
				if (*(buf+j) != 0x5c) {
					if(x == 0)
						fprintf(stderr, "\n(W)%d:[%d][%d] == %d\n", m, i, j, *(buf+j));
					fprintf(stdout, "(W)%d:[%d][%d] == %d\n", m, i, j, *(buf+j));
				x++;
				}
			}
		}
		if (x > 0)
			fprintf(stderr, "!!! %d error found.\n", x);

		for(i=10; i>0; i--) {
			fprintf(stderr, "Sleeping %d seconds...\r", i);
			sleep(1);
		}
		m++;
	}

	return 0;
}

