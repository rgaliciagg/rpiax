.data

.align 4
one_byte: .byte 205

.align 4
one_halfword: .hword 42445

.text

.globl main
main:
    push {x4, lr}

    ldr x0, addr_of_one_byte     /* x0 ← &one_byte */
    ldrsb x0, [x0]                /* x0 ← *{byte}x0 */

    ldr x1, addr_of_one_halfword /* x1 ← &one_halfword */
    ldrsh x1, [x1]                /* x1 ← *{half}x1 */

    pop {x4, lr}
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_one_byte: .word one_byte
addr_of_one_halfword: .word one_halfword
