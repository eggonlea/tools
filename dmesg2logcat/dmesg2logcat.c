#include <stdio.h>
#include <stdlib.h>
#include <android/log.h>

#define BUFSIZE	1024
int main (int argc, char **argv)
{

	char buf[1024];
	FILE *fp = fopen("/proc/kmsg", "r");
	while(1) {
		if(fgets(buf, BUFSIZE, fp))
			__android_log_print(ANDROID_LOG_INFO, "kernel", buf);
	}

	return 0;
}

