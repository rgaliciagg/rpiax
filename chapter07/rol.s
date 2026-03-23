/* -- rol.s */

.data

.balign 4
value: 
.int 0x12345678

.global main
.text
main:
    ldr x1, .Lcvalue
    ldr x1, [x1]
    mov x1, x1, ROL #1
    mov x1, x1, ROL #31

    eor x0, x0, x0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

.Lcvalue: .word value
