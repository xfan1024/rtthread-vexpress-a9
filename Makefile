CROSS_COMPILE := arm-none-eabi-
CC := $(CROSS_COMPILE)gcc

CFLAGS := -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=softfp -g -Og
AFLAGS := -march=armv7-a -mtune=cortex-a9 -g -Og
LFLAGS := -specs=nosys.specs -T link.ld -nostartfiles

C_SRCS := main.c pl011.c
S_SRCS := startup.S
TARGET := rt-thread

INCLUDE_DIR := 	-I. \
				-Irtthread-nano/rt-thread/include \
				-Irtthread-nano/rt-thread/components/finsh \
				-Irtthread-nano/rt-thread/libcpu/arm/cortex-a

CFLAGS += $(INCLUDE_DIR)
AFLAGS += $(INCLUDE_DIR)

C_SRCS += $(wildcard rtthread-nano/rt-thread/src/*.c)
C_SRCS += $(wildcard rtthread-nano/rt-thread/components/finsh/*.c)
C_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/*.c)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/*_init.S)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/context_gcc.S)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/cp15_gcc.S)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/vector_gcc.S)

include build.mk

.PHONY: link delete_target

delete_target:
	@[ "$(HIDE)" = "@" ] && echo " DELETE   $(TARGET)" || true
	$(HIDE)rm -f $(TARGET)

link: delete_target $(TARGET)
