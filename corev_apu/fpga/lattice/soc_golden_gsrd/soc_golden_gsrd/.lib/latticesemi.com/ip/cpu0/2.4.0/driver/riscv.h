/*   ==================================================================

     >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
     ------------------------------------------------------------------
     Copyright (c) 2019-2024 by Lattice Semiconductor Corporation
     ALL RIGHTS RESERVED
     ------------------------------------------------------------------

       IMPORTANT: THIS FILE IS USED BY OR GENERATED BY the LATTICE PROPEL™
       DEVELOPMENT SUITE, WHICH INCLUDES PROPEL BUILDER AND PROPEL SDK.

       Lattice grants permission to use this code pursuant to the
       terms of the Lattice Propel License Agreement.

     DISCLAIMER:

    LATTICE MAKES NO WARRANTIES ON THIS FILE OR ITS CONTENTS,
    WHETHER EXPRESSED, IMPLIED, STATUTORY,
    OR IN ANY PROVISION OF THE LATTICE PROPEL LICENSE AGREEMENT OR
    COMMUNICATION WITH LICENSEE,
    AND LATTICE SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
    MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
    LATTICE DOES NOT WARRANT THAT THE FUNCTIONS CONTAINED HEREIN WILL MEET
    LICENSEE 'S REQUIREMENTS, OR THAT LICENSEE' S OPERATION OF ANY DEVICE,
    SOFTWARE OR SYSTEM USING THIS FILE OR ITS CONTENTS WILL BE
    UNINTERRUPTED OR ERROR FREE,
    OR THAT DEFECTS HEREIN WILL BE CORRECTED.
    LICENSEE ASSUMES RESPONSIBILITY FOR SELECTION OF MATERIALS TO ACHIEVE
    ITS INTENDED RESULTS, AND FOR THE PROPER INSTALLATION, USE,
    AND RESULTS OBTAINED THEREFROM.
    LICENSEE ASSUMES THE ENTIRE RISK OF THE FILE AND ITS CONTENTS PROVING
    DEFECTIVE OR FAILING TO PERFORM PROPERLY AND IN SUCH EVENT,
    LICENSEE SHALL ASSUME THE ENTIRE COST AND RISK OF ANY REPAIR, SERVICE,
    CORRECTION,
    OR ANY OTHER LIABILITIES OR DAMAGES CAUSED BY OR ASSOCIATED WITH THE
    SOFTWARE.IN NO EVENT SHALL LATTICE BE LIABLE TO ANY PARTY FOR DIRECT,
    INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
    INCLUDING LOST PROFITS,
    ARISING OUT OF THE USE OF THIS FILE OR ITS CONTENTS,
    EVEN IF LATTICE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
    LATTICE 'S SOLE LIABILITY, AND LICENSEE' S SOLE REMEDY,
    IS SET FORTH ABOVE.
    LATTICE DOES NOT WARRANT OR REPRESENT THAT THIS FILE,
    ITS CONTENTS OR USE THEREOF DOES NOT INFRINGE ON THIRD PARTIES'
    INTELLECTUAL PROPERTY RIGHTS, INCLUDING ANY PATENT. IT IS THE USER' S
    RESPONSIBILITY TO VERIFY THE USER SOFTWARE DESIGN FOR CONSISTENCY AND
    FUNCTIONALITY THROUGH THE USE OF FORMAL SOFTWARE VALIDATION METHODS.
     ------------------------------------------------------------------

     ================================================================== */

#ifndef BSP_DRIVER_RISCV_RISCV_H__
#define BSP_DRIVER_RISCV_RISCV_H__


#include <stdio.h>

#define MTVEC_MODE_DIRECT       0
#define MTVEC_MODE_VECTORED     1
#define MTVEC_MODE_SEL          MTVEC_MODE_DIRECT


#define __ASM_STR(x)    #x

#define csr_read(csr)                                   \
    ({                                                  \
        register unsigned long __v;                     \
        __asm__ __volatile__("csrr %0, " __ASM_STR(csr) \
                             : "=r"(__v)                \
                             :                          \
                             : "memory");               \
        __v;                                            \
    })

#define csr_write(csr, val)                                \
    ({                                                     \
        unsigned long __v = (unsigned long)(val);          \
        __asm__ __volatile__("csrw " __ASM_STR(csr) ", %0" \
                             :                             \
                             : "rK"(__v)                   \
                             : "memory");                  \
    })


typedef uint32_t reg_t;
typedef struct {
	/* ignore x0 */
	reg_t ra;
	reg_t sp;
	reg_t gp;
	reg_t tp;
	reg_t t0;
	reg_t t1;
	reg_t t2;
	reg_t s0;
	reg_t s1;
	reg_t a0;
	reg_t a1;
	reg_t a2;
	reg_t a3;
	reg_t a4;
	reg_t a5;
	reg_t a6;
	reg_t a7;
	reg_t s2;
	reg_t s3;
	reg_t s4;
	reg_t s5;
	reg_t s6;
	reg_t s7;
	reg_t s8;
	reg_t s9;
	reg_t s10;
	reg_t s11;
	reg_t t3;
	reg_t t4;
	reg_t t5;
	reg_t t6;
	// upon is trap frame

	// save the pc to run in next schedule cycle
	reg_t pc; 
} context_t;


#define MCAUSE_VAL_MASK 0xF
#define MCAUSE_VAL_MEIP 11
#define MCAUSE_VAL_SEIP 9
#define MCAUSE_VAL_MTIP 7
#define MCAUSE_VAL_STIP 5
#define MCAUSE_VAL_MSIP 3

