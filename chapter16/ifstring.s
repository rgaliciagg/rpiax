/* ifstring.s */
.data

.text

.globl main

main:
  cmp x0, #1                  /* x0 - 1 and update cpsr */
  beq case_1                  /* if x0 == 1 branch to case_1 */
  cmp x0, #2                  /* x0 - 2 and update cpsr */
  beq case_2                  /* if x0 == 2 branch to case_2 */
  cmp x0, #3                  /* x0 - 3 and update cpsr */
  beq case_3                  /* if x0 == 3 branch to case_3 */
  b case_default              /* branch to case_default */

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
