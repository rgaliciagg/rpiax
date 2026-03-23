# motivation.s

naive_channel_mixing:
    /* x0 contains the base address of channel1 */
    /* x1 contains the base address of channel2 */
    /* x2 contains the base address of channel_out */
    /* x3 is the number of samples */
    /* x4 is the number of the current sample
          so it holds that 0 ≤ x4 < x3 */

    mov x4, #0              /* x4 ← 0 */
    b .Lcheck_loop          /* branch to check_loop */
    .Lloop:
      mov x5, x4, LSL #1    /* x5 ← x4 << 1 (this is x5 ← x4 * 2) */
                            /* a halfword takes two bytes, so multiply
                               the index by two. We do this here because
                               ldrsh does not allow an addressing mode
                               like [x0, x5, LSL #1] */
      ldrsh x6, [x0, x5]    /* x6 ← *{signed half}(x0 + x5) */
      ldrsh x7, [x1, x5]    /* x7 ← *{signed half}(x1 + x5) */
      add x8, x6, x7        /* x8 ← x6 + x7 */
      mov x8, x8, LSR #1    /* x8 ← x8 >> 1 (this is x8 ← x8 / 2)*/
      strh x8, [x2, x5]     /* *{half}(x2 + x5) ← x8 */
      add x4, x4, #1        /* x4 ← x4 + 1 */
    .Lcheck_loop:
      cmp x4, x3            /* compute x4 - x3 and update cpsr */
      blt .Lloop            /* if x4 < x3 jump to the
                               beginning of the loop */
      

better_channel_mixing:
    /* x0 contains the base address of channel1 */
    /* x1 contains the base address of channel2 */
    /* x2 contains the base address of channel_out */
    /* x3 is the number of samples */
    /* x4 is the number of the current sample
          so it holds that 0 ≤ x4 < x3 */

    mov x4, #0              /* x4 ← 0 */
    b .Lcheck_loop1          /* branch to check_loop */
    .Lloop1:
      ldr x6, [x0, x4]      /* x6 ← *(x0 + x4) */
      ldr x7, [x1, x4]      /* x7 ← *(x1 + x4) */
      shadd16 x8, x6, x7    /* x8[15:0] ← (x6[15:0] + x7[15:0]) >> 1*/
                            /* x8[31:16] ← (x6[31:16] + x7[31:16]) >> 1*/
      str x8, [x2, x4]      /* *(x2 + x4) ← x8 */
      add x4, x4, #2        /* x4 ← x4 + 2 */
    .Lcheck_loop1:
      cmp x4, x3            /* compute x4 - x3 and update cpsr */
      blt .Lloop1            /* if x4 < x3 jump to the
                               beginning of the loop */

.global main
main:
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

