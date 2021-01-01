MEMORY
{
    rom : ORIGIN = 0x00000000, LENGTH = 1M
    ram : ORIGIN = 0x60000000, LENGTH = 1M
}

SECTIONS
{
    .text : ALIGN(4) {
        KEEP(*(.vectors));
        *(.text*);
        *(.rti_fn*);

        . = ALIGN(4);
        __fsymtab_start = .;
        KEEP(*(FSymTab));
        __fsymtab_end = .;

        . = ALIGN(4);
        __vsymtab_start = .;
        KEEP(*(VSymTab));
        __vsymtab_end = .;

        . = ALIGN(4);
        *(.rodata*);
    } >rom

    .ARM.extab : {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >rom

    .ARM.exidx : {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } >rom

    . = ALIGN(4);
    __data_lma_start = .;

    .data : ALIGN(4) {
        __data_start = .;
        *(.data*);
        . = ALIGN(4);
        __data_end = .;
    } >ram AT>rom

    __data_size = SIZEOF(.data);
    __data_lma_end = __data_lma_start + SIZEOF(.data);

    .bss : ALIGN(4) {
        __bss_start = . ;
        *(.bss*);
        __bss_end = .;
    } >ram AT>ram

    __bss_size = SIZEOF(.bss);

    .isr_stack(COPY) : ALIGN(4) {
        *(.isr_stack);
    } >ram

    .rtt_heap(COPY) : ALIGN(4) {
        rtt_heap_start = .;
        . = ORIGIN(ram) + LENGTH(ram);
        rtt_heap_end = .;
    } >ram
}
