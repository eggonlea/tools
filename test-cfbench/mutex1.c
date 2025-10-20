// Name: spinlockvsmutex1.cc
// Source: http://www.alexonlinux.com/pthread-mutex-vs-pthread-spinlock
// Compiler(spin lock version): g++ -o spin_version -DUSE_SPINLOCK spinlockvsmutex1.cc -lpthread
// Compiler(mutex version): g++ -o mutex_version spinlockvsmutex1.cc -lpthread
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>
#include <sys/time.h>
#include <pthread.h>
#include <stdlib.h>
 
#define LOOPS 100000000
 
int the_list;
 
#ifdef USE_SPINLOCK
pthread_spinlock_t spinlock;
#else
pthread_mutex_t mutex;
#endif
 
//Get the thread id
pid_t gettid() { return syscall( __NR_gettid ); }
 
void *consumer(void *ptr)
{
    printf("Consumer TID %lu\n", (unsigned long)gettid());
 
    while (1)
    {
#ifdef USE_SPINLOCK
        pthread_spin_lock(&spinlock);
#else
        pthread_mutex_lock(&mutex);
#endif
 
        if (the_list <= 0)
        {
#ifdef USE_SPINLOCK
            pthread_spin_unlock(&spinlock);
#else
            pthread_mutex_unlock(&mutex);
#endif
            break;
        }
 
        the_list--;
 
#ifdef USE_SPINLOCK
        pthread_spin_unlock(&spinlock);
#else
        pthread_mutex_unlock(&mutex);
#endif
    }
 
    return NULL;
}
 
int main(int argc, char *argv[])
{
    int n = 2;
    if(argc > 1)
        n = atoi(argv[1]);
    if(n <= 0 || n > 9)
        n = 2;

    printf("Thread - %d\n", n);
    the_list = LOOPS;

    pthread_t thr[9];
    struct timeval tv1, tv2;
 
#ifdef USE_SPINLOCK
    pthread_spin_init(&spinlock, 0);
#else
    pthread_mutex_init(&mutex, NULL);
#endif
 
    // Measuring time before starting the threads...
    gettimeofday(&tv1, NULL);
 
    int i;
    for(i=0; i<n; i++) {
        pthread_create(&(thr[i]), NULL, consumer, NULL);
        pthread_join(thr[i], NULL);
    }
    // Measuring time after threads finished...
    gettimeofday(&tv2, NULL);
 
    if (tv1.tv_usec > tv2.tv_usec)
    {
        tv2.tv_sec--;
        tv2.tv_usec += 1000000;
    }
 
    printf("Result - %ld.%ld\n", tv2.tv_sec - tv1.tv_sec,
        tv2.tv_usec - tv1.tv_usec);
 
#ifdef USE_SPINLOCK
    pthread_spin_destroy(&spinlock);
#else
    pthread_mutex_destroy(&mutex);
#endif
 
    return 0;
}
