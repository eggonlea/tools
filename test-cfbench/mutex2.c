//Name: svm2.c
//Source: http://www.solarisinternals.com/wiki/index.php/DTrace_Topics_Locks
//Compile(spin lock version): gcc -o spin -DUSE_SPINLOCK svm2.c -lpthread
//Compile(mutex version): gcc -o mutex svm2.c -lpthread
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/syscall.h>
 
#define LOOPS 100000000

int workload;

pthread_t g_thread[9];
#ifdef USE_SPINLOCK
pthread_spinlock_t g_spin;
#else
pthread_mutex_t g_mutex;
#endif
__uint64_t g_count = 0;
 
pid_t gettid()
{
    return syscall(SYS_gettid);
}
 
void *run_amuck(void *arg)
{
       int i;
 
       printf("Thread %lu started.\n", (unsigned long)gettid());
 
       while(g_count < LOOPS) {
#ifdef USE_SPINLOCK
           pthread_spin_lock(&g_spin);
#else
               pthread_mutex_lock(&g_mutex);
#endif
               for (i = 0; i < workload; i++) {
			g_count++;
       			if(g_count >= LOOPS)
				break;
               }
#ifdef USE_SPINLOCK
           pthread_spin_unlock(&g_spin);
#else
               pthread_mutex_unlock(&g_mutex);
#endif
       }
        
       printf("Thread %lu finished!\n", (unsigned long)gettid());
 
       return (NULL);
}
 
int main(int argc, char *argv[])
{
	int n = LOOPS / 2;
	if(argc > 1)
		n = atoi(argv[1]);
	if(n<=0)
		n = LOOPS / 2;
	printf("Workload: %d\n", n);
	workload = n;

       int i, threads = 9;
 
       printf("Creating %d threads...\n", threads);
#ifdef USE_SPINLOCK
       pthread_spin_init(&g_spin, 0);
#else
       pthread_mutex_init(&g_mutex, NULL);
#endif
       for (i = 0; i < threads; i++)
               pthread_create(&g_thread[i], NULL, run_amuck, (void *) i);
 
       for (i = 0; i < threads; i++)
               pthread_join(g_thread[i], NULL);
 
       printf("Done.\n");
 
       return (0);
}
