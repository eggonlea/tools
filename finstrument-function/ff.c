#include <stdio.h>

static int n;

void __attribute__((no_instrument_function))  
__cyg_profile_func_enter(void *this_func, void *call_site)  
{  
	int i;
	for(i=0; i<n; i++)
		printf(" ");
	printf("%p <- %p {\n", this_func, call_site);
	n++;
}  
  
  
void __attribute__((no_instrument_function))  
__cyg_profile_func_exit(void *this_func, void *call_site)  
{  
	int i;
	n--;
	for(i=0; i<n; i++)
		printf(" ");
	printf("} %p -> %p\n", this_func, call_site);
}  
