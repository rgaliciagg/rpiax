/* squares.s */

.data

.align 4
message: .asciz "Sum of 1^2 + 2^2 + 3^2 + 4^2 + 5^2 is %d\n"

.text

    
sq: 
  ldr x1, [x0]   /* x1 ← (*x0) */
  mul x1, x1, x1 /* x1 ← x1 * x1 */
  str x1, [x0]   /* (*x0) ← x1 */
  
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


sq_sum5:
  push {fp, lr}         /* Keep fp and all callee-saved registers. */
  mov fp, sp            /* Set the dynamic link */

  sub sp, sp, #16      /* sp ← sp - 4. Allocate space for 4 integers in the stack */
  /* Keep parameters in the stack */
  str x0, [fp, #-16]    /* *(fp - 16) ← x0 */
  str x1, [fp, #-12]    /* *(fp - 12) ← x1 */
  str x2, [fp, #-8]     /* *(fp - 8) ← x2 */
  str x3, [fp, #-4]     /* *(fp - 4) ← x3 */

  /* At this point the stack looks like this
     | Value  |  Address(es)
     +--------+-----------------------
     |   x0   |  [fp, #-16], [sp]
     |   x1   |  [fp, #-12], [sp, #4]
     |   x2   |  [fp, #-8],  [sp, #8]
     |   x3   |  [fp, #-4],  [sp, #12]
     |   fp   |  [fp],       [sp, #16]
     |   lr   |  [fp, #4],   [sp, #20]
     |   e    |  [fp, #8],   [sp, #24]
     v
   Higher
   addresses
  */

  sub x0, fp, #16    /* x0 ← fp - 16 */
  bl sq              /* call sq(&a); */
  sub x0, fp, #12    /* x0 ← fp - 12 */
  bl sq              /* call sq(&b); */
  sub x0, fp, #8     /* x0 ← fp - 8 */
  bl sq              /* call sq(&c); */
  sub x0, fp, #4     /* x0 ← fp - 4 */
  bl sq              /* call sq(&d) */
  add x0, fp, #8     /* x0 ← fp + 8 */
  bl sq              /* call sq(&e) */

  ldr x0, [fp, #-16] /* x0 ← *(fp - 16). Loads a into x0 */
  ldr x1, [fp, #-12] /* x1 ← *(fp - 12). Loads b into x1 */
  add x0, x0, x1     /* x0 ← x0 + x1 */
  ldr x1, [fp, #-8]  /* x1 ← *(fp - 8). Loads c into x1 */
  add x0, x0, x1     /* x0 ← x0 + x1 */
  ldr x1, [fp, #-4]  /* x1 ← *(fp - 4). Loads d into x1 */
  add x0, x0, x1     /* x0 ← x0 + x1 */
  ldr x1, [fp, #8]   /* x1 ← *(fp + 8). Loads e into x1 */
  add x0, x0, x1     /* x0 ← x0 + x1 */

  mov sp, fp         /* Undo the dynamic link */
  pop {fp, lr}       /* Restore fp and callee-saved registers */
  
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


.globl main

main:
    push {x4, lr}          /* Keep callee-saved registers */

    /* Prepare the call to sq_sum5 */
    mov x0, #1             /* Parameter a ← 1 */
    mov x1, #2             /* Parameter b ← 2 */
    mov x2, #3             /* Parameter c ← 3 */
    mov x3, #4             /* Parameter d ← 4 */

    /* Parameter e goes through the stack,
       so it requires enlarging the stack */
    mov x4, #5             /* x4 ← 5 */
    sub sp, sp, #8         /* Enlarge the stack 8 bytes,
                              we will use only the
                              topmost 4 bytes */
    str x4, [sp]           /* Parameter e ← 5 */
    bl sq_sum5             /* call sq_sum5(1, 2, 3, 4, 5) */
    add sp, sp, #8         /* Shrink back the stack */

    /* Prepare the call to printf */
    mov x1, x0             /* The result of sq_sum5 */
    ldr x0, address_of_message
    bl printf              /* Call printf */

    pop {x4, lr}           /* Restore callee-saved registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 



address_of_message: .word message
