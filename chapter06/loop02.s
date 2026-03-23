/* -- loop02.s */

.text
.global main
main:
    mov x1, #0       /* x1 ← 0 */
    mov x2, #1       /* x2 ← 1 */
    b check_loop     /* unconditionally jump at the end of the loop */
loop: 
    add x1, x1, x2   /* x1 ← x1 + x1 */
    add x2, x2, #1   /* x2 ← x2 + 1 */
check_loop:
    cmp x2, #22      /* compare x2 and 22 */
    ble loop         /* branch if x2 &lt;= 22 to the beginning of the loop */
end:
    mov x0, x1       /* x0 ← x1 */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

