#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#define	TEST_FNAME	"test.tmp"

int mystat(char *);

int main(int argc, char *argv[])
{
	if(argc != 4) {
		fprintf(stderr, "Usage: %s <start_size> <inc_size> <iteration>\n", argv[0]);
		exit(1);
	}

	int size = atoi(argv[1]);
	int inc = atoi(argv[2]);
	int count = atoi(argv[3]);
	if(size <= 0 || inc <= 0 || count <= 0) {
		fprintf(stderr, "Invalid input\n");
		exit(1);
	}
	void *buf = malloc(size + inc * count);
	if(buf == NULL) {
		fprintf(stderr, "Malloc failed\n");
		exit(1);
	}

	int i;
	FILE *fp = fopen(TEST_FNAME, "w");
	for(i=0; i<count; i++) {
		int cur = size + inc * i;
		int ret = fwrite(buf, cur, 1, fp);
		printf("fwrite(%d) returns %d/%d\n", cur, ret * cur, ret);
	}
	fclose(fp);

	mystat(TEST_FNAME);

	fp = fopen(TEST_FNAME, "r");
	for(i=0; i<count; i++) {
		int cur = size + inc * i;
		int ret = fread(buf, cur, 1, fp);
		printf("fread(%d) returns %d/%d\n", cur, ret * cur, ret);
	}
	fclose(fp);

	unlink(TEST_FNAME);
	free(buf);

	return 0;
}

int mystat(char *fname)
{
    struct stat sb;

    if (stat(fname, &sb) == -1) {
        perror("stat");
        return 1;
    }

    printf("File type:                ");

    switch (sb.st_mode & S_IFMT) {
    case S_IFBLK:  printf("block device\n");            break;
    case S_IFCHR:  printf("character device\n");        break;
    case S_IFDIR:  printf("directory\n");               break;
    case S_IFIFO:  printf("FIFO/pipe\n");               break;
    case S_IFLNK:  printf("symlink\n");                 break;
    case S_IFREG:  printf("regular file\n");            break;
    case S_IFSOCK: printf("socket\n");                  break;
    default:       printf("unknown?\n");                break;
    }

    printf("I-node number:            %ld\n", (long) sb.st_ino);

    printf("Mode:                     %lo (octal)\n",
            (unsigned long) sb.st_mode);

    printf("Link count:               %ld\n", (long) sb.st_nlink);
    printf("Ownership:                UID=%ld   GID=%ld\n",
            (long) sb.st_uid, (long) sb.st_gid);

    printf("Preferred I/O block size: %ld bytes\n",
            (long) sb.st_blksize);
    printf("File size:                %lld bytes\n",
            (long long) sb.st_size);
    printf("Blocks allocated:         %lld\n",
            (long long) sb.st_blocks);

    printf("Last status change:       %s", ctime((time_t *)(&sb.st_ctime)));
    printf("Last file access:         %s", ctime((time_t *)(&sb.st_atime)));
    printf("Last file modification:   %s", ctime((time_t *)(&sb.st_mtime)));

    return 0;
}

