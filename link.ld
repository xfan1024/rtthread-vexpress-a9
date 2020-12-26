MEMORY
{
    ram : ORIGIN = 0x60000000, LENGTH = 1M
}

SECTIONS
{
    .text : {
        KEEP(*(.vectors));
        *(.text*);
        *(.rti_fn*);

        __fsymtab_start = .;
        KEEP(*(FSymTab));
        __fsymtab_end = .;
        
        __vsymtab_start = .;
        KEEP(*(VSymTab));
        __vsymtab_end = .;


    } > ram
    
    .rodata : {
        *(.rodata*);
    } > ram

    .data : {
        *(.data*);
    } > ram

    .bss : {
        __bss_start = . ;
        *(.bss*);
        __bss_end = .;
    } > ram

    .heap : {
        rtt_heap_start = .;
        . = ORIGIN(ram) + LENGTH(ram);
        rtt_heap_end = .;
    } > ram
}
