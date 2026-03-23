/* write_sys.s */

.data


greeting: .asciz "Hello world\n"
after_greeting:

.set size_of_greeting, after_greeting - greeting

.text

.globl main

main:
    push {x4, lr}

    /* Prepare the system call */
    mov x0, #1                  /* x0 ← 1 */
    ldr x1, addr_of_greeting    /* x1 ← &greeting */
    mov x2, #size_of_greeting   /* x2 ← sizeof(greeting) */

    mov x7, #4                  /* select system call 'write' */
    swi #0                      /* perform the system call */

    mov x0, #0
    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_greeting : .word greeting
