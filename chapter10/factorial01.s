/* -- factorial01.s */
.data

message1: .asciz "Type a number: "
format:   .asciz "%d"
message2: .asciz "The factorial of %d is %d\n"

.text

factorial:
    str lr, [sp,#-4]!  /* Push lr onto the top of the stack */
    str x0, [sp,#-4]!  /* Push x0 onto the top of the stack */

    cmp x0, #0         /* compare x0 and 0 */
    bne is_nonzero     /* if x0 != 0 then branch */
    mov x0, #1         /* x0 ← 1. This is the return */
    b end
is_nonzero:
                       /* Prepare the call to factorial(n-1) */
    sub x0, x0, #1     /* x0 ← x0 - 1 */
    bl factorial
                       /* After the call x0 contains factorial(n-1) */
                       /* Load x0 (that we kept in th stack) into x1 */
    ldr x1, [sp]       /* x1 ← *sp */
    mul x0, x0, x1     /* x0 ← x0 * x1 */
    
end:
    add sp, sp, #+4    /* Discard the x0 we kept in the stack */
    ldr lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
              /* Leave factorial */

.globl main
main:
    str lr, [sp,#-4]!            /* Push lr onto the top of the stack */
    sub sp, sp, #4               /* Make room for one 4 byte integer in the stack */
                                 /* In these 4 bytes we will keep the number entered by */
                                 /* the user */

    ldr x0, address_of_message1  /* Set &message1 as the first parameter of printf */
    bl printf                    /* Call printf */

    ldr x0, address_of_format    /* Set &format as the first parameter of scanf */
    mov x1, sp                   /* Set the top of the stack as the second parameter */
                                 /* of scanf */
    bl scanf                     /* Call scanf */

    ldr x0, [sp]                 /* Load the integer read by scanf into x0 */
                                 /* So we set it as the first parameter of factorial */
    bl factorial                 /* Call factorial */

    mov x2, x0                   /* Get the result of factorial and move it to x2 */
                                 /* So we set it as the third parameter of printf */
    ldr x1, [sp]                 /* Load the integer read by scanf into x1 */
                                 /* So we set it as the second parameter of printf */
    ldr x0, address_of_message2  /* Set &message2 as the first parameter of printf */
    bl printf                    /* Call printf */


    add sp, sp, #+4              /* Discard the integer read by scanf */
    ldr lr, [sp], #+4            /* Pop the top of the stack and put it in lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                        /* Leave main */

address_of_message1: .word message1
address_of_message2: .word message2
address_of_format: .word format
