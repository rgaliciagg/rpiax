/* -- hello01.s */
.data

greeting: 
 .asciz "Hello world"

.balign 4
return: .word 0

.text

.global main
main:
    ldr x1, address_of_return     /*   x1 ← &address_of_return */
    str lr, [x1]                  /*   *x1 ← lr */

    ldr x0, address_of_greeting   /* x0 ← &address_of_greeting */
                                  /* First parameter of puts */

    bl puts                       /* Call to puts */
                                  /* lr ← address of next instruction */

    ldr x1, address_of_return     /* x1 ← &address_of_return */
    ldr lr, [x1]                  /* lr ← *x1 */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                         /* return from main */

address_of_greeting: .word greeting
address_of_return: .word return

/* External */
.global puts
