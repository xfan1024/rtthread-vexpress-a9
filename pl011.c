#include "pl011.h"
#include "pl011_pri.h"
#include "board.h"

struct pl011_regs
{
    uint32_t dr;
    uint32_t ecr;
    uint32_t pl010_lcrh;
    uint32_t pl010_lcrm;
    uint32_t pl010_lcrl;
    uint32_t pl010_cr;
    uint32_t fr;
    uint32_t pl011_rlcr;
    uint32_t ilpr;
    uint32_t pl011_ibrd;
    uint32_t pl011_fbrd;
    uint32_t pl011_lcrh;
    uint32_t pl011_cr;
};


#define RREG(base, reg) (*(volatile uint32_t*)&(((struct pl011_regs*)(base))->reg))
#define WREG(base, reg, val) RREG(base, reg) = val

void pl011_init(uintptr_t base, uint32_t baudrate)
{
    WREG(base, pl011_cr, 0);
    unsigned int temp;
    unsigned int divider;
    unsigned int remainder;
    unsigned int fraction;

    /*
     * Set baud rate
     *
     * IBRD = UART_CLK / (16 * BAUD_RATE)
     * FBRD = RND((64 * MOD(UART_CLK,(16 * BAUD_RATE))) / (16 * BAUD_RATE))
     */
    temp = 16 * baudrate;
    divider = PL011_CLOCK / temp;
    remainder = PL011_CLOCK % temp;
    temp = (8 * remainder) / baudrate;
    fraction = (temp >> 1) + (temp & 1);

    WREG(base, pl011_ibrd, divider);
    WREG(base, pl011_fbrd, fraction);

    WREG(base, pl010_lcrh, UART_PL010_LCRH_WLEN_8 | UART_PL010_LCRH_FEN);
    /* Finally, enable the UART */
    WREG(base, pl010_cr, UART_PL010_CR_UARTEN);

}

void pl011_putchar(uintptr_t base, char ch)
{
    while (RREG(base, fr) & UART_PL01x_FR_TXFF)
    {}
    WREG(base, dr, ch);
}

int pl011_getchar(uintptr_t base)
{
    if (RREG(base, fr) & UART_PL01x_FR_RXFE)
    {
        return -1;
    }
    return RREG(base, dr) & 0xff;
}

