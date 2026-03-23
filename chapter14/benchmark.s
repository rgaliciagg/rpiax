/* -- matmul.s */
.data
mat_A: .float 0.1, 0.2, 0.0, 0.1
       .float 0.2, 0.1, 0.3, 0.0
       .float 0.0, 0.3, 0.1, 0.5 
       .float 0.0, 0.6, 0.4, 0.1
mat_B: .float  4.92,  2.54, -0.63, -1.75
       .float  3.02, -1.51, -0.87,  1.35
       .float -4.29,  2.14,  0.71,  0.71
       .float -0.95,  0.48,  2.38, -0.95
mat_C: .float 0.0, 0.0, 0.0, 0.0
       .float 0.0, 0.0, 0.0, 0.0
       .float 0.0, 0.0, 0.0, 0.0
       .float 0.0, 0.0, 0.0, 0.0
       .float 0.0, 0.0, 0.0, 0.0

format_result : .asciz "Matrix result is:\n%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n"

.text

naive_matmul_4x4:
    /* x0 address of A
       x1 address of B
       x2 address of C
    */
    push {x4, x5, x6, x7, x8, lr} /* Keep integer registers */
    /* First zero 16 single floating point */
    /* In IEEE 754, all bits cleared means 0.0 */
    mov x4, x2
    mov x5, #16
    mov x6, #0
    b .L0_loop_init_test
    .L0_loop_init :
      str x6, [x4], +#4   /* *x4 ← x6 then x4 ← x4 + 4 */
    .L0_loop_init_test:
      subs x5, x5, #1
      bge .L0_loop_init

    /* We will use 
           x4 as i
           x5 as j
           x6 as k
    */
    mov x4, #0 /* x4 ← 0 */
    .L0_loop_i:  /* loop header of i */
      cmp x4, #4  /* if x4 == 4 goto end of the loop i */
      beq .L0_end_loop_i
      mov x5, #0  /* x5 ← 0 */
      .L0_loop_j: /* loop header of j */
       cmp x5, #4 /* if x5 == 4 goto end of the loop j */
        beq .L0_end_loop_j
        /* Compute the address of C[i][j] and load it into s0 */
        /* Address of C[i][j] is C + 4*(4 * i + j) */
        mov x7, x5               /* x7 ← x5. This is x7 ← j */
        adds x7, x7, x4, LSL #2  /* x7 ← x7 + (x4 << 2). 
                                    This is x7 ← j + i * 4.
                                    We multiply i by the row size (4 elements) */
        adds x7, x2, x7, LSL #2  /* x7 ← x2 + (x7 << 2).
                                    This is x7 ← C + 4*(j + i * 4)
                                    We multiply (j + i * 4) by the size of the element.
                                    A single-precision floating point takes 4 bytes.
                                    */
        vldr s0, [x7] /* s0 ← *x7 */

        mov x6, #0 /* x6 ← 0 */
        .L0_loop_k :  /* loop header of k */
          cmp x6, #4 /* if x6 == 4 goto end of the loop k */
          beq .L0_end_loop_k

          /* Compute the address of a[i][k] and load it into s1 */
          /* Address of a[i][k] is a + 4*(4 * i + k) */
          mov x8, x6               /* x8 ← x6. This is x8 ← k */
          adds x8, x8, x4, LSL #2  /* x8 ← x8 + (x4 << 2). This is x8 ← k + i * 4 */
          adds x8, x0, x8, LSL #2  /* x8 ← x0 + (x8 << 2). This is x8 ← a + 4*(k + i * 4) */
          vldr s1, [x8]            /* s1 ← *x8 */

          /* Compute the address of b[k][j] and load it into s2 */
          /* Address of b[k][j] is b + 4*(4 * k + j) */
          mov x8, x5               /* x8 ← x5. This is x8 ← j */
          adds x8, x8, x6, LSL #2  /* x8 ← x8 + (x6 << 2). This is x8 ← j + k * 4 */
          adds x8, x1, x8, LSL #2  /* x8 ← x1 + (x8 << 2). This is x8 ← b + 4*(j + k * 4) */
          vldr s2, [x8]            /* s1 ← *x8 */

          vmul.f32 s3, s1, s2      /* s3 ← s1 * s2 */
          vadd.f32 s0, s0, s3      /* s0 ← s0 + s3 */

          add x6, x6, #1           /* x6 ← x6 + 1 */
          b .L0_loop_k               /* next iteration of loop k */
        .L0_end_loop_k: /* Here ends loop k */
        vstr s0, [x7]            /* Store s0 back to C[i][j] */
        add x5, x5, #1  /* x5 ← x5 + 1 */
        b .L0_loop_j /* next iteration of loop j */
       .L0_end_loop_j: /* Here ends loop j */
       add x4, x4, #1 /* x4 ← x4 + 1 */
       b .L0_loop_i     /* next iteration of loop i */
    .L0_end_loop_i: /* Here ends loop i */

    pop {x4, x5, x6, x7, x8, lr}  /* Restore integer registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* Leave function */

