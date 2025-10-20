LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := fsync.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_FSYNC
LOCAL_MODULE := fsync
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_SRC_FILES := fsync.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_FDATASYNC
LOCAL_MODULE := fdatasync
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_SRC_FILES := fsync.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_DUMMYSYNC
LOCAL_MODULE := fdummysync
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := bench.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_FSYNC
LOCAL_MODULE := fsyncbench
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_SRC_FILES := bench.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_FDATASYNC
LOCAL_MODULE := fdatasyncbench
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_SRC_FILES := bench.c

LOCAL_CFLAGS += -Wall -Wextra -DUSE_DUMMYSYNC
LOCAL_MODULE := fdummysyncbench
LOCAL_MULTILIB := 32

include $(BUILD_EXECUTABLE)

