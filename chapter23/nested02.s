/* nested01.s */

.text

# void f(void) // non nested (nesting depth = 0)
# {
#    int x;
# 
#    void g() // nested (nesting depth = 1)
#    {
#       x = x + 1;
#    }
#    void h() // nested (nesting depth = 1)
#    {
#       void m() // nested (nesting depth = 2)
#       {
#          x = x + 2;
#          g();
#       }
# 
#       g();
#       m();
#       x = x + 3;
#    }
# 
#    x = 1;
#    h();
#    // here x will be 8
# }

f:
    push {x4, x10, fp, lr} /* keep registers */
    mov fp, sp             /* setup dynamic link */

    sub sp, sp, #8      /* make room for x (4 + 4 bytes) */
    /* x will be in address "fp - 4" */

    /* At this point our stack looks like this

     Data | Address | Notes
    ------+---------+---------------------------
          | fp - 8  | alignment (per AAPCS)
      x   | fp - 4  | 
      x4  | fp      |  
      x10 | fp + 8  | previous value of x10
      fp  | fp + 12 | previous value of fp
      lr  | fp + 16 |
   */

    mov x4, #1          /* x4 ← 1 */
    str x4, [fp, #-4]   /* x ← x4 */

    /* prepare the call to h */
    mov x10, fp /* setup the static link,
                   since we are calling an immediately nested function
                   it is just the current frame */
    bl h

    mov sp, fp             /* restore stack */
    pop {x4, x10, fp, lr}  /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
 /* return */

/* ------ nested function ------------------ */
h :
    push {x4, x5, x10, fp, lr} /* keep registers */
    mov fp, sp /* setup dynamic link */

    sub sp, sp, #4 /* align stack */

    /* At this point our stack looks like this

      Data | Address | Notes
     ------+---------+---------------------------
           | fp - 4  | alignment (per AAPCS)
       x4  | fp      |  
       x5  | fp + 4  | 
       x10 | fp + 8  | frame pointer of 'f'
       fp  | fp + 12 | frame pointer of caller
       lr  | fp + 16 |
    */

    /* prepare call to g */
    /* g is a sibling so the static link will be the same
       as the current one */
    ldr x10, [fp, #8]
    bl g

    /* prepare call to m */
    /* m is an immediately nested function so the static
       link is the current frame */
    mov x10, fp
    bl m

    ldr x4, [fp, #8]  /* load frame pointer of 'f' */
    ldr x5, [x4, #-4]  /* x5 ← x */
    add x5, x5, #3     /* x5 ← x5 + 3 */
    str x5, [x4, #-4]  /* x ← x5 */

    mov sp, fp            /* restore stack */
    pop {x4, x5, x10, fp, lr} /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 



/* ------ nested function ------------------ */
m:
    push {x4, x5, x10, fp, lr} /* keep registers */
    mov fp, sp /* setup dynamic link */

    sub sp, sp, #4 /* align stack */
    /* At this point our stack looks like this

      Data | Address | Notes
     ------+---------+---------------------------
           | fp - 4  | alignment (per AAPCS)
       x4  | fp      |  
       x5  | fp + 4  |
       x10 | fp + 8  | frame pointer of 'h'
       fp  | fp + 12 | frame pointer of caller
       lr  | fp + 16 |
    */

    ldr x4, [fp, #8]  /* x4 ← frame pointer of 'h' */
    ldr x4, [x4, #8]  /* x4 ← frame pointer of 'f' */
    ldr x5, [x4, #-4] /* x5 ← x */
    add x5, x5, #2    /* x5 ← x5 + 2 */
    str x5, [x4, #-4] /* x ← x5 */

    /* setup call to g */
    ldr x10, [fp, #8]   /* x10 ← frame pointer of 'h' */
    ldr x10, [x10, #8]  /* x10 ← frame pointer of 'f' */
    bl g

    mov sp, fp                /* restore stack */
    pop {x4, x5, x10, fp, lr} /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


/* ------ nested function ------------------ */
g:
    push {x4, x5, x10, fp, lr} /* keep registers */
    mov fp, sp /* setup dynamic link */

    sub sp, sp, #4 /* align stack */

    /* At this point our stack looks like this

      Data | Address | Notes
     ------+---------+---------------------------
           | fp - 4  | alignment (per AAPCS)
       x4  | fp      |  
       x5  | fp + 4  |  
       x10 | fp + 8  | frame pointer of 'f'
       fp  | fp + 12 | frame pointer of caller
       lr  | fp + 16 |
    */

    ldr x4, [fp, #8]  /* x4 ← frame pointer of 'f' */
    ldr x5, [x4, #-4] /* x5 ← x */
    add x5, x5, #1    /* x5 ← x5 + 1 */
    str x5, [x4, #-4] /* x ← x5 */

    mov sp, fp /* restore dynamic link */
    pop {x4, x5, x10, fp, lr} /* restore registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


.globl main

main :
    push {x4, lr} /* keep registers */

    bl f          /* call f */

    mov x0, #0
    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

