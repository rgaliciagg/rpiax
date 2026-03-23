/* -- store02.s */

/* -- Data section */
.data

/* Ensure variable is 4-byte aligned */
.balign 4
/* Define storage for myvax1 */
myvax1:
    /* Contents of myvax1 is just '3' */
    .word 3

/* Ensure variable is 4-byte aligned */
.balign 4
/* Define storage for myvax2 */
myvax2:
    /* Contents of myvax2 is just '3' */
    .word 4

/* Ensure variable is 4-byte aligned */
.balign 4
/* Define storage for myvax3 */
myvax3:
    /* Contents of myvax3 is just '0' */
    .word 0

/* -- Code section */
.text

/* Ensure function section starts 4 byte aligned */
.balign 4
.global main
main:
    ldr x1, addr_of_myvax1 /* x1 ← &myvax1 */
    ldr x1, [x1]           /* x1 ← *x1 */
    ldr x2, addr_of_myvax2 /* x2 ← &myvax2 */
    ldr x2, [x2]           /* x1 ← *x2 */
    add x3, x1, x2         /* x3 ← x1 + x2 */
    ldr x4, addr_of_myvax3 /* x4 ← &myvax3 */
    str x3, [x4]           /* *x4 ← x3 */
    /* Clear registers to prove that
       we are actually something
       previously stored */
    mov x0, #0             /* x0 ← 0 */
    mov x1, #0             /* x1 ← 0 */
    mov x2, #0             /* x2 ← 0 */
    mov x3, #0             /* x3 ← 0 */
    mov x4, #0             /* x4 ← 0 */
    
    ldr x0, addr_of_myvax3
    ldr x0, [x0]
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


/* Labels needed to access data */
addr_of_myvax1 : .word myvax1
addr_of_myvax2 : .word myvax2
addr_of_myvax3 : .word myvax3
