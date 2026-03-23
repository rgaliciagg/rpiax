/* write_c.s */

.data


greeting: .asciz "Hello world\n"
after_greeting:

.set size_of_greeting, after_greeting - greeting

.text

.globl main

main:
    push {x4, lr}
    mov x0, #1
    ldr x1, addr_of_greeting
    mov x2, #size_of_greeting
    bl write

    mov x0, #0

    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_greeting : .word greeting
