
.PHONY: all
all: $(TARGET)

OBJS :=
DEPS :=

ifeq ($(V),1)
HIDE:=
else
HIDE:=@
endif

define add_c_source
$(eval _SRC := $(1))
$(eval _OBJ := $(patsubst %.c,%.o,$(1)))
OBJS += $(_OBJ)
DEPS += $(_SRC).d
$(_OBJ) : $(_SRC)
	@[ "$(HIDE)" = "@" ] && echo " CC       $(_OBJ)" || true
	$(HIDE)$(CC) -c $(_SRC) $(CFLAGS) -MMD -MF $(_SRC).d  -o $(_OBJ)
endef

define add_s_source
$(eval _SRC := $(1))
$(eval _OBJ := $(patsubst %.S,%.o,$(1)))
OBJS += $(_OBJ)
DEPS += $(_SRC).d
$(_OBJ) : $(_SRC)
	@[ "$(HIDE)" = "@" ] && echo " AS       $(_OBJ)" || true
	$(HIDE)$(CC) -c $(_SRC) $(AFLAGS) -MMD -MF $(_SRC).d  -o $(_OBJ)
endef

$(foreach f,$(C_SRCS),$(eval $(call add_c_source,$(f))))
$(foreach f,$(S_SRCS),$(eval $(call add_s_source,$(f))))
ifneq ($(LDSCRIPT),)
	LFLAGS += -T $(LDSCRIPT)
endif

$(TARGET): $(OBJS) $(LDSCRIPT)
	@[ "$(HIDE)" = "@" ] && echo " LD       $(TARGET)" || true
	$(HIDE)$(CC) $(OBJS) $(LFLAGS) -o $(TARGET) -Wl,-Map=$(TARGET).map,--cref
	@[ "$(HIDE)" = "@" ] && echo " OBJDUMP  $(TARGET).asm" || true
	$(HIDE)$(CROSS_COMPILE)objdump -d $(TARGET) >$(TARGET).asm

.PHONY: clean
clean:
	rm -f $(OBJS) $(DEPS) $(TARGET) $(TARGET).asm $(TARGET).map

-include $(DEPS)
