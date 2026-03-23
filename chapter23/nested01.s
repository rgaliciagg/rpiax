/* nested01.s */

.text

f:
    push {x4, x5, fp, lr} /* keep registers */
    mov fp, sp /* keep dynamic link */

    sub sp, sp, #8      /* make room for x (4 bytes)
                           plus 4 bytes to keep stack
                           aligned */
    /* x is in address "fp - 4" */

    mov x4, #1          /* x4 ← 0 */
    str x4, [fp, #-4]   /* x ← x4 */

    bl g                /* call (nested function) g */

    ldr x4, [fp, #-4]   /* x4 ← x */
    add x4, x4, #1      /* x4 ← x4 + 1 */
    str x4, [fp, #-4]   /* x ← x4 */

    mov sp, fp /* restore dynamic link */
    pop {x4, x5, fp, lr} /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* return */

    /* nested function g */
    g:
        push {x4, x5, fp, lr} /* keep registers */
        mov fp, sp /* keep dynamic link */

        /* At this point our stack looks like this

          Data | Address | Notes
         ------+---------+--------------------
           x4  | fp      |  
           x5  | fp + 4  |
           fp  | fp + 8  | This is the old fp
           lr  |
        */

        ldr x4, [fp, #+8] /* get the activation record
                             of my caller
                             (since only f can call me)
                           */

        /* now x4 acts like the fp we had inside 'f' */
        ldr x5, [x4, #-4] /* x5 ← x */
        add x5, x5, #1    /* x5 ← x5 + 1 */
        str x5, [x4, #-4] /* x ← x5 */

        mov sp, fp /* restore dynamic link */
        pop {x4, x5, fp, lr} /* restore registers */
        
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* return */

.globl main

main :
    push {x4, lr} /* keep registers */

    bl f          /* call f */

    mov x0, #0
    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

