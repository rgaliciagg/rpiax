/* -- loop01.s */

.text
.global main
main:
    mov x1, #0       /* x1 ← 0 */
    mov x2, #1       /* x2 ← 1 */
loop: 
    cmp x2, #22      /* compare x2 and 22 */
    bgt end          /* branch if x2 > 22 to end */
    add x1, x1, x2   /* x1 ← x1 + x1 */
    add x2, x2, #1   /* x2 ← x2 + 1 */
    b loop
end:
    mov x0, x1       /* x0 ← x1 */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

