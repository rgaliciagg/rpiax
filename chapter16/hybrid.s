/* hybrid.s */
.data

.text

.globl main

main:
  push {x4, x5, x6, lr}

  cmp x0, #1                /* x0 - 1 and update cpsr */
  blt case_default          /* if x0 < 1 then branch to case_default */
  cmp x0, #300              /* x0 - 300 and update cpsr */
  bgt case_default          /* if x0 > 300 then branch to case default */

  /* prepare the binary search. 
     x1 will hold the lower index
     x2 will hold the upper index
     x3 the base address of the case_value_table
  */
  mov x1, #0
  mov x2, #9
  ldr x3, addr_case_value_table /* x3 ← &case_value_table */

  b check_binary_search
  binary_search:
    add x4, x1, x2          /* x4 ← x1 + x2 */
    mov x4, x4, ASR #1      /* x4 ← x4 / 2 */
    ldr x5, [x3, +x4, LSL #2]   /* x5 ← *(x3 + x4 * 4). 
                               This is x5 ← case_value_table[x4] */
    cmp x0, x5              /* x0 - x5 and update cpsr */
    sublt x2, x4, #1        /* if x0 < x5 then x2 ← x4 - 1 */
    addgt x1, x4, #1        /* if x0 > x5 then x1 ← x4 + 1 */
    bne check_binary_search /* if x0 != x5 branch to binary_search */

    /* if we reach here it means that x0 == x5 */
    ldr x5, addr_case_addresses_table /* x5 ← &addr_case_value_table */
    ldr x5, [x5, +x4, LSL #2]   /* x5 ← *(x5 + x4*4) 
                               This is x5 ← case_addresses_table[x4] */
    mov pc, x5              /* branch to the proper case */
    
  check_binary_search:
    cmp x1, x2              /* x1 - x2 and update cpsr */
    ble binary_search       /* if x1 <= x2 branch to binary_search */

  /* if we reach here it means the case value
     was not found. branch to default case */
  b case_default

  case_1:
     mov x0, #1
     b after_switch
  case_2:
     mov x0, #2
     b after_switch
  case_3:
     mov x0, #3
     b after_switch
  case_24:
     mov x0, #24
     b after_switch
  case_25:
     mov x0, #95
     b after_switch
  case_26:
     mov x0, #96
     b after_switch
  case_97:
     mov x0, #97
     b after_switch
  case_98:
     mov x0, #98
     b after_switch
  case_99:
     mov x0, #99
     b after_switch
  case_300:
     mov x0, #300    /* The error code will be 44 */
     b after_switch

  case_default:
   mov x0, #42       /* x0 ← 42 */
   b after_switch    /* break (unnecessary) */  

  after_switch:

  pop {x4,x5,x6,lr}
  
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
              /* Return from main */

case_value_table: .word 1, 2, 3, 24, 25, 26, 97, 98, 99, 300
addr_case_value_table: .word case_value_table

case_addresses_table:
    .word case_1
    .word case_2
    .word case_3
    .word case_24
    .word case_25
    .word case_26
    .word case_97
    .word case_98
    .word case_99
    .word case_300
addr_case_addresses_table: .word case_addresses_table
