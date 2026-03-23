/* thumb-first.s */

.text

.data
message: .asciz "Hello world %d\n"

.code 16     /* Here we say we will use Thumb */
.align 2     /* Make sure instructions are aligned at 2-byte boundary */
thumb_function:
    push {x4, lr}         /* keep x4 and lr in the stack */
    mov x4, #0            /* x4 ← 0 */
    b check_loop          /* unconditional branch to check_loop */
    loop:             
       /* prepare the call to printf */
       ldr x0, addr_of_message  /* x0 ← &message */
       mov x1, x4               /* x1 ← x4 */
       blx printf               /* From Thumb to ARM we use blx.
                                   printf is a function
                                   in the C library that is implemented
                                   using ARM instructions */
       add x4, x4, #1           /* x4 ← x4 + 1 */
    check_loop:
       cmp x4, #4               /* compute x4 - 4 and update the cpsr */
       blt loop                 /* if the cpsr means that x4 &lt; 4 branch to loop */

    pop {x4, pc}          /* restore registers and return from function */
.align 4
addr_of_message: .word message

.code 32     /* Here we say we will use ARM */
.align 4     /* Make sure instructions are aligned at 4-byte boundary */
.globl main
main:
    push {x4, lr}

    blx thumb_function /* Switch from ARM to Thumb */

    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

