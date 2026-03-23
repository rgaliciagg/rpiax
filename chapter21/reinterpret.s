.data

.align 4
a_word: .word 0x11223344

.align 4
message_bytes : .asciz "byte #%d is 0x%x\n"
message_halfwords : .asciz "halfword #%d is 0x%x\n"
message_words : .asciz "word #%d is 0x%x\n"

.text

.globl main
main:
    push {x4, x5, x6, lr}  /* keep callee saved registers */

    ldr x4, addr_a_word    /* x4 ← &a_word */

    mov x5, #0             /* x5 ← 0 */
    b check_loop_bytes     /* branch to check_loop_bytes */

    loop_bytes:
        /* prepare call to printf */
        ldr x0, addr_message_bytes
                           /* x0 ← &message_bytes
                              first parameter of printf */
        mov x1, x5         /* x1 ← x5
                              second parameter of printf */
        ldrb x2, [x4, x5]  /* x2 ← *{byte}(x4 + x5)
                              third parameter of printf */
        bl printf          /* call printf */
        add x5, x5, #1     /* x5 ← x5 + 1 */
    check_loop_bytes:
        cmp x5, #4         /* compute x5 - 4 and update cpsr */
        bne loop_bytes     /* if x5 != 4 branch to loop_bytes */

    mov x5, #0             /* x5 ← 0 */
    b check_loop_halfwords /* branch to check_loop_halfwords */

    loop_halfwords:
        /* prepare call to printf */
        ldr x0, addr_message_halfwords
                           /* x0 ← &message_halfwords
                              first parameter of printf */
        mov x1, x5         /* x1 ← x5
                              second parameter of printf */
        mov x6, x5, LSL #1 /* x6 ← x5 * 2 */
        ldrh x2, [x4, x6]  /* x2 ← *{half}(x4 + x6)
                              this is x2 ← *{half}(x4 + x5 * 2)
                              third parameter of printf */
        bl printf          /* call printf */
        add x5, x5, #1     /* x5 ← x5 + 1 */
    check_loop_halfwords:
        cmp x5, #2         /* compute x5 - 2 and update cpsr */
        bne loop_halfwords /* if x5 != 2 branch to loop_halfwords */

    /* prepare call to printf */
    ldr x0, addr_message_words /* x0 ← &message_words
                                  first parameter of printf */
    mov x1, #0                 /* x1 ← 0
                                  second parameter of printf */
    ldr x2, [x4]               /* x1 ← *x4
                                  third parameter of printf */
    bl printf                  /* call printf */

    pop {x4, x5, x6, lr}   /* restore callee saved registers */
    mov x0, #0             /* set error code */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                  /* return to system */

addr_a_word : .word a_word
addr_message_bytes : .word message_bytes
addr_message_halfwords : .word message_halfwords
addr_message_words : .word message_words
