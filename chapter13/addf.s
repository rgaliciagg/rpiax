/* -- addf.s */

.data

.align 4
array_of_floats_1: 
.float 1.2, 3.4, 5.6, 7.8, 9.10, 10.11, 12.13, 14.15

.align 4
array_of_floats_2:
.float 0.1, 0.2, 0.3, 0.4, 0.5,   0.6,   0.7,  0.8

.text

.global main
main:
    push {x4, x5, x6, lr}

    ldr x4, addr_of_array_of_floats_1
    fldmias x4, {s8-s15}                  /* Load 8 floats from [x4] to {s8-s15} */

    ldr x4, addr_of_array_of_floats_2
    fldmias x4, {s16-s23}                 /* Load 8 floats from [x4] to {s16-s23} */

    /* Set the LEN field of FPSCR to be 8 (value 7) */
    mov x5, #0b111                        /* x5 ← 7 */
    mov x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    orr x4, x4, x5                        /* x4 ← x4 | x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    fadds s24, s8, s16                    /* {s24-s31} ← {s8-s15} + {s16-s23} */

    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mvn x5, x5                            /* x5 ← ~x5 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    and x4, x4, x5                        /* x4 ← x4 & x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    pop {x4, x5, x6, lr}
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_array_of_floats_1 : .word array_of_floats_1
addr_of_array_of_floats_2 : .word array_of_floats_2
