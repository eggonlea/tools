#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <android/log.h>

#define	LOG(args...)	__android_log_print(ANDROID_LOG_INFO, "daemon", ##args)

int main (int argc, char **argv)
{
	printf("argv[argc] = %p\n", argv[argc]);
	if (argc <= 1) {
		LOG("Usage: %s <command [args...]>\n", argv[0]);
		exit(-1);
	}

	pid_t pid = fork();
	if (pid < 0) {
		LOG("Failed to fork.\n");
		exit(-1);
	} else if (pid > 0) {
		/* parent */
		if (daemon(0, 0) < 0) {
			LOG("Failed to become a daemon.\n");
			exit(-1);
		}
		waitpid(pid, NULL, 0);
		LOG("Child exit. Respawn...\n");
	} else {
		/* child */
		char *argv_child[argc];
		memcpy(argv_child, argv+1, argc-1);
		argv_child[argc-1] = '\0';
		if (execvp(argv_child[0], argv_child)) {
			LOG("Failed to execute %s.\n", argv_child[0]);
			exit(-1);
		} 
	}

	exit(0);
}

