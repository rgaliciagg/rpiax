
.data
max16bit: .word 32767

.text

clipped_add16bit:
    /* first operand is in x0 */
    /* second operand is in x0 */
    /* result is left in x0 */
    push {x4, lr}             /* keep registers */
 
    ldr x4, addr_of_max16bit  /* x4 ← &max16bit */
    ldr x4, [x4]              /* x4 ← *x4 */
                              /* now x4 == 32767 (i.e. 2^15 - 1) */

    add x0, x0, x1            /* x0 ← x0 + x1 */
    cmp x0, x4                /* perform x0 - x4 and update cpsr */
    movgt x0, x4              /* if x0 > x4 then x0 ← x4 */
    bgt end                   /* if x0 > x4 then branch to end */
    
    mvn x4, x4                /* x4 ← ~x4
                                 now x4 == -32768 (i.e. -2^15) */
    cmp x0, x4                /* perform x0 - x4 and update cpsr */
    movlt x0, x4              /* if x0 < x4 then x0 ← x4 */
  
    end:

    pop {x4, lr}              /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                     /* return */
addr_of_max16bit: .word max16bit

.globl main

main:
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

