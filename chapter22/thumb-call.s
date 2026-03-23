/* thumb-call.s */
.text

.code 16     /* Here we say we will use Thumb */
.align 2     /* Make sure instructions are aligned at 2-byte boundary */

thumb_function_2:
    mov x0, #2
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
   /* A leaf Thumb function (i.e. a function that does not call
               any other function) returns using "
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
" */

thumb_function_1:
    push {x4, lr}       /* Keep x4 and lr in the stack */
    bl thumb_function_2 /* From Thumb to Thumb we use bl */
    pop {x4, pc}  /* This is how we return from a non-leaf Thumb function */

.code 32     /* Here we say we will use ARM */
.align 4     /* Make sure instructions are aligned at 4-byte boundary */
.globl main
main:
    push {x4, lr}

    blx thumb_function_1 /* From ARM to Thumb we use blx */

    pop {x4, lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

