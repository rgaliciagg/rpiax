.data     /* data section */
.align 4  /* ensure the next label is 4-byte aligned */
message: .asciz "Hello world\n"

.text     /* text section (= code) */

.align 4  /* ensure the next label is 4-byte aligned */
say_hello:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    /* Prepare the call to printf */
    ldr x0, addr_of_message  /* x0 ← &message */
    bl printf                /* call printf */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller */

.align 4  /* ensure the next label is 4-byte aligned */
addr_of_message: .word message

.globl main /* state that 'main' label is global */
.align 4  /* ensure the next label is 4-byte aligned */
main:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    bl say_hello             /* call say_hello, directly, using the label */

    mov x0, #0               /* return from the program, set error code */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller (the system) */

