.data     /* data section */
.align 4  /* ensure the next label is 4-byte aligned */
message_1: .asciz "Hello\n"
.align 4  /* ensure the next label is 4-byte aligned */
message_2: .asciz "Bonjour\n"

.text     /* text section (= code) */

.align 4  /* ensure the next label is 4-byte aligned */
say_hello:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    /* Prepare the call to printf */
    ldr x0, addr_of_message_1 /* x0 ← &message */
    bl printf                 /* call printf */
    pop {x4, lr}              /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                     /* return to the caller */

.align 4  /* ensure the next label is 4-byte aligned */
addr_of_message_1: .word message_1

.align 4  /* ensure the next label is 4-byte aligned */
say_bonjour:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    /* Prepare the call to printf */
    ldr x0, addr_of_message_2 /* x0 ← &message */
    bl printf                 /* call printf */
    pop {x4, lr}              /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                     /* return to the caller */

.align 4  /* ensure the next label is 4-byte aligned */
addr_of_message_2: .word message_2

.align 4
greeter:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    blx x0                   /* indirect call to x0 */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller */

.globl main /* state that 'main' label is global */
.align 4  /* ensure the next label is 4-byte aligned */
main:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */

    ldr x0, addr_say_hello   /* x0 ← &say_hello */
    bl greeter               /* call greeter */

    ldr x0, addr_say_bonjour /* x0 ← &say_bonjour */
    bl greeter               /* call greeter */

    mov x0, #0               /* return from the program, set error code */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller (the system) */

addr_say_hello : .word say_hello
addr_say_bonjour : .word say_bonjour
