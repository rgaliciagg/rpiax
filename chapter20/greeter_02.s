.data     /* data section */

.align 4  /* ensure the next label is 4-byte aligned */
message_hello: .asciz "Hello %s\n"
.align 4  /* ensure the next label is 4-byte aligned */
message_bonjour: .asciz "Bonjour %s\n"

/* tags of kind of people */
.align 4  /* ensure the next label is 4-byte aligned */
person_english : .word say_hello /* tag for people
                                     that will be greeted 
                                     in English */
.align 4  /* ensure the next label is 4-byte aligned */
person_french : .word say_bonjour /* tag for people
                                     that will be greeted 
                                     in French */

/* several names to be used in the people definition */
.align 4
name_pierre: .asciz "Pierre"
.align 4
name_john: .asciz "John"
.align 4
name_sally: .asciz "Sally"
.align 4
name_bernadette: .asciz "Bernadette"

/* some people */
.align 4
person_john: .word name_john, person_english
.align 4
person_pierre: .word name_pierre, person_french
.align 4
person_sally: .word name_sally, person_english
.align 4
person_bernadette: .word name_bernadette, person_french

/* array of people */
people : .word person_john, person_pierre, person_sally, person_bernadette

.text     /* text section (= code) */

.align 4  /* ensure the next label is 4-byte aligned */
say_hello:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    /* Prepare the call to printf */
    mov x1, x0               /* x1 ← x0 */
    ldr x0, addr_of_message_hello
                             /* x0 ← &message_hello */
    bl printf                /* call printf */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller */

.align 4  /* ensure the next label is 4-byte aligned */
addr_of_message_hello: .word message_hello

.align 4  /* ensure the next label is 4-byte aligned */
say_bonjour:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */
    /* Prepare the call to printf */
    mov x1, x0               /* x1 ← x0 */
    ldr x0, addr_of_message_bonjour
                             /* x0 ← &message_bonjour */
    bl printf                /* call printf */
    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller */

.align 4  /* ensure the next label is 4-byte aligned */
addr_of_message_bonjour: .word message_bonjour

/* This function receives an address to a person */
.align 4
greet_person:
    push {x4, lr}            /* keep lr because we call printf, 
                                we keep x4 to keep the stack 8-byte
                                aligned, as per AAPCS requirements */

    /* prepare indirect function call */
    mov x4, x0               /* x0 ← x4, keep the first parameter in x4 */
    ldr x0, [x4]             /* x0 ← *x4, this is the address to the name
                                of the person and the first parameter
                                of the indirect called function*/

    ldr x1, [x4, #4]         /* x1 ← *(x4 + 4) this is the address
                                to the person tag */
    ldr x1, [x1]             /* x1 ← *x1, the address of the
                                specific greeting function */

    blx x1                   /* indirect call to x1, this is
                                the specific greeting function */

    pop {x4, lr}             /* restore x4 and lr */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller */

.globl main /* state that 'main' label is global */
.align 4  /* ensure the next label is 4-byte aligned */
main:
    push {x4, x5, x6, lr}    /* keep callee saved registers that we will modify */

    ldr x4, addr_of_people   /* x4 ← &people */
    /* recall that people is an array of addresses (pointers) to people */

    /* now we loop from 0 to 4 */
    mov x5, #0               /* x5 ← 0 */
    b check_loop             /* branch to the loop check */

    loop:
      /* prepare the call to greet_person */
      ldr x0, [x4, x5, LSL #2]  /* x0 ← *(x4 + x5 << 2)   this is
                                   x0 ← *(x4 + x5 * 4)
                                   recall, people is an array of addresses,
                                   so this is
                                   x0 ← people[x5]
                                */
      bl greet_person           /* call greet_person */
      add x5, x5, #1            /* x5 ← x5 + 1 */
    check_loop:
      cmp x5, #4                /* compute x5 - 4 and update cpsr */
      bne loop                  /* if x5 != 4 branch to loop */

    mov x0, #0               /* return from the program, set error code */
    pop {x4, x5, x6, lr}     /* callee saved registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                    /* return to the caller (the system) */

addr_of_people : .word people
