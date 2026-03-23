/* -- collatz03.s */
.data

message: .asciz "Type a number: "
scan_format : .asciz "%d"
message2: .asciz "Length of the Hailstone sequence for %d is %d\n"


.text

collatz2:
    /* x0 contains the first argument */
    push {x4}
    mov x4, x0
    mov x3, #4194304
  collatz_repeat:
    mov x1, x4                 /* x1 ← x0 */
    mov x0, #0                 /* x0 ← 0 */
  collatz2_loop:
    cmp x1, #1                 /* compare x1 and 1 */
    beq collatz2_end           /* if x1 == 1 branch to collatz2_end */
    and x2, x1, #1             /* x2 ← x1 & 1 */
    cmp x2, #0                 /* compare x2 and 0 */
    moveq x1, x1, ASR #1       /* if x2 == 0, x1 ← x1 >> 1. This is x1 ← x1/2 */
    addne x1, x1, x1, LSL #1   /* if x2 != 0, x1 ← x1 + (x1 << 1). This is x1 ← 3*x1 */
    addne x1, x1, #1           /* if x2 != 0, x1 ← x1 + 1. */
  collatz2_end_loop:
    add x0, x0, #1             /* x0 ← x0 + 1 */
    b collatz2_loop             /* branch back to collatz2_loop */
  collatz2_end:
    sub x3, x3, #1
    cmp x3, #0
    bne collatz_repeat
    pop {x4}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


.global main
main:
    push {lr}                       /* keep lr */
    sub sp, sp, #4                  /* make room for 4 bytes in the stack */

    ldr x0, address_of_message      /* first parameter of printf: &message */
    bl printf                       /* call printf */

    ldr x0, address_of_scan_format  /* first parameter of scanf: &scan_format */
    mov x1, sp                      /* second parameter of scanf: 
                                       address of the top of the stack */
    bl scanf                        /* call scanf */

    ldr x0, [sp]                    /* first parameter of collatz:
                                       the value stored (by scanf) in the top of the stack */
    bl collatz2                     /* call collatz2 */
    
    mov x2, x0                      /* third parameter of printf: 
                                       the result of collatz */
    ldr x1, [sp]                    /* second parameter of printf:
                                       the value stored (by scanf) in the top of the stack */
    ldr x0, address_of_message2     /* first parameter of printf: &address_of_message */
    bl printf

    add sp, sp, #4
    pop {lr}
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

    

address_of_message: .word message
address_of_scan_format: .word scan_format
address_of_message2: .word message2
