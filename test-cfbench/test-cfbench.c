#include <stdio.h>
#include <dlfcn.h>
#include <time.h>
#include <pthread.h>

#define	UNUSED		__attribute__ ((unused))
#define MAX_THREADS	8

static long (*bench_mips)(void);
static long (*bench_msflops)(void);
static long (*bench_mdflops)(void);
static long (*bench_malloc)(void);
static long (*bench_memread)(void);
static long (*bench_memwrite)(void);
static long bench_asm_memwrite(void);
extern long __bench_asm_memwrite(void *ptr, int size);
static long bench_java_memwrite(void);
extern long __bench_java_memwrite(void *ptr, int size);
int (*__clock_gettime)(clockid_t clk_id, struct timespec *tp);

void *load_symbols(void)
{
	void *handle;

	handle = dlopen("./libCFBench.so", RTLD_LAZY);
	if (handle == NULL)
		return NULL;

	__clock_gettime		= clock_gettime;
	bench_mips		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMIPS");
	bench_msflops		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMSFLOPS");
	bench_mdflops		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMDFLOPS");
	bench_malloc		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMalloc");
	bench_memread		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMemReadAligned");
	bench_memwrite		= dlsym(handle, "Java_eu_chainfire_cfbench_BenchNative_benchMemWriteAligned");

	printf("clock_gettime	@%p\n", __clock_gettime);
	printf("bench_mips	@%p\n", bench_mips);
	printf("bench_msflops	@%p\n", bench_msflops);
	printf("bench_mdflops	@%p\n", bench_mdflops);
	printf("bench_malloc	@%p\n", bench_malloc);
	printf("bench_memread	@%p\n", bench_memread);
	printf("bench_memwrite	@%p\n", bench_memwrite);
	return handle;
}

static struct {
	pthread_t	thread;
	long		(*func)(void);
	long		result;
} threads[MAX_THREADS];

void *bench_thread_fn(void *arg)
{
	int i = (int)arg;
	threads[i].result = (*threads[i].func)();
	return NULL;
}

void bench(int num_threads, const char *name, long (*bench_func)(void))
{
	int i;

	if (num_threads > MAX_THREADS) {
		printf("num threads %d exceeds maximum %d\n", num_threads, MAX_THREADS);
		return;
	}

	for (i = 0; i < num_threads; i++) {
		threads[i].func = bench_func;
		pthread_create(&threads[i].thread, NULL, bench_thread_fn, (void *)i);
	}

	for (i = 0; i < num_threads; i++)
		pthread_join(threads[i].thread, NULL);

	int total = 0;
	printf("%10s: ", name);
	for (i = 0; i < num_threads; i++)
		total += threads[i].result;
	printf("%ld: ", total);
	for (i = 0; i < num_threads; i++)
		printf(" %ld", threads[i].result);
	printf("\n");
}

long bench_asm_memwrite(void)
{
	int size = 1024 * 1024;
	void *ptr = malloc(size);
	long ret = __bench_asm_memwrite(ptr, size);
	free(ptr);

	return ret;
}

long bench_java_memwrite(void)
{
	int size = 1024 * 1024 + 12;
	void *ptr = malloc(size);
	int *psize = (int *)ptr;
	psize[2] = size;
	long ret = __bench_java_memwrite(ptr, size);
	free(ptr);

	return ret;
}

static void bench_cmp_branch(void)
{
	int i;
	for (i = 0; i < 100; i++) {
		int loop_count = 10000000;
		__asm__ __volatile__(
		"1:\n"
		"subs	%0, %0, #1\n"
		"bge	1b\n"
		: : "r"(loop_count) :);
	}
}

int main(UNUSED int argc, UNUSED char *argv[])
{
	void *handle;

	handle = load_symbols();

	//printf("MIPS: 1xthread %ld\n", bench_mips());
#if 0
	bench(4, "MIPS", 	bench_mips);
	bench(4, "MSFLOPS", 	bench_msflops);
	bench(4, "MDFLOPS", 	bench_mdflops);
	bench(4, "MALLOC", 	bench_malloc);
	bench(4, "MEMREAD",	bench_memread);
	bench(4, "MEMWRITE",	bench_memwrite);
	bench(1, "MEMWRITE_S",	bench_asm_memwrite);
	bench(1, "MEMWRITE_J",	bench_java_memwrite);
#endif

	//bench_cmp_branch();
	int i;
	for(i=1; i<=8; i++)
		bench(i, "MALLOC", 	bench_malloc);

	return 0;
}