naive_vectorial_matmul_4x4:
    /* x0 address of A
       x1 address of B
       x2 address of C
    */
    push {x4, x5, x6, x7, x8, lr} /* Keep integer registers */
    vpush {s16-s19}               /* Floating point registers starting from s16 must be preserved */
    vpush {s24-s27}
    /* First zero 16 single floating point */
    /* In IEEE 754, all bits cleared means 0 */
    mov x4, x2
    mov x5, #16
    mov x6, #0
    b .L1_loop_init_test
    .L1_loop_init :
      str x6, [x4], +#4   /* *x4 ← x6 then x4 ← x4 + 4 */
    .L1_loop_init_test:
      subs x5, x5, #1
      bge .L1_loop_init

    /* Set the LEN field of FPSCR to be 4 (value 3) */
    mov x5, #0b011                        /* x5 ← 3 */
    mov x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    orr x4, x4, x5                        /* x4 ← x4 | x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    /* We will use 
           x4 as i
           x5 as j
    */
    mov x4, #0 /* x4 ← 0 */
    .L1_loop_i:  /* loop header of i */
      cmp x4, #4  /* if x4 == 4 goto end of the loop i */
      beq .L1_end_loop_i
      mov x5, #0  /* x5 ← 0 */
      .L1_loop_j: /* loop header of j */
       cmp x5, #4 /* if x5 == 4 goto end of the loop j */
        beq .L1_end_loop_j
        /* Compute the address of C[i][j] and load it into s0 */
        /* Address of C[i][j] is C + 4*(4 * i + j) */
        mov x7, x5               /* x7 ← x5. This is x7 ← j */
        adds x7, x7, x4, LSL #2  /* x7 ← x7 + (x4 << 2). 
                                    This is x7 ← j + i * 4.
                                    We multiply i by the row size (4 elements) */
        adds x7, x2, x7, LSL #2  /* x7 ← x2 + (x7 << 2).
                                    This is x7 ← C + 4*(j + i * 4)
                                    We multiply (j + i * 4) by the size of the element.
                                    A single-precision floating point takes 4 bytes.
                                    */
        /* Compute the address of a[i][0] */
        mov x8, x4, LSL #2
        adds x8, x0, x8, LSL #2
        vldmia x8, {s8-s11}  /* Load {s8,s9,s10,s11} ← {a[i][0], a[i][1], a[i][2], a[i][3]} */

        /* Compute the address of b[0][j] */
        mov x8, x5               /* x8 ← x5. This is x8 ← j */
        adds x8, x1, x8, LSL #2  /* x8 ← x1 + (x8 << 2). This is x8 ← b + 4*(j) */
        vldr s16, [x8]             /* s16 ← *x8. This is s16 ← b[0][j] */
        vldr s17, [x8, #16]        /* s17 ← *(x8 + 16). This is s17 ← b[1][j] */
        vldr s18, [x8, #32]        /* s18 ← *(x8 + 32). This is s17 ← b[2][j] */
        vldr s19, [x8, #48]        /* s19 ← *(x8 + 48). This is s17 ← b[3][j] */

        vmul.f32 s24, s8, s16      /* {s24,s25,s26,s27} ← {s8,s9,s10,s11} * {s16,s17,s18,s19} */
        vmov.f32 s0, s24           /* s0 ← s24 */
        vadd.f32 s0, s0, s25       /* s0 ← s0 + s25 */
        vadd.f32 s0, s0, s26       /* s0 ← s0 + s26 */
        vadd.f32 s0, s0, s27       /* s0 ← s0 + s27 */

        vstr s0, [x7]            /* Store s0 back to C[i][j] */
        add x5, x5, #1  /* x5 ← x5 + 1 */
        b .L1_loop_j /* next iteration of loop j */
       .L1_end_loop_j: /* Here ends loop j */
       add x4, x4, #1 /* x4 ← x4 + 1 */
       b .L1_loop_i     /* next iteration of loop i */
    .L1_end_loop_i: /* Here ends loop i */

    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mov x5, #0b011                        /* x5 ← 3 */
    mvn x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    and x4, x4, x5                        /* x4 ← x4 & x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    vpop {s24-s27}                /* Restore preserved floating registers */
    vpop {s16-s19}
    pop {x4, x5, x6, x7, x8, lr}  /* Restore integer registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* Leave function */
    
naive_vectorial_matmul_2_4x4:
    /* x0 address of A
       x1 address of B
       x2 address of C
    */
    push {x4, x5, x6, x7, x8, lr} /* Keep integer registers */
    vpush {s16-s31}               /* Floating point registers starting from s16 must be preserved */
    /* First zero 16 single floating point */
    /* In IEEE 754, all bits cleared means 0 */
    mov x4, x2
    mov x5, #16
    mov x6, #0
    b .L2_loop_init_test
    .L2_loop_init :
      str x6, [x4], +#4   /* *x4 ← x6 then x4 ← x4 + 4 */
    .L2_loop_init_test:
      subs x5, x5, #1
      bge .L2_loop_init

    /* Set the LEN field of FPSCR to be 4 (value 3) */
    mov x5, #0b011                        /* x5 ← 3 */
    mov x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    orr x4, x4, x5                        /* x4 ← x4 | x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    /* We will use 
           x4 as i
           x5 as j
    */
    mov x4, #0 /* x4 ← 0 */
    .L2_loop_i:  /* loop header of i */
      cmp x4, #4  /* if x4 == 4 goto end of the loop i */
      beq .L2_end_loop_i
      mov x5, #0  /* x5 ← 0 */
      .L2_loop_j: /* loop header of j */
       cmp x5, #4 /* if x5 == 4 goto end of the loop j */
        beq .L2_end_loop_j
        /* Compute the address of C[i][j] and load it into s0 */
        /* Address of C[i][j] is C + 4*(4 * i + j) */
        mov x7, x5               /* x7 ← x5. This is x7 ← j */
        adds x7, x7, x4, LSL #2  /* x7 ← x7 + (x4 << 2). 
                                    This is x7 ← j + i * 4.
                                    We multiply i by the row size (4 elements) */
        adds x7, x2, x7, LSL #2  /* x7 ← x2 + (x7 << 2).
                                    This is x7 ← C + 4*(j + i * 4)
                                    We multiply (j + i * 4) by the size of the element.
                                    A single-precision floating point takes 4 bytes.
                                    */
        /* Compute the address of a[i][0] */
        mov x8, x4, LSL #2
        adds x8, x0, x8, LSL #2
        vldmia x8, {s8-s11}  /* Load {s8,s9,s10,s11} ← {a[i][0], a[i][1], a[i][2], a[i][3]} */

        /* Compute the address of b[0][j] */
        mov x8, x5               /* x8 ← x5. This is x8 ← j */
        adds x8, x1, x8, LSL #2  /* x8 ← x1 + (x8 << 2). This is x8 ← b + 4*(j) */
        vldr s16, [x8]             /* s16 ← *x8. This is s16 ← b[0][j] */
        vldr s17, [x8, #16]        /* s17 ← *(x8 + 16). This is s17 ← b[1][j] */
        vldr s18, [x8, #32]        /* s18 ← *(x8 + 32). This is s17 ← b[2][j] */
        vldr s19, [x8, #48]        /* s19 ← *(x8 + 48). This is s17 ← b[3][j] */

        /* Compute the address of b[0][j+1] */
        add x8, x5, #1             /* x8 ← x5 + 1. This is x8 ← j + 1*/
        adds x8, x1, x8, LSL #2    /* x8 ← x1 + (x8 << 2). This is x8 ← b + 4*(j + 1) */
        vldr s20, [x8]             /* s20 ← *x8. This is s20 ← b[0][j + 1] */
        vldr s21, [x8, #16]        /* s21 ← *(x8 + 16). This is s21 ← b[1][j + 1] */
        vldr s22, [x8, #32]        /* s22 ← *(x8 + 32). This is s22 ← b[2][j + 1] */
        vldr s23, [x8, #48]        /* s23 ← *(x8 + 48). This is s23 ← b[3][j + 1] */

        vmul.f32 s24, s8, s16      /* {s24,s25,s26,s27} ← {s8,s9,s10,s11} * {s16,s17,s18,s19} */
        vmov.f32 s0, s24           /* s0 ← s24 */
        vadd.f32 s0, s0, s25       /* s0 ← s0 + s25 */
        vadd.f32 s0, s0, s26       /* s0 ← s0 + s26 */
        vadd.f32 s0, s0, s27       /* s0 ← s0 + s27 */

        vmul.f32 s28, s8, s20      /* {s28,s29,s30,s31} ← {s8,s9,s10,s11} * {s20,s21,s22,s23} */

        vmov.f32 s1, s28           /* s1 ← s28 */
        vadd.f32 s1, s1, s29       /* s1 ← s1 + s29 */
        vadd.f32 s1, s1, s30       /* s1 ← s1 + s30 */
        vadd.f32 s1, s1, s31       /* s1 ← s1 + s31 */

        vstmia x7, {s0-s1}         /* {C[i][j], C[i][j+1]} ← {s0, s1} */

        add x5, x5, #2  /* x5 ← x5 + 2 */
        b .L2_loop_j /* next iteration of loop j */
       .L2_end_loop_j: /* Here ends loop j */
       add x4, x4, #1 /* x4 ← x4 + 1 */
       b .L2_loop_i     /* next iteration of loop i */
    .L2_end_loop_i: /* Here ends loop i */

    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mov x5, #0b011                        /* x5 ← 3 */
    mvn x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    and x4, x4, x5                        /* x4 ← x4 & x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    vpop {s16-s31}                /* Restore preserved floating registers */
    pop {x4, x5, x6, x7, x8, lr}  /* Restore integer registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* Leave function */

better_vectorial_matmul_4x4:
    /* x0 address of A
       x1 address of B
       x2 address of C
    */
    push {x4, x5, x6, x7, x8, lr} /* Keep integer registers */
    vpush {s16-s19}               /* Floating point registers starting from s16 must be preserved */
    vpush {s24-s27}
    /* First zero 16 single floating point */
    /* In IEEE 754, all bits cleared means 0 */
    mov x4, x2
    mov x5, #16
    mov x6, #0
    b .L3_loop_init_test
    .L3_loop_init :
      str x6, [x4], +#4   /* *x4 ← x6 then x4 ← x4 + 4 */
    .L3_loop_init_test:
      subs x5, x5, #1
      bge .L3_loop_init

    /* Set the LEN field of FPSCR to be 4 (value 3) */
    mov x5, #0b011                        /* x5 ← 3 */
    mov x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    orr x4, x4, x5                        /* x4 ← x4 | x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    /* We will use 
           x4 as k
           x5 as i
    */
    mov x4, #0 /* x4 ← 0 */
    .L3_loop_k:  /* loop header of k */
      cmp x4, #4  /* if x4 == 4 goto end of the loop k */
      beq .L3_end_loop_k
      mov x5, #0  /* x5 ← 0 */
      .L3_loop_i: /* loop header of i */
       cmp x5, #4 /* if x5 == 4 goto end of the loop i */
        beq .L3_end_loop_i
        /* Compute the address of C[i][0] */
        /* Address of C[i][0] is C + 4*(4 * i) */
        add x7, x2, x5, LSL #4         /* x7 ← x2 + (x5 << 4). This is x7 ← c + 4*4*i */
        vldmia x7, {s8-s11}            /* Load {s8,s9,s10,s11} ← {c[i][0], c[i][1], c[i][2], c[i][3]} */
        /* Compute the address of A[i][k] */
        /* Address of A[i][k] is A + 4*(4*i + k) */
        add x8, x4, x5, LSL #2         /* x8 ← x4 + x5 << 2. This is x8 ← k + 4*i */
        add x8, x0, x8, LSL #2         /* x8 ← x0 + x8 << 2. This is x8 ← a + 4*(k + 4*i) */
        vldr s0, [x8]                  /* Load s0 ← a[i][k] */

        /* Compute the address of B[k][0] */
        /* Address of B[k][0] is B + 4*(4*k) */
        add x8, x1, x4, LSL #4         /* x8 ← x1 + x4 << 4. This is x8 ← b + 4*(4*k) */
        vldmia x8, {s16-s19}           /* Load {s16,s17,s18,s19} ← {b[k][0], b[k][1], b[k][2], b[k][3]} */

        vmul.f32 s24, s16, s0          /* {s24,s25,s26,s27} ← {s16,s17,s18,s19} * {s0,s0,s0,s0} */
        vadd.f32 s8, s8, s24           /* {s8,s9,s10,s11} ← {s8,s9,s10,s11} + {s24,s25,s26,s7} */

        vstmia x7, {s8-s11}            /* Store {c[i][0],c[i][1],c[i][2],c[i][3]} ← {s8,s9,s10,s11} */

        add x5, x5, #1  /* x5 ← x5 + 1. This is i = i + 1 */
        b .L3_loop_i /* next iteration of loop i */
       .L3_end_loop_i: /* Here ends loop i */
       add x4, x4, #1 /* x4 ← x4 + 1. This is k = k + 1 */
       b .L3_loop_k     /* next iteration of loop k */
    .L3_end_loop_k: /* Here ends loop k */

    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mov x5, #0b011                        /* x5 ← 3 */
    mvn x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    and x4, x4, x5                        /* x4 ← x4 & x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    vpop {s24-s27}                /* Restore preserved floating registers */
    vpop {s16-s19}
    pop {x4, x5, x6, x7, x8, lr}  /* Restore integer registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* Leave function */

best_vectorial_matmul_4x4:
    /* x0 address of A
       x1 address of B
       x2 address of C
    */
    push {x4, x5, x6, x7, x8, lr} /* Keep integer registers */
    vpush {s16-s19}               /* Floating point registers starting from s16 must be preserved */

    /* First zero 16 single floating point */
    /* In IEEE 754, all bits cleared means 0 */
    mov x4, x2
    mov x5, #16
    mov x6, #0
    b .L4_loop_init_test
    .L4_loop_init :
      str x6, [x4], +#4   /* *x4 ← x6 then x4 ← x4 + 4 */
    .L4_loop_init_test:
      subs x5, x5, #1
      bge .L4_loop_init

    /* Set the LEN field of FPSCR to be 4 (value 3) */
    mov x5, #0b011                        /* x5 ← 3 */
    mov x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    orr x4, x4, x5                        /* x4 ← x4 | x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    /* We will use 
           x4 as k
           x5 as i
    */
    mov x4, #0 /* x4 ← 0 */
    .L4_loop_k:  /* loop header of k */
      cmp x4, #4  /* if x4 == 4 goto end of the loop k */
      beq .L4_end_loop_k
      mov x5, #0  /* x5 ← 0 */
      .L4_loop_i: /* loop header of i */
       cmp x5, #4 /* if x5 == 4 goto end of the loop i */
        beq .L4_end_loop_i
        /* Compute the address of C[i][0] */
        /* Address of C[i][0] is C + 4*(4 * i) */
        add x7, x2, x5, LSL #4         /* x7 ← x2 + (x5 << 4). This is x7 ← c + 4*4*i */
        vldmia x7, {s8-s15}            /* Load {s8,s9,s10,s11,s12,s13,s14,s15} 
                                            ← {c[i][0],   c[i][1],   c[i][2],   c[i][3]
                                               c[i+1][0], c[i+1][1], c[i+1][2], c[i+1][3]} */
        /* Compute the address of A[i][k] */
        /* Address of A[i][k] is A + 4*(4*i + k) */
        add x8, x4, x5, LSL #2         /* x8 ← x4 + x5 << 2. This is x8 ← k + 4*i */
        add x8, x0, x8, LSL #2         /* x8 ← x0 + x8 << 2. This is x8 ← a + 4*(k + 4*i) */
        vldr s0, [x8]                  /* Load s0 ← a[i][k] */
        vldr s1, [x8, #16]             /* Load s1 ← a[i+1][k] */

        /* Compute the address of B[k][0] */
        /* Address of B[k][0] is B + 4*(4*k) */
        add x8, x1, x4, LSL #4         /* x8 ← x1 + x4 << 4. This is x8 ← b + 4*(4*k) */
        vldmia x8, {s16-s19}           /* Load {s16,s17,s18,s19} ← {b[k][0], b[k][1], b[k][2], b[k][3]} */

        vmla.f32 s8, s16, s0           /* {s8,s9,s10,s11} ← {s8,s9,s10,s11} + ({s16,s17,s18,s19} * {s0,s0,s0,s0}) */
        vmla.f32 s12, s16, s1          /* {s12,s13,s14,s15} ← {s12,s13,s14,s15} + ({s16,s17,s18,s19} * {s1,s1,s1,s1}) */

        vstmia x7, {s8-s15}            /* Store {c[i][0],   c[i][1],   c[i][2],    c[i][3],
                                                 c[i+1][0], c[i+1][1], c[i+1][2]}, c[i+1][3] }
                                                ← {s8,s9,s10,s11,s12,s13,s14,s15} */

        add x5, x5, #2  /* x5 ← x5 + 2. This is i = i + 2 */
        b .L4_loop_i /* next iteration of loop i */
       .L4_end_loop_i: /* Here ends loop i */
       add x4, x4, #1 /* x4 ← x4 + 1. This is k = k + 1 */
       b .L4_loop_k     /* next iteration of loop k */
    .L4_end_loop_k: /* Here ends loop k */

    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mov x5, #0b011                        /* x5 ← 3 */
    mvn x5, x5, LSL #16                   /* x5 ← x5 << 16 */
    fmrx x4, fpscr                        /* x4 ← fpscr */
    and x4, x4, x5                        /* x4 ← x4 & x5 */
    fmxr fpscr, x4                        /* fpscr ← x4 */

    vpop {s16-s19}                /* Restore preserved floating registers */
    pop {x4, x5, x6, x7, x8, lr}  /* Restore integer registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* Leave function */

.globl main
main:
    push {x4, x5, x6, lr}  /* Keep integer registers */

    ldr x0, addr_mat_A  /* x0 ← a */
    ldr x1, addr_mat_B  /* x1 ← b */
    ldr x2, addr_mat_C  /* x2 ← c */
    mov x4, #1
    mov x4, x4, LSL #21
    .Lmain_loop_test: 
      bl best_vectorial_matmul_4x4
      subs x4, x4, #1
      bne .Lmain_loop_test /* Should have been 'bge' */

    mov x0, #0
    pop {x4, x5, x6, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_mat_A : .word mat_A
addr_mat_B : .word mat_B
addr_mat_C : .word mat_C
addr_format_result : .word format_result
