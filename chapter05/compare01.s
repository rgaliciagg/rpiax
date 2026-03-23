/* -- compare01.s */

.text
.global main
main:
    mov x1, #2       /* x1 ← 2 */
    mov x2, #2       /* x2 ← 2 */
    cmp x1, x2       /* x1 ← x2 */
    beq case_equal   /* branch to case_equal if Z = 1 */
case_different :
    mov x0, #2       /* x0 ← 2 */
    b end            /* branch to end */
case_equal:
    mov x0, #1       /* x0 ← 1 */
end:
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

