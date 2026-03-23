/* -- sum02.s */
.global main

main:
    mov x0, #3
    mov x1, #4
    add x0, x0, x1  /* x0 ← x1 + x2 */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


