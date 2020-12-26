#ifndef __board_h__
#define __board_h__

#define UART0_BASE  0x10009000

#define PL011_CLOCK 24000000

#define MAX_HANDLERS	96

#define REALVIEW_GIC_DIST_BASE      0x1E001000  /* Generic interrupt controller distributor */
#define REALVIEW_GIC_CPU_BASE       0x1E000100  /* Generic interrupt controller CPU interface */


#define platform_get_gic_dist_base()    REALVIEW_GIC_DIST_BASE
#define platform_get_gic_cpu_base()     REALVIEW_GIC_CPU_BASE
#define GIC_IRQ_START                   0
#define GIC_ACK_INTID_MASK              0x000003ff
#define ARM_GIC_MAX_NR                  1
#define ARM_GIC_NR_IRQS                 96

#define __REG32(addr) (*((volatile unsigned int*)(addr)))

#endif

