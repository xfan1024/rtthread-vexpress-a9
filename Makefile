CROSS_COMPILE := arm-none-eabi-
CC := $(CROSS_COMPILE)gcc

CFLAGS := -march=armv7-a -mtune=cortex-a9 -msoft-float -O3
AFLAGS := -march=armv7-a -mtune=cortex-a9 -O3
LFLAGS := -specs=nosys.specs -specs=nano.specs -nostartfiles
LFLAGS += -Wl,--wrap=_malloc_r -Wl,--wrap=_realloc_r -Wl,--wrap=_free_r -Wl,--wrap=_calloc_r
LDSCRIPT := link.ld

TARGET := rt-thread

INCLUDE_DIR := 	-I. -Iinclude
C_SRCS := main.c pl011.c wrap_malloc.c
S_SRCS := startup.S
FILTER_OUT :=

# add rtthread-nano
INCLUDE_DIR += -Irtthread-nano/rt-thread/include \
				-Irtthread-nano/rt-thread/components/finsh \
				-Irtthread-nano/rt-thread/libcpu/arm/cortex-a
C_SRCS += $(wildcard rtthread-nano/rt-thread/src/*.c)
C_SRCS += $(wildcard rtthread-nano/rt-thread/components/finsh/*.c)
C_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/*.c)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/*_init.S)
S_SRCS += $(wildcard rtthread-nano/rt-thread/libcpu/arm/cortex-a/*_gcc.S)
FILTER_OUT += rtthread-nano/rt-thread/libcpu/arm/cortex-a/start_gcc.S

# add mbedtls
INCLUDE_DIR += -Imbedtls/mbedtls/include -Imbedtls/ports/inc
CFLAGS += -DMBEDTLS_CONFIG_FILE=\<mbedtls/config.h\>
C_SRCS += $(wildcard mbedtls/mbedtls/library/*.c)
C_SRCS += mbedtls/ports/src/timing_alt.c

# add mbedtls_bench
C_SRCS += mbedtls_bench/mbedtls_bench.c

CFLAGS += $(INCLUDE_DIR)
AFLAGS += $(INCLUDE_DIR)
C_SRCS := $(filter-out $(FILTER_OUT),$(C_SRCS))
S_SRCS := $(filter-out $(FILTER_OUT),$(S_SRCS))

include build.mk

OFILES += $(TARGET).bin

$(TARGET).bin : $(TARGET)
	@[ "$(HIDE)" = "@" ] && echo " OBJCOPY  $(TARGET).bin" || true
	$(HIDE)$(CROSS_COMPILE)objcopy -O binary $(TARGET) $(TARGET).bin

all: $(TARGET).bin
