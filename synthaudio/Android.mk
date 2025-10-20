LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE_TAGS := tests

LOCAL_C_INCLUDES:=

LOCAL_SRC_FILES:= synthaudio.cpp

LOCAL_SHARED_LIBRARIES := libutils liblog libcutils

LOCAL_MODULE:= synthaudio

# LOCAL_CFLAGS += 

include $(BUILD_EXECUTABLE)
