#ifndef __pl011_h__
#define __pl011_h__

#include <stdint.h>

void pl011_init(uintptr_t base, uint32_t baudrate);
void pl011_putchar(uintptr_t base, char ch);
int pl011_getchar(uintptr_t base);

#endif
