/* good_pointer.s */

.data

.align 4
number_1  : .word 3
number_2  : .word 4
pointer_to_number: .word 0

.text
.globl main


main:
    ldr x0, addr_of_pointer_to_number
                             /* x0 ← &pointer_to_number */

    ldr x1, addr_of_number_2 /* x1 ← &number_2 */

    str x1, [x0]             /* *x0 ← x1.
                                This is actually
                                  pointer_to_number ← &number_2 */

    ldr x1, [x0]             /* x1 ← *x0.
                                This is actually
                                  x1 ← pointer_to_number
                                Since pointer_to_number has the value &number_2
                                then this is like
                                  x1 ← &number_2
                             */
                               

    ldr x0, [x1]             /* x0 ← *x1
                                Since x1 had as value &number_2
                                then this is like
                                   x0 ← number_2
                             */

    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_pointer_to_number: .word pointer_to_number
addr_of_number_1: .word number_1
addr_of_number_2: .word number_2
