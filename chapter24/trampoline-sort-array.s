/* trampoline-sort-arrays.s */

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
.align 4
comparison_message: .asciz "Num comparisons: %d\n"

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
    push {x4, x5, x6, fp, lr} /* keep callee saved registers */
    mov fp, sp                /* setup dynamic link */

    sub sp, sp, #4            /* counter will be in fp - 4 */
    /* note that now the stack is 8-byte aligned */

    /* set counter to zero */
    mov x4, #0        /* x4 ← 0 */
    str x4, [fp, #-4] /* counter ← x4 */

    /* Make room for the trampoline */
    sub sp, sp, #32 /* sp ← sp - 32 */
    /* note that 32 is a multiple of 8, so the stack
       is still 8-byte aligned */

    /* copy the trampoline into the stack */
    mov x4, #32                        /* x4 ← 32 */
    ldr x5, .Laddr_trampoline_template /* x4 ← &trampoline_template */
    mov x6, sp                         /* x6 ← sp */
    b .Lcopy_trampoline_loop_check     /* branch to copy_trampoline_loop_check */

    .Lcopy_trampoline_loop:
        ldr x7, [x5]     /* x7 ← *x5 */
        str x7, [x6]     /* *x6 ← x7 */
        add x5, x5, #4   /* x5 ← x5 + 4 */
        add x6, x6, #4   /* x6 ← x6 + 4 */
        sub x4, x4, #4   /* x4 ← x4 - 4 */
    .Lcopy_trampoline_loop_check:
        cmp x4, #0                  /* compute x4 - 0 and update cpsr */
        bgt .Lcopy_trampoline_loop  /* if cpsr means that x4 > 0
                                       then branch to copy_trampoline_loop */

    /* setup the trampoline */
    ldr x4, addr_of_integer_comparison_count
                       /* x4 ← &integer_comparison_count */
    str x4, [fp, #-36] /* *(fp + 36) ← x4 */
                       /* set the function_called in the trampoline
                          to be &integer_comparison_count */
    str fp, [fp, #-32]  /* *(fp + 32) ← fp */
                        /* set the lexical_scope in the trampoline
                           to be fp */

    /* prepare call to __clear_cache */
    mov x0, sp       /* x0 ← sp */
    add x1, sp, #32  /* x1 ← sp + 32 */
    bl __clear_cache /* call __clear_cache */

    /* prepare call to print_array */
    ldr x0, addr_of_my_array /* x0 ← &my_array */
    mov x1, #10              /* x1 ← 10
                                our array is of length 10 */
    bl print_array           /* call print_array */

    /* prepare call to qsort */
    /*
    void qsort(void *base,
         size_t nmemb,
         size_t size,
         int (*compar)(const void *, const void *));
    */
    ldr x0, addr_of_my_array /* x0 ← &my_array
                                base */
    mov x1, #10              /* x1 ← 10
                                nmemb = number of members
                                our array is 10 elements long */
    mov x2, #4               /* x2 ← 4
                                size of each member is 4 bytes */
    sub x3, fp, #28          /* x3 ← fp + 28 */
    bl qsort                 /* call qsort */

    /* prepare call to printf */
    ldr x1, [fp, #-4]                    /* x1 ← counter
                                            num comparisons */
    ldr x0, addr_of_comparison_message   /* x0 ← &comparison_message */
    bl printf                            /* call printf */

    /* now print again the array to see if elements were sorted */
    /* prepare call to print_array */
    ldr x0, addr_of_my_array  /* x0 ← &my_array */
    mov x1, #10               /* x1 ← 10
                                 our array is of length 10 */
    bl print_array            /* call print_array */

    mov x0, #0                /* x0 ← 0 set errorcode to 0 prior returning from main */

    mov sp, fp
    pop {x4, x5, x6, fp, lr}      /* restore callee-saved registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                     /* return */

addr_of_my_array: .word my_array
addr_of_comparison_message : .word comparison_message

    /* nested function integer comparison */
    addr_of_integer_comparison_count : .word integer_comparison_count
    integer_comparison_count:
        /* x0 will be the address to the first integer */
        /* x1 will be the address to the second integer */
        push {x4, x5, x10, fp, lr} /* keep callee-saved registers */
        mov fp, sp                 /* setup dynamic link */

        ldr x0, [x0]    /* x0 ← *x0
                           load the integer pointed by x0 in x0 */
        ldr x1, [x1]    /* x1 ← *x1
                           load the integer pointed by x1 in x1 */
     
        cmp x0, x1      /* compute x0 - x1 and update cpsr */
        moveq x0, #0    /* if cpsr means that x0 == x1 then x0 ←  0 */
        movlt x0, #-1   /* if cpsr means that x0 <  x1 then x0 ← -1 */
        movgt x0, #1    /* if cpsr means that x0 >  x1 then x0 ←  1 */

        ldr x4, [fp, #8]  /* x4 ← *(fp + 8)
                             get static link in the stack */
        ldr x5, [x4, #-4] /* x5 ← *(x4 - 4)
                             get value of counter */
        add x5, x5, #1    /* x5 ← x5 + 1 */
        str x5, [x4, #-4] /* *(x4 - 4) ← x5
                             update counter */

        mov sp, fp        /* restore stack */
        pop {x4, x5, x10, fp, lr} /* restore callee-saved registers */
        
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
           /* return */

.Laddr_trampoline_template : .word .Ltrampoline_template
.Ltrampoline_template:
    .Lfunction_called: .word 0x0
    .Llexical_scope: .word 0x0
    push {x4, x5, x10, lr}           /* keep callee-saved registers */
    ldr x4, .Lfunction_called        /* x4 ← function called */
    ldr x10, .Llexical_scope         /* x10 ← lexical scope */
    blx x4                           /* indirect call to x4 */
    pop {x4, x5, x10, lr}            /* restore callee-saved registers */
    
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                            /* return */


