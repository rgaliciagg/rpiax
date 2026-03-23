/* first_pointer.s */

.data

.align 4
number_1  : .word 3

.text
.globl main


main:
    ldr x0, pointer_to_number
    ldr x0, [x0]

    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


pointer_to_number: .word number_1