#define MIE_VAL_USIE 0x001		// U mode Soft INT
#define MIE_VAL_SSIE 0x002		// S mode Soft INT
#define MIE_VAL_MSIE 0x008		// M mode Soft INT
#define MIE_VAL_UTIE 0x010		// U mode Timer INT
#define MIE_VAL_STIE 0x020		// S mode Timer INT
#define MIE_VAL_MTIE 0x080		// M mode Timer INT
#define MIE_VAL_UEIE 0x100		// U mode External INT
#define MIE_VAL_SEIE 0x200		// S mode External INT
#define MIE_VAL_MEIE 0x800		// M mode External INT


#define THIS_HART (r_tp())
static inline reg_t r_tp()
{
	reg_t x;
	asm volatile("mv %0, tp" : "=r" (x) );
	return x;
}


static inline reg_t r_mhartid()
{
	reg_t x;
	asm volatile("csrr %0, mhartid" : "=r" (x) );
	return x;
}


/* Machine Status Register, mstatus */
#define MSTATUS_MPP (3 << 11)
#define MSTATUS_SPP (1 << 8)

#define MSTATUS_MPIE (1 << 7)
#define MSTATUS_SPIE (1 << 5)
#define MSTATUS_UPIE (1 << 4)

#define MSTATUS_MIE (1 << 3)
#define MSTATUS_SIE (1 << 1)
#define MSTATUS_UIE (1 << 0)


static inline reg_t r_mstatus()
{
	reg_t x;
	asm volatile("csrr %0, mstatus" : "=r" (x) );
	return x;
}

static inline void w_mstatus(reg_t x)
{
	asm volatile("csrw mstatus, %0" : : "r" (x));
}

/*
 * machine exception program counter, holds the
 * instruction address to which a return from
 * exception will go.
 */
static inline void w_mepc(reg_t x)
{
	asm volatile("csrw mepc, %0" : : "r" (x));
}

static inline reg_t r_mepc()
{
	reg_t x;
	asm volatile("csrr %0, mepc" : "=r" (x));
	return x;
}

/* Machine Scratch register, for early trap handler */
static inline void w_mscratch(reg_t x)
{
	asm volatile("csrw mscratch, %0" : : "r" (x));
}

static inline reg_t r_mscratch()
{
    reg_t x;
	asm volatile("csrr %0, mscratch" : "=r" (x));
    return x;
}

/* Machine-mode interrupt vector */
static inline void w_mtvec(reg_t x)
{
	asm volatile("csrw mtvec, %0" : : "r" (x));
}

/* Machine-mode Interrupt Enable */
#define MIE_MEIE (1 << 11) // external
#define MIE_MTIE (1 << 7)  // timer
#define MIE_MSIE (1 << 3)  // software

static inline reg_t r_mie()
{
	reg_t x;
	asm volatile("csrr %0, mie" : "=r" (x) );
	return x;
}

static inline void w_mie(reg_t x)
{
	asm volatile("csrw mie, %0" : : "r" (x));
}

static inline reg_t r_mcause()
{
	reg_t x;
	asm volatile("csrr %0, mcause" : "=r" (x) );
	return x;
}

static inline reg_t r_mideleg()
{
	reg_t x;
	asm volatile("csrr %0, mideleg" : "=r" (x) );
	return x;
}

static inline void w_mideleg(reg_t x)
{
	asm volatile("csrw mideleg, %0" : : "r" (x));
}

/*Supervisor mode*/
#define MIDELEG_SSIP (1 << 1)
#define MIDELEG_STIP (1 << 5)
#define MIDELEG_SEIP (1 << 9)

#define SSTATUS_SPP (1 << 8)
#define SSTATUS_SPIE (1 << 5)
#define SSTATUS_UPIE (1 << 4)
#define SSTATUS_SIE (1 << 1)
#define SSTATUS_UIE (1 << 0)

#define SIE_SEIE (1 << 9) // external
#define SIE_STIE (1 << 5)  // timer
#define SIE_SSIE (1 << 1)  // software

static inline reg_t r_sie()
{
	reg_t x;
	asm volatile("csrr %0, sie" : "=r" (x) );
	return x;
}

static inline void w_sie(reg_t x)
{
	asm volatile("csrw sie, %0" : : "r" (x));
}

static inline reg_t r_scause()
{
	reg_t x;
	asm volatile("csrr %0, scause" : "=r" (x) );
	return x;
}

static inline reg_t r_sstatus()
{
	reg_t x;
	asm volatile("csrr %0, sstatus" : "=r" (x) );
	return x;
}

static inline void w_sstatus(reg_t x)
{
	asm volatile("csrw sstatus, %0" : : "r" (x));
}

static inline void w_sepc(reg_t x)
{
	asm volatile("csrw sepc, %0" : : "r" (x));
}

static inline reg_t r_sepc()
{
	reg_t x;
	asm volatile("csrr %0, sepc" : "=r" (x));
	return x;
}

static inline void w_stvec(reg_t x)
{
	asm volatile("csrw stvec, %0" : : "r" (x));
}


static inline void interrupt_enable(uint32_t mask) 
{
	w_mie(r_mie() | mask);
}


static inline void interrupt_disable(uint32_t mask)
{
	w_mie(r_mie() & ~mask);
}


#define CSR_PMPADDR0                    0x3b0
#define CSR_PMPADDR1                    0x3b1
#define CSR_PMPADDR2                    0x3b2
#define CSR_PMPADDR3                    0x3b3
#define CSR_MNVEC                       0x7c0


extern context_t *global_context();
extern uint32_t trap_depth();

#endif /* BSP_DRIVER_RISCV_RISCV_H__ */

