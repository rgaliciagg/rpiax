/* binsearch.s */
.data

.text

.globl main

main:

  cmp x0, #1              /* x0 - 1 and update cpsr */
  blt case_default        /* if x0 < 1 then branch to case_default */
  cmp x0, #10             /* x0 - 10 and update cpsr */
  bgt case_default        /* if x0 > 10 then branch to case default */

  case_1_to_10:
    cmp x0, #5            /* x0 - 5 and update cpsr */
    beq case_5            /* if x0 == 5 branch to case_5 */
    blt case_1_to_4       /* if x0 < 5 branch to case_1_to_4 */
    bgt case_6_to_10      /* if x0 > 5 branch to case_6_to_4 */

  case_1_to_4:
    cmp x0, #2            /* x0 - 2 and update cpsr */
    beq case_2            /* if x0 == 2 branch to case_2 */
    blt case_1            /* if x0 < 2 branch to case_1 
                             (case_1_to_1 does not make sense) */
    bgt case_3_to_4       /* if x0 > 2 branch to case_3_to_4 */

  case_3_to_4:            
    cmp x0, #3            /* x0 - 3 and update cpsr */
    beq case_3            /* if x0 == 3 branch to case_3 */
    b case_4              /* otherwise it must be x0 == 4,
                             branch to case_4 */

  case_6_to_10:
    cmp x0, #8            /* x0 - 8 and update cpsr */
    beq case_8            /* if x0 == 8 branch to case_8 */
    blt case_6_to_7       /* if x0 < 8 then branch to case_6_to_7 */
    bgt case_9_to_10      /* if x0 > 8 then branch to case_9_to_10 */

  case_6_to_7:
    cmp x0, #6            /* x0 - 6 and update cpsr */
    beq case_6            /* if x0 == 6 branch to case_6 */
    b case_7              /* otherwise it must be x0 == 7,
                             branch to case 7 */

  case_9_to_10:
    cmp x0, #9            /* x0 - 9 and update cpsr */
    beq case_9
    b case_10

  case_1:
     mov x0, #1
     b after_switch
  case_2:
     mov x0, #2
     b after_switch
  case_3:
     mov x0, #3
     b after_switch
  case_4:
     mov x0, #4
     b after_switch
  case_5:
     mov x0, #5
     b after_switch
  case_6:
     mov x0, #6
     b after_switch
  case_7:
     mov x0, #7
     b after_switch
  case_8:
     mov x0, #8
     b after_switch
  case_9:
     mov x0, #9
     b after_switch
  case_10:
     mov x0, #10
     b after_switch

  case_default:
   mov x0, #42                /* x0 ← 42 */
   b after_switch             /* break (unnecessary) */  

  after_switch:

  
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                       /* Return from main */
