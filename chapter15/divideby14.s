/* -- divideby14.s */

.data

.align 4
read_number: .word 0

.align 4
message1 : .asciz "Enter an integer to divide it by 14: "

.align 4
message2 : .asciz "Number %d (signed-)divided by 14 is %d\n"

.align 4
scan_format : .asciz "%d"

.text

/* This function has been generated using "magic.py 14 code_for_signed" */
s_divide_by_14:
   /* x0 contains the argument to be divided by 14 */
   ldr x1, .Ls_magic_number_14 /* x1 ← magic_number */
   smull x1, x2, x1, x0   /* x1 ← Lowex32Bits(x1*x0). x2 ← Uppex32Bits(x1*x0) */
   add x2, x2, x0         /* x2 ← x2 + x0 */
   mov x2, x2, ASR #3     /* x2 ← x2 >> 3 */
   mov x1, x0, LSR #31    /* x1 ← x0 >> 31 */
   add x0, x2, x1         /* x0 ← x2 + x1 */
   
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                  /* leave function */
   .align 4
   .Ls_magic_number_14: .word 0x92492493

.globl main

main:
    /* Call printf */
    push {x4, lr}
    ldr x0, addr_of_message1       /* x0 ← &message */
    bl printf

    /* Call scanf */
    ldr x0, addr_of_scan_format   /* x0 ← &scan_format */
    ldr x1, addr_of_read_number   /* x1 ← &read_number */
    bl scanf

    ldr x0, addr_of_read_number   /* x1 ← &read_number */
    ldr x0, [x0]                  /* x1 ← *x1 */

    bl s_divide_by_14
    mov x2, x0

    ldr x1, addr_of_read_number   /* x1 ← &read_number */
    ldr x1, [x1]                  /* x1 ← *x1 */
    
    ldr x0, addr_of_message2      /* x0 ← &message2 */
    bl printf                     /* Call printf, x1 and x2 already
                                     contain the desired values */

    pop {x4, lr}
    mov x0, #0
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


addr_of_message1: .word message1
addr_of_scan_format: .word scan_format
addr_of_message2: .word message2
addr_of_read_number: .word read_number
