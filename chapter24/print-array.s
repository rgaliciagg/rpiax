/* print-array.s */

.data

/* declare an array of 10 integers called my_array */
.align 4
my_array: .word 82, 70, 93, 77, 91, 30, 42, 6, 92, 64

/* format strings for printf */
/* format string that prints an integer plus a space */
.align 4
integer_printf: .asciz "%d "
/* format string that simply prints a newline */
.align 4
newline_printf: .asciz "\n"

.text

print_array:
    /* x0 will be the address of the integer array */
    /* x1 will be the number of items in the array */
    push {x4, x5, x6, lr}  /* keep x4, x5, x6 and lr in the stack */

    mov x4, x0             /* x4 ← x0. keep the address of the array */
    mov x5, x1             /* x5 ← x1. keep the number of items */
    mov x6, #0             /* x6 ← 0.  current item to print */

    b .Lprint_array_check_loop /* go to the condition check of the loop */

    .Lprint_array_loop:
      /* prepare the call to printf */
      ldr x0, addr_of_integer_printf  /* x0 ← &integer_printf */
      ldr x1, [x4, +x6, LSL #2]       /* x1 ← *(x4 + x6 * 4) */
      bl printf                       /* call printf */

      add x6, x6, #1                  /* x6 ← x6 + 1 */
    .Lprint_array_check_loop: 
      cmp x6, x5               /* perform x6 - x5 and update cpsr */
      bne .Lprint_array_loop   /* if cpsr states that x6 is not equal to x5
                                  branch to the body of the loop */

    /* prepare call to printf */
    ldr x0, addr_of_newline_printf /* x0 ← &newline_printf */
    bl printf
    
    pop {x4, x5, x6, lr}   /* restore x4, x5, x6 and lr from the stack */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                  /* return */

addr_of_integer_printf: .word integer_printf
addr_of_newline_printf: .word newline_printf

.globl main
main:
    push {x4, lr}             /* keep x4 and lr in the stack */

    /* prepare call to print_array */
    ldr x0, addr_of_my_array  /* x0 ← &my_array */
    mov x1, #10               /* x1 ← 10
                                 our array is of length 10 */
    bl print_array            /* call print_array */

    mov x0, #0                /* x0 ← 0 set errorcode to 0 prior returning from main */
    pop {x4, lr}              /* restore x4 and lr in the stack */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                     /* return */

addr_of_my_array: .word my_array
