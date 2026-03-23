/* -- mult64.s */
.data

.align 8
message : .asciz "Multiplication of %lld by %lld is %lld\n"

.align 4
number_a_low: .word 3755744309
number_a_high: .word 2

number_b_low: .word 12345678
number_b_high: .word 0

.text

mult64:
   /* The argument will be passed in x0, x1 and x2, x3 and returned in x0, x1 */
   /* Keep the registers that we are going to write */
   push {x4, x5, x6, x7, x8, lr}
   /* For covenience, mov x0,x1 into x4,x5 */
   mov x4, x0   /* x0 ← x4 */
   mov x5, x1   /* x5 ← x1 */

   umull x0, x6, x2, x4    /* x0,x6 ← x2 * x4 */
   umull x7, x8, x3, x4    /* x7,x8 ← x3 * x4 */
   umull x4, x5, x2, x5    /* x4,x5 ← x2 * x5 */
   adds x2, x7, x4         /* x2 ← x7 + x4 and update cpsr */
   adc x1, x2, x6          /* x1 ← x2 + x6 + C */

   /* Restore registers */
   pop {x4, x5, x6, x7, x8, lr}
   
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                   /* Leave mult64 */

mult64_2:
   /* The argument will be passed in x0, x1 and x2, x3 and returned in x0, x1 */
   /* Keep the registers that we are going to write */
   push {x4, x5, x6, lr}

   /* For convenience, mov x0,x1 into x4,x5 */
   mov x4, x0   /* x0 ← x4 */
   mov x5, x1   /* x5 ← x1 */
   umull x0, x1, x2, x4    /* x0,x1 ← x2 * x4 */
   umlal x1, x6, x3, x4    /* x1 ← x1 + LO(x3*x4). x6 ← x6 + HI(x3*x4) */
   umlal x1, x6, x2, x5    /* x1 ← x1 + LO(x4*x3). x6 ← x6 + HI(x2*x5) */

   /* Restore registers */
   pop {x4, x5, x6, lr}
   
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


.global main
main:
    push {x4, x5, x6, x7, x8, lr}       /* Keep the registers we are going to modify */
    /* We have to load the number from memory because the literal value would
       not fit the instruction */
    ldr x4, addr_number_a_low       /* x4 ← &a_low  */
    ldr x4, [x4]                    /* x4 ← *x4 */
    ldr x5, addr_number_a_high      /* x5 ← &a_high  */
    ldr x5, [x5]                    /* x5 ← *x5 */

    ldr x6, addr_number_b_low       /* x6 ← &b_low  */
    ldr x6, [x6]                    /* x6 ← *x6 */
    ldr x7, addr_number_b_high      /* x7 ← &b_high  */
    ldr x7, [x7]                    /* x7 ← *x7 */

    /* Now prepare the call to mult64
    /* 
       The first number is passed in 
       registers x0,x1 and the second one in x2,x3
       Note that we pass 32-bit numbers, this is why
       the higher register will be zero
    */
    mov x0, x4                  /* x0 ← x4 */
    mov x1, x5                  /* x1 ← x5 */

    mov x2, x6                  /* x2 ← x6 */
    mov x3, x7                  /* x3 ← x7 */

    bl mult64                  /* call mult64 function */
    /* The result of the multiplication is in x0,x1 */
    
    /* Now prepare the call to printf */
    /* We have to pass &message, {x4,x5}, {x6,x7} and {x0,x1} */
#    push {x1}                   /* Push x1 onto the stack. 7th parameter */
#    push {x0}                   /* Push x0 onto the stack. 6th parameter */
#    push {x7}                   /* Push x7 onto the stack. 5th parameter */
#    push {x6}                   /* Push x6 onto the stack. 4th parameter */
    push {x0,x1}
    push {x6,x7}
    mov x3, x5                  /* x3 ← x5.                3rd parameter */
    mov x2, x4                  /* x2 ← x4.                2nd parameter */
    ldr x0, addr_of_message     /* x0 ← &message           1st parameter */
    bl printf                   /* Call printf */
    add sp, sp, #16             /* sp ← sp + 16 */
                                /* Pop the two registers we pushed above */

    mov x0, #0                  /* x0 ← 0 */
    pop {x4, x5, x6, x7, x8, lr}        /* Restore registers we kept */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                       /* Leave main */

addr_of_message : .word message
addr_number_a_low: .word number_a_low
addr_number_a_high: .word number_a_high

addr_number_b_low: .word number_b_low
addr_number_b_high: .word number_b_high
