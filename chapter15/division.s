/* division.s */

.data

.text

.globl main

unsigned_naive_longdiv:
    /* x0 contains N */
    /* x1 contains D */
    mov x2, x1             /* x2 ← x0. We keep D in x2 */
    mov x1, x0             /* x1 ← x0. We keep N in x1 */

    mov x0, #0             /* x0 ← 0. Set Q = 0 initially */

    b .Lloop_check0
    .Lloop0:
       add x0, x0, #1      /* x0 ← x0 + 1. Q = Q + 1 */
       sub x1, x1, x2      /* x1 ← x1 - x2 */
    .Lloop_check0:
       cmp x1, x2          /* compute x1 - x2 and update cpsr */
       bhs .Lloop0         /* branch if x1 >= x2 (C=0 or Z=1) */

    /* x0 already contains Q */
    /* x1 already contains R */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


unsigned_longdiv:
    /* x0 contains N */
    /* x1 contains D */
    /* x2 contains Q */
    /* x3 contains R */
    push {x4, lr}
    mov x2, #0                 /* x2 ← 0 */
    mov x3, #0                 /* x3 ← 0 */

    mov x4, #32                /* x4 ← 32 */
    b .Lloop_check1
    .Lloop1:
        movs x0, x0, LSL #1    /* x0 ← x0 << 1 updating cpsr (sets C if 31st bit of x0 was 1) */
        adc x3, x3, x3         /* x3 ← x3 + x3 + C. This is equivalent to x3 ← (x3 << 1) + C */

        cmp x3, x1             /* compute x3 - x1 and update cpsr */
        subhs x3, x3, x1       /* if x3 >= x1 (C=1) then x3 ← x3 - x1 */
        adc x2, x2, x2         /* x2 ← x2 + x2 + C. This is equivalent to x2 ← (x2 << 1) + C */
    .Lloop_check1:
        subs x4, x4, #1        /* x4 ← x4 - 1 */
        bpl .Lloop1            /* if x4 >= 0 (N=0) then branch to .Lloop1 */

    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


better_unsigned_division :
    /* x0 contains N */
    /* x1 contains D */
    /* x2 contains Q */
    /* x3 tmp */

    mov x3, x1                 /* x3 ← x1 */
    cmp x3, x0, LSR #1         /* update cpsr with x3 - 2*x0 */
    .Lloop2:
    movls x3, x3, LSL #1       /* if x3 <= 2*x0 (C=0 or Z=1) then x3 ← 2*x3 */
    cmp x3, x0, LSR #1         /* update cpsr with x3 - 2*x0 */
    bls .Lloop2                /* branch to .Lloop2 if x3 <= 2*x0 (C=0 or Z=1) */

    mov x2, #0                 /* x2 ← 0 */

    .Lloop3:
    cmp x0, x3                 /* update cpsr with x0 - x3 */
    subhs x0, x0, x3           /* if x0 >= x3 then x0 ← x0 - x3 */
    adc x2, x2, x2             /* x2 ← x2 + x2 + C (if x0 >= x3 then C = 1 else C = 0) */

    mov x3, x3, LSR #1         /* x3 ← x3 >> 1 */
    cmp x3, x1                 /* update cpsr with x3 - x1 */
    bhs .Lloop3                /* if x3 >= x1 branch to .Lloop3 */
   
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


vfpv2_division:
    /* x0 contains N */
    /* x1 contains D */
    vmov s0, x0             /* s0 ← x0 (bit copy) */
    vmov s1, x1             /* s1 ← x1 (bit copy) */
    vcvt.f32.s32 s0, s0     /* s0 ← (float)s0 */
    vcvt.f32.s32 s1, s1     /* s1 ← (float)s1 */
    vdiv.f32 s0, s0, s1     /* s0 ← s0 / s1 */
    vcvt.s32.f32 s0, s0     /* s0 ← (int)s0 */
    vmov x0, s0             /* x0 ← s0 (bit copy). This is Q */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


    
main:
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

