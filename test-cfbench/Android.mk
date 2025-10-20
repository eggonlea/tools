LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_CFLAGS		:= -O0 -g
LOCAL_ARM_MODE		:= arm
LOCAL_MODULE		:= test-cfbench
LOCAL_SRC_FILES		:= test-cfbench.c cfbench-memwrite.S
LOCAL_MULTILIB		:= 32
LOCAL_SHARED_LIBRARIES	:= libdl

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_CFLAGS		:= -O0 -g
LOCAL_ARM_MODE		:= arm
LOCAL_MODULE		:= mutex1
LOCAL_SRC_FILES		:= mutex1.c
LOCAL_MULTILIB		:= 32

include $(BUILD_EXECUTABLE)

###

include $(CLEAR_VARS)

LOCAL_CFLAGS		:= -O0 -g
LOCAL_ARM_MODE		:= arm
LOCAL_MODULE		:= mutex2
LOCAL_SRC_FILES		:= mutex2.c
LOCAL_MULTILIB		:= 32

include $(BUILD_EXECUTABLE)
