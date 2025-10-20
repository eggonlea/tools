#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

void touch_file(const char *path)
{
  int fd;
  int len;
  struct stat statbuf;
  void *addr;

  if ((fd = open(path, O_RDONLY)) < 0) {
    fprintf(stderr, "Failed to open file %s\n", path);
    return;
  }

  if (fstat(fd, &statbuf) < 0) {
    fprintf(stderr, "Failed to stat file %s\n", path);
    goto fexit;
  }

  if ((len = statbuf.st_size) <= 0) {
    // no need to mmap
    goto fexit;
  }

  if ((addr = mmap(NULL, len, PROT_READ, MAP_PRIVATE | MAP_LOCKED | MAP_POPULATE, fd, 0)) == MAP_FAILED) {
    fprintf(stderr, "Failed to mmap file %s\n", path);
    goto fexit;
  }

  if (mlock(addr, len) < 0) {
    fprintf(stderr, "Filed to mlock file %s\n", path);
    goto mexit;
  }

  munlock(addr, len);
mexit:
  munmap(addr, len);
fexit:
  close(fd);
}

void traverse(const char *path)
{
  DIR *dir;
  struct dirent *ent;

  if (!(dir = opendir(path))) {
    fprintf(stderr, "Failed to open dir %s\n", path);
    return;
  }

  while (!!(ent = readdir(dir))) {
    char next[PATH_MAX];
    snprintf(next, PATH_MAX, "%s/%s", path, ent->d_name);
    switch (ent->d_type) {
    case DT_DIR:
      if ((!strcmp(ent->d_name, ".")) || (!strcmp(ent->d_name, "..")))
        continue;
      traverse(next);
      break;
    case DT_REG:
      touch_file(next);
      break;
    default:
      break;
    }
  }
}

int main (int argc, char **argv)
{
  struct timespec tp1, tp2, tp3;

  clock_gettime(CLOCK_MONOTONIC, &tp1);
  traverse(argc > 1 ? argv[1] : ".");
  clock_gettime(CLOCK_MONOTONIC, &tp2);

  tp3.tv_sec = tp2.tv_sec - tp1.tv_sec;
  tp3.tv_nsec = tp2.tv_nsec - tp1.tv_nsec;
  if (tp3.tv_nsec < 0) {
    tp3.tv_sec--;
    tp3.tv_nsec += 1000000000L;
  }

  printf("Duration: %ld.%09ld\n", tp3.tv_sec, tp3.tv_nsec);

  return 0;
}

