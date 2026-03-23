/* -- branch01.s */

.text
.global main
main:
case_a:
    mov x0, #2
    b end
case_b :
    mov x0, #3
end:
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

