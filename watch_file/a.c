#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argv, char *argc[])
{
  int loop = 1;

  if (argv < 2 || argv > 4) {
    fprintf(stderr, "Usage: %s <file> [loop]\n", argc[0]);
    return 1;
  }

  if (argv == 3) {
    loop = atoi(argc[2]);
  }

  int fd = open(argc[1], O_RDONLY);
  if (fd < 0) {
    fprintf(stderr, "Failed to open %s, (%d) %s\n", argc[1], errno, strerror(errno));
    return 2;
  }

  for (int i = 1;; i++) {
    int n;
    char buf[4097];
    n = lseek(fd, 0, SEEK_SET);
    if (n < 0) {
      fprintf(stderr, "Failed to seek %s, (%d) %s\n", argc[1], errno, strerror(errno));
      return 3;
    }
    n = read(fd, buf, 4096);
    buf[n] = '\0';
    if (n < 0) {
      fprintf(stderr, "Failed to read %s, (%d) %s\n", argc[1], errno, strerror(errno));
      return 4;
    }
    printf("%s\n", buf);

    if (loop > 0 && i >= loop) break;

    sleep(1);
  }

  return 0;
}
