/* jumptable.s */
.data

.text

.globl main

main:
  cmp x0, #1                  /* x0 - 1 and update cpsr */
  blt case_default            /* branch to case_default if x0 < 1 */
  cmp x0, #3                  /* x0 - 3 and update cpsr */
  bgt case_default            /* branch to case_default if x0 > 3 */

  sub x0, x0, #1              /* x0 ← x0 - 1. Required to index the table */
  ldr x1, addr_of_jump_table  /* x1 ← &jump_table */
  ldr x1, [x1, +x0, LSL #2]   /* x1 ← *(x1 + x0*4).
                                 This is x1 ← jump_table[x0] */

  mov pc, x1                  /* pc ← x1
                                 This will cause a branch to the
                                 computed address */

  case_1:
   mov x0, #1                 /* x0 ← 1 */ 
   b after_switch             /* break */
 
  case_2:
   mov x0, #2                 /* x0 ← 2 */
   b after_switch             /* break */

  case_3:
   mov x0, #3                 /* x0 ← 3 */
   b after_switch             /* break */

  case_default:
   mov x0, #42                /* x0 ← 42 */
   b after_switch             /* break (unnecessary) */  

  after_switch:

  
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                       /* Return from main */

.align 4
jump_table: 
   .word case_1
   .word case_2
   .word case_3

.align 4
addr_of_jump_table: .word jump_table
