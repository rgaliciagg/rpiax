/* -- store01.s */

/* -- Data section */
.data

/* Ensure variable is 4-byte aligned */
.balign 4
/* Define storage for myvax1 */
myvax1:
    /* Contents of myvax1 is just '3' */
    .word 0

/* Ensure variable is 4-byte aligned */
.balign 4
/* Define storage for myvax2 */
myvax2:
    /* Contents of myvax2 is just '3' */
    .word 0

/* -- Code section */
.text

/* Ensure function section starts 4 byte aligned */
.balign 4
.global main
main:
    ldr x1, addr_of_myvax1 /* x1 ← &myvax1 */
    mov x3, #3             /* x3 ← 3 */
    str x3, [x1]           /* *x1 ← x3 */
    ldr x2, addr_of_myvax2 /* x2 ← &myvax2 */
    mov x3, #4             /* x3 ← 3 */
    str x3, [x2]           /* *x2 ← x3 */

    ldr x1, addr_of_myvax1 /* x1 ← &myvax1 */
    ldr x1, [x1]           /* x1 ← *x1 */
    ldr x2, addr_of_myvax2 /* x2 ← &myvax2 */
    ldr x2, [x2]           /* x1 ← *x2 */
    add x0, x1, x2
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 


/* Labels needed to access data */
addr_of_myvax1 : .word myvax1
addr_of_myvax2 : .word myvax2
