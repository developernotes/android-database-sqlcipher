
LOCAL_LIBCUTILS_PATH := $(call my-dir)

LIBCUTILS_SOURCE_PATH := $(LOCAL_LIBCUTILS_PATH)/platform-system-core/libcutils
LIBCUTILS_HEADER_PATH := $(LOCAL_LIBCUTILS_PATH)/platform-system-core/include
BIONIC_INCLUDE_PATH := $(LOCAL_LIBCUTILS_PATH)/bionic/libc/include
BIONIC_KERNEL_INCLUDE_PATH := $(LOCAL_LIBCUTILS_PATH)/bionic/libc/kernel/common

include $(CLEAR_VARS)

ifeq ($(TARGET_CPU_SMP),true)
    targetSmpFlag := -DANDROID_SMP=1
else
    targetSmpFlag := -DANDROID_SMP=0
endif
hostSmpFlag := -DANDROID_SMP=0

commonSources := \
	$(LIBCUTILS_SOURCE_PATH)/array.c \
	$(LIBCUTILS_SOURCE_PATH)/hashmap.c \
	$(LIBCUTILS_SOURCE_PATH)/atomic.c.arm \
	$(LIBCUTILS_SOURCE_PATH)/native_handle.c \
	$(LIBCUTILS_SOURCE_PATH)/buffer.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_inaddr_any_server.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_local_client.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_local_server.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_loopback_client.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_loopback_server.c \
	$(LIBCUTILS_SOURCE_PATH)/socket_network_client.c \
	$(LIBCUTILS_SOURCE_PATH)/sockets.c \
	$(LIBCUTILS_SOURCE_PATH)/config_utils.c \
	$(LIBCUTILS_SOURCE_PATH)/cpu_info.c \
	$(LIBCUTILS_SOURCE_PATH)/load_file.c \
	$(LIBCUTILS_SOURCE_PATH)/list.c \
	$(LIBCUTILS_SOURCE_PATH)/open_memstream.c \
	$(LIBCUTILS_SOURCE_PATH)/strdup16to8.c \
	$(LIBCUTILS_SOURCE_PATH)/strdup8to16.c \
	$(LIBCUTILS_SOURCE_PATH)/record_stream.c \
	$(LIBCUTILS_SOURCE_PATH)/process_name.c \
	$(LIBCUTILS_SOURCE_PATH)/properties.c \
	$(LIBCUTILS_SOURCE_PATH)/threads.c \
	$(LIBCUTILS_SOURCE_PATH)/sched_policy.c \
	$(LIBCUTILS_SOURCE_PATH)/iosched_policy.c \
	$(LIBCUTILS_SOURCE_PATH)/str_parms.c

commonHostSources := \
        $(LIBCUTILS_SOURCE_PATH)/ashmem-host.c

# some files must not be compiled when building against Mingw
# they correspond to features not used by our host development tools
# which are also hard or even impossible to port to native Win32
WINDOWS_HOST_ONLY :=
ifeq ($(HOST_OS),windows)
    ifeq ($(strip $(USE_CYGWIN)),)
        WINDOWS_HOST_ONLY := 1
    endif
endif
# USE_MINGW is defined when we build against Mingw on Linux
ifneq ($(strip $(USE_MINGW)),)
    WINDOWS_HOST_ONLY := 1
endif

ifeq ($(WINDOWS_HOST_ONLY),1)
    commonSources += \
        $(LIBCUTILS_SOURCE_PATH)/uio.c
else
    commonSources += \
        $(LIBCUTILS_SOURCE_PATH)/abort_socket.c \
        $(LIBCUTILS_SOURCE_PATH)/mspace.c \
        $(LIBCUTILS_SOURCE_PATH)/selector.c \
        $(LIBCUTILS_SOURCE_PATH)/tztime.c \
        $(LIBCUTILS_SOURCE_PATH)/zygote.c

    commonHostSources += \
        $(LIBCUTILS_SOURCE_PATH)/tzstrftime.c
endif


# Static library for host
# ========================================================
LOCAL_MODULE := libcutils
LOCAL_SRC_FILES := $(commonSources) $(commonHostSources) dlmalloc_stubs.c
LOCAL_LDLIBS := -lpthread
LOCAL_STATIC_LIBRARIES := liblog
LOCAL_CFLAGS += $(hostSmpFlag)
#include $(BUILD_HOST_STATIC_LIBRARY)


# Shared and static library for target
# ========================================================
include $(CLEAR_VARS)
LOCAL_MODULE := libcutils
LOCAL_SRC_FILES := $(commonSources) $(LIBCUTILS_SOURCE_PATH)/ashmem-dev.c \
	$(LIBCUTILS_SOURCE_PATH)/android_reboot.c \
	$(LIBCUTILS_SOURCE_PATH)/partition_utils.c \
	$(LIBCUTILS_SOURCE_PATH)/qtaguid.c \
	$(LIBCUTILS_SOURCE_PATH)/klog.c
	#$(LIBCUTILS_SOURCE_PATH)/mq.c
	#$(LIBCUTILS_SOURCE_PATH)/uevent.c


ifeq ($(TARGET_ARCH),arm)
LOCAL_SRC_FILES += $(LIBCUTILS_SOURCE_PATH)/arch-arm/memset32.S
else  # !arm
ifeq ($(TARGET_ARCH),sh)
LOCAL_SRC_FILES += $(LIBCUTILS_SOURCE_PATH)/memory.c $(LIBCUTILS_SOURCE_PATH)/atomic-android-sh.c
else  # !sh
ifeq ($(TARGET_ARCH_VARIANT),x86-atom)
LOCAL_CFLAGS += -DHAVE_MEMSET16 -DHAVE_MEMSET32
LOCAL_SRC_FILES += $(LIBCUTILS_SOURCE_PATH)/arch-x86/android_memset16.S $(LIBCUTILS_SOURCE_PATH)/arch-x86/android_memset32.S memory.c
else # !x86-atom
LOCAL_SRC_FILES += $(LIBCUTILS_SOURCE_PATH)/memory.c
endif # !x86-atom
endif # !sh
endif # !arm

LOCAL_CFLAGS += -DHAVE_PTHREADS
LOCAL_C_INCLUDES := $(KERNEL_HEADERS) $(LIBCUTILS_HEADER_PATH) $(BIONIC_INCLUDE_PATH) $(BIONIC_KERNEL_INCLUDE_PATH)
LOCAL_STATIC_LIBRARIES := liblog
LOCAL_CFLAGS += $(targetSmpFlag)
include $(BUILD_STATIC_LIBRARY)

# include $(CLEAR_VARS)
# LOCAL_MODULE := libcutils
# LOCAL_WHOLE_STATIC_LIBRARIES := libcutils
# LOCAL_SHARED_LIBRARIES := liblog
# LOCAL_CFLAGS += $(targetSmpFlag)
# include $(BUILD_SHARED_LIBRARY)

# include $(CLEAR_VARS)
# LOCAL_MODULE := tst_str_parms
# LOCAL_CFLAGS += -DTEST_STR_PARMS
# LOCAL_SRC_FILES := str_parms.c hashmap.c memory.c
# LOCAL_SHARED_LIBRARIES := liblog
# LOCAL_MODULE_TAGS := optional
# include $(BUILD_EXECUTABLE)

