# byte_array_add.s

naive_byte_array_addition:
    /* x0 contains the base address of a */
    /* x1 contains the base address of b */
    /* x2 contains the base address of c */
    /* x3 is N */
    /* x4 is the number of the current item
          so it holds that 0 ≤ x4 < x3 */

    mov x4, #0             /* x4 ← 0 */
    b .Lcheck_loop0        /* branch to check_loop0 */

    .Lloop0:
      ldrb x5, [x0, x4]    /* x5 ← *{unsigned byte}(x0 + x4) */
      ldrb x6, [x1, x4]    /* x6 ← *{unsigned byte}(x1 + x4) */
      add x7, x5, x6       /* x7 ← x5 + x6 */
      strb x7, [x2, x4]    /* *{unsigned byte}(x2 + x4) ← x7 */
      add x4, x4, #1       /* x4 ← x4 + 1 */
    .Lcheck_loop0:
       cmp x4, x3          /* perform x4 - x3 and update cpsr */
       blt .Lloop0         /* if cpsr means that x4 < x3 jump to loop0 */

simd_byte_array_addition_0:
    /* x0 contains the base address of a */
    /* x1 contains the base address of b */
    /* x2 contains the base address of c */
    /* x3 is N */
    /* x4 is the number of the current item
          so it holds that 0 ≤ x4 < x3 */

    mov x4, #0             /* x4 ← 0 */
    b .Lcheck_loop1        /* branch to check_loop1 */

    .Lloop1:
      ldr x5, [x0, x4]     /* x5 ← *(x0 + x4) */
      ldr x6, [x1, x4]     /* x6 ← *(x1 + x4) */
      sadd8 x7, x5, x6     /* x7[7:0] ← x5[7:0] + x6[7:0] */
                           /* x7[15:8] ← x5[15:8] + x6[15:8] */
                           /* x7[23:16] ← x5[23:16] + x6[23:16] */
                           /* x7[31:24] ← x5[31:24] + x6[31:24] */
                           /* x7[x:y] means bits x to y of the register x7 */
      str x7, [x2, x4]     /* *(x2 + x4) ← x7 */
      add x4, x4, #4       /* x4 ← x4 + 4 */
    .Lcheck_loop1:
       cmp x4, x3          /* perform x4 - x3 and update cpsr */
       blt .Lloop1         /* if cpsr means that x4 < x3 jump to loop1 */
     
simd_byte_array_addition_1:
    /* x0 contains the base address of a */
    /* x1 contains the base address of b */
    /* x2 contains the base address of c */
    /* x3 is N */
    /* x4 is the number of the current item
          so it holds that 0 ≤ x4 < x3 */

    mov x4, #0             /* x4 ← 0 */
    sub x8, x3, #3         /* x8 ← x3 - 3
                              this is x8 ← N - 3 */
    b .Lcheck_loop2        /* branch to check_loop2 */

    .Lloop2:
      ldr x5, [x0, x4]     /* x5 ← *(x0 + x4) */
      ldr x6, [x1, x4]     /* x6 ← *(x1 + x4) */
      sadd8 x7, x5, x6     /* x7[7:0] ← x5[7:0] + x6[7:0] */
                           /* x7[15:8] ← x5[15:8] + x6[15:8] */
                           /* x7[23:16] ← x5[23:16] + x6[23:16] */
                           /* x7[31:24] ← x5[31:24] + x6[31:24] */
      str x7, [x2, x4]     /* *(x2 + x4) ← x7 */
      add x4, x4, #4       /* x4 ← x4 + 4 */
    .Lcheck_loop2:
       cmp x4, x8          /* perform x4 - x8 and update cpsr */
       blt .Lloop2         /* if cpsr means that x4 < x8 jump to loop2 */
                           /* i.e. if x4 < N - 3 jump to loop2 */

     /* epilog loop */
     b .Lcheck_loop3       /* branch to check_loop3 */
 
     .Lloop3: 
        ldrb x5, [x0, x4]  /* x5 ← *{unsigned byte}(x0 + x4) */
        ldrb x6, [x1, x4]  /* x6 ← *{unsigned byte}(x1 + x4) */
        add x7, x5, x6     /* x7 ← x5 + x6 */
        strb x7, [x2, x4]  /* *{unsigned byte}(x2 + x4) ← x7 */ 

        add x4, x4, #1     /* x4 ← x4 + 1 */
     .Lcheck_loop3:
        cmp x4, x3         /* perform x4 - x3 and update cpsr */
        blt .Lloop3        /* if cpsr means that x4 < x3 jump to loop 3 */

.global main
main:
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

