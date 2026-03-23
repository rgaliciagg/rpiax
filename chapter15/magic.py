#!/usr/bin/python
# coding=utf-8

# Implemented very naively following the equations in Hacker's Delight

# We assume 32-bit
w = 32
# Make sure you use Python 2.5+ because we may enter in the domain of bignums
# (Python long) during the computations

# We mimick a C99-style %-operator (remainder)
# Python returns the sign of the divisor
# while C99 uses the sign of the dividend
def rem(x, y):
    t = x % y
    if (t == 0):
        return t
    # For nonzero results we may have to adjust the result
    #  2 %  3 = 2
    # -2 % -3 = -2
    if (x > 0) != (y > 0):
        t = t - y
    return t


def magic_unsigned(d):
    p = w
    n_c = 2**w - rem(2**w, d) - 1
    while not (2**p > (n_c * (d - 1 - rem(2**p - 1, d)))):
        p = p + 1
    m = (2**p + d - 1 - rem(2**p - 1, d)) / d
    # Adjust the result to w bits
    magic = m & ~(~0 << w)
    add_flag = (m != magic)
    shift = p - w
    return (magic, shift, add_flag)

def magic_signed_positive(d):
    p = w
    n_c = 2**(w-1) - rem(2**(w-1), d) - 1
    while not (2**p > (n_c*(d-rem(2**p, d)))):
        p = p + 1
    m = (2**p + d - rem(2**p, d)) / d
    # Adjust the result to w bits
    magic = m & ~(~0 << w)
    shift = p - w
    return (magic, shift)

def magic_signed_negative(d):
    p = w
    n_c = -(2**(w-1)) + rem(2**(w-1) + 1, d)
    while not (2**p > (n_c*(d+rem(2**p, d)))):
        p = p + 1
    m = (2**p - d - rem(2**p, d)) / d
    # Adjust the result to w bits
    magic = m & ~(~0 << w)
    shift = p - w
    return (magic, shift)

import sys
import string

operations = ["just_tell", "code_for_signed", "code_for_unsigned"]

def usage_message():
    print "usage: {0} divisor [{1}]".format(sys.argv[0], string.join(operations, "|"))
    sys.exit(1)

if len(sys.argv) < 2:
    usage_message()

# The divisor
try:
    d = int(sys.argv[1])
except:
    usage_message()

if (d == 0):
    print "dividend cannot be zero"
    usage_message()

if len(sys.argv) >= 3:
    operation = sys.argv[2]
else:
    operation = "just_tell"

if operation not in operations:
    usage_message()

if operation == "just_tell":
    if d > 0:
        (magic_signed, shift_signed) = magic_signed_positive(d)
        (magic_unsigned, shift_unsigned, add_flag) = magic_unsigned(d)
        print "Magic number for signed division by {0} is {1} (0x{1:X}) with shift {2}".format(d, magic_signed, shift_signed)
        print "Magic number for unsigned division by {0} is {1} (0x{1:X}) with shift {2}{3}".format(d, magic_unsigned, shift_unsigned, " and we need an extra addition" if add_flag else "")
    elif d < 0:
        (magic_signed, shift_signed) = magic_signed_negative(d)
        print "Magic number for signed division by {0} is {1} (0x{1:X}) with shift {2}".format(d, magic_signed, shift_signed)
    else:
        print "Can't divide by 0"
elif operation == "code_for_signed":
    if (d > 0):
        (magic_signed, shift_signed) = magic_signed_positive(d)
    else:
        (magic_signed, shift_signed) = magic_signed_negative(d)

    tab = "   "
    dividend_name = "{0}".format(d) if d > 0 else "minus_{0}".format(-d)
    magic_number_name = ".Ls_magic_number_{0}".format(dividend_name)
    function_name = "s_divide_by_{0}".format(dividend_name)
    code = "{0}:\n".format(function_name)
    code += tab + "/* x0 contains the argument to be divided by {0} */\n".format(d)
    code += tab + "ldr x1, {0} /* x1 ← magic_number */\n".format(magic_number_name)
    code += tab + "smull x1, x2, x1, x0   /* x1 ← Lowex32Bits(x1*x0). x2 ← Uppex32Bits(x1*x0) */\n"
    magic_number_is_negative = (magic_signed & (1 << (w-1)))
    if d > 0 and magic_number_is_negative:
        code += tab + "add x2, x2, x0         /* x2 ← x2 + x0 */\n"
    elif d < 0 and not magic_number_is_negative:
        code += tab + "sub x2, x2, x0         /* x2 ← x2 - x0 */\n"
    if shift_signed > 0:
        code += tab + "mov x2, x2, ASR #{0}     /* x2 ← x2 >> {0} */\n".format(shift_signed)
    code += tab + "mov x1, x0, LSR #{0}    /* x1 ← x0 >> {0} */\n".format(w-1)
    code += tab + "add x0, x2, x1         /* x0 ← x2 + x1 */\n"
    code += tab + "
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                  /* leave function */\n"
    code += tab + ".align 4\n"
    code += tab + "{0}: .word 0x{1:x}\n".format(magic_number_name, magic_signed)

    print code
elif operation == "code_for_unsigned":
    if d < 0:
        print "You requested code for unsigned but the divisor is negative!"
        sys.exit(1)
    (magic_unsigned, shift_unsigned, add_flag) = magic_unsigned(d)
    tab = "   "
    dividend_name = "{0}".format(d)
    magic_number_name = ".Lu_magic_number_{0}".format(dividend_name)
    function_name = "u_divide_by_{0}".format(dividend_name)
    code = "{0}:\n".format(function_name)
    code += tab + "/* x0 contains the argument to be divided by {0} */\n".format(d)
    code += tab + "ldr x1, {0} /* x1 ← magic_number */\n".format(magic_number_name)
    code += tab + "umull x1, x2, x1, x0   /* x1 ← Lowex32Bits(x1*x0). x2 ← Uppex32Bits(x1*x0) */\n"
    if add_flag:
        code += tab + "adds x2, x2, x0        /* x2 ← x2 + x0 updating cpsr */\n"
        code += tab + "mov x2, x2, ROR #0     /* x2 ← (carry_flag << 31) | (x2 >> 1) */\n".format(shift_unsigned)
        code += tab + "mov x0, x2, LSR #{0}     /* x0 ← x2 >> {0} */\n".format(shift_unsigned)
    elif shift_unsigned > 0:
        code += tab + "mov x0, x2, LSR #{0}     /* x0 ← x2 >> {0} */\n".format(shift_unsigned)
    code += tab + "
//  mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 
                  /* leave function */\n"
    code += tab + ".align 4\n"
    code += tab + "{0}: .word 0x{1:x}\n".format(magic_number_name, magic_unsigned)

    print code
else:
    print "Operation {} not implemented".format(operation)
