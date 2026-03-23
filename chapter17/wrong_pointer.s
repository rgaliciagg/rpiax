/* wrong_pointer.s */

.data

.align 4
number_1  : .word 3
number_2  : .word 4

.text
.globl main

main:
    ldr x1, address_of_number_2  /* x1 ← &number_2 */
    str x1, pointer_to_number    /* pointer_to_number ← x1, this is pointer_to_number ← &number_2 */

    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


pointer_to_number: .word number_1
address_of_number_2: .word number_2
