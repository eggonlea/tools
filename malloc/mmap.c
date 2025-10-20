#include <sys/mman.h>
#include <stdio.h>

#define KB 1024
#define MB (KB*KB)
#define GB (MB*KB)

int main(void) {
    int i;
    char *mem;
    size_t size;

    for(i=1; i<2314; i++) {

       size = MB*i;

       printf("%d: %d\n", i < 2314, i);

       mem = (char*)mmap(0 /*addr*/, size, PROT_READ|PROT_WRITE,
                                      MAP_PRIVATE|MAP_ANON, -1 /*fd*/, 0/*offseto	*/);
       if (mem == MAP_FAILED) {
           return 1;
       }

       munmap(mem, size);
    }

    return 0;
}
