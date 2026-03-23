/* -- collatz.s */

.text
.global main
main:
    mov x1, #123           /* x1 ← 123 */
    mov x2, #0             /* x2 ← 0 */
loop: 
    cmp x1, #1             /* compare x1 and 1 */
    beq end                /* branch to end if x1 == 1 */

    and x3, x1, #1         /* x3 ← x1 & 1 */
    cmp x3, #0             /* comprare x3 and 0 */
    bne odd                /* branch to odd if x3 != 0 */
even:
    mov x1, x1, ASR #1     /* x1 ← (x1 >> 1) */
    b end_loop
odd:
    add x1, x1, x1, LSL #1 /* x1 ← x1 + (x1 << 1) */
    add x1, x1, #1         /* x1 ← x1 + 1 */

end_loop:
    add x2, x2, #1         /* x2 ← x2 + 1 */
    b loop                 /* branch to loop */

end:
    mov x0, x2
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

