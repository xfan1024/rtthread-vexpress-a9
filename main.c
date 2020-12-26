#include "pl011.h"
#include "board.h"
#include <stdio.h>
#include <rtthread.h>
#include <shell.h>
#include <interrupt.h>

#define TIMER_LOAD(hw_base)             __REG32(hw_base + 0x00)
#define TIMER_VALUE(hw_base)            __REG32(hw_base + 0x04)
#define TIMER_CTRL(hw_base)             __REG32(hw_base + 0x08)
#define TIMER_CTRL_ONESHOT              (1 << 0)
#define TIMER_CTRL_32BIT                (1 << 1)
#define TIMER_CTRL_DIV1                 (0 << 2)
#define TIMER_CTRL_DIV16                (1 << 2)
#define TIMER_CTRL_DIV256               (2 << 2)
#define TIMER_CTRL_IE                   (1 << 5)        /* Interrupt Enable (versatile only) */
#define TIMER_CTRL_PERIODIC             (1 << 6)
#define TIMER_CTRL_ENABLE               (1 << 7)

#define TIMER_INTCLR(hw_base)           __REG32(hw_base + 0x0c)
#define TIMER_RIS(hw_base)              __REG32(hw_base + 0x10)
#define TIMER_MIS(hw_base)              __REG32(hw_base + 0x14)
#define TIMER_BGLOAD(hw_base)           __REG32(hw_base + 0x18)

#define REALVIEW_SCTL_BASE          0x10001000  /* System Controller */
#define REALVIEW_TIMER2_3_BASE      0x10012000  /* Timer 2 and 3 */
#define REALVIEW_REFCLK 0
#define IRQ_PBA8_GIC_START          32
#define IRQ_PBA8_TIMER2_3   (IRQ_PBA8_GIC_START + 3)    /* Timer 2/3 */

#define SYS_CTRL                        __REG32(REALVIEW_SCTL_BASE)
#define TIMER_HW_BASE                   REALVIEW_TIMER2_3_BASE


static void rt_hw_timer_isr(int vector, void *param)
{
    rt_tick_increase();
    /* clear interrupt */
    TIMER_INTCLR(TIMER_HW_BASE) = 0x01;
}

int rt_hw_timer_init(void)
{
    rt_uint32_t val;

    SYS_CTRL |= REALVIEW_REFCLK;

    /* Setup Timer0 for generating irq */
    val = TIMER_CTRL(TIMER_HW_BASE);
    val &= ~TIMER_CTRL_ENABLE;
    val |= (TIMER_CTRL_32BIT | TIMER_CTRL_PERIODIC | TIMER_CTRL_IE);
    TIMER_CTRL(TIMER_HW_BASE) = val;

    TIMER_LOAD(TIMER_HW_BASE) = 1000000/RT_TICK_PER_SECOND;

    /* enable timer */
    TIMER_CTRL(TIMER_HW_BASE) |= TIMER_CTRL_ENABLE;

    rt_hw_interrupt_install(IRQ_PBA8_TIMER2_3, rt_hw_timer_isr, RT_NULL, "tick");
    rt_hw_interrupt_umask(IRQ_PBA8_TIMER2_3);

    return 0;
}

static void hello_puts(const char *s)
{
    while (*s)
    {
        pl011_putchar(UART0_BASE, *s++);
    }
}

static void idle_wfi()
{
    __asm("wfi");
}


void rt_hw_board_init()
{
    pl011_init(UART0_BASE, 115200);

    rt_thread_idle_sethook(idle_wfi);
    rt_hw_interrupt_init();
    rt_hw_timer_init();
#if defined(RT_USING_HEAP)
    extern unsigned int rtt_heap_start[];
    extern unsigned int rtt_heap_end[];
    rt_kprintf("init heap 0x%p - 0x%p\n", rtt_heap_start, rtt_heap_end);
    rt_system_heap_init(rtt_heap_start, rtt_heap_end);
#endif
}

int rt_hw_console_getchar(void)
{
    int ch = pl011_getchar(UART0_BASE);

    if (ch < 0)
    {
        rt_thread_mdelay(10);
    }
    
    return ch;
}

void rt_hw_console_output(const char *str)
{
    while (*str)
    {
        pl011_putchar(UART0_BASE, *str++);
    }
}

int main(void)
{
    rt_kprintf("main task is running\n");
    finsh_system_init();
    return 0;
}

