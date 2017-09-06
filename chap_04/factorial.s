#
# factorial.s
#
# From pp 66 and 67 of Programming from the Ground Up; 64 bit version
#
# Build with build_factorial.sh, in this same directory.
#
# Computes the factorial for a given number and puts it in
# the exit status code that can be seen with $?
#
# Intended to illustrate functions and stack management, but
# the 64 bit intel linux calling convention uses registers
# for the first 6 function argments, so stack use won't come
# until we learn about local variables in functions.

# Nothing for the data section this time.
.section .data

.section .text
.globl _start

# We don't need to make the factorial function global unless we
# want to share it outside of this ELF file.
.globl factorial
_start:
  movq $4, %rdi         # first argument. We want the factorial of 4
  call factorial        # call the factorial function

  movq %rax, %rdi       # Our answer is in %rax, but we want to print
                        # it as the exit status, so put it into %rdi,
                        # the first arg for system calls.

  movq $60, %rax        # Now that %rax is free, put the system call
                        # for exit in %rax

  syscall               # Do the system call

# I forget exactly how this .type directive works, but obviously it's
# defining a function.
.type factorial, @function
factorial:
  pushq %rbp            # save the old base pointer
  movq %rsp, %rbp       # make the stack pointer the base pointer
  subq $8, %rsp         # make room to put our only argument, %rdi,
                        # in a local variable
  movq %rdi, -8(%rbp)   # put our only argument into its local variable
                        # on the stack

  movq -8(%rbp), %rax   # also put our local variable in the return
                        # register
  cmpq $1, %rax         # If the number is 1, that is our base case,
                        # so we return.
  je end_factorial

  decq %rax             # otherwise, decrease the value
  movq %rax, %rdi       # move our newly modified value into the first
                        # argument register for a call to factorial
  call factorial
  imulq -8(%rbp), %rax  # multiply our current value by the return value
                        # from the call to factorial, in %rax

end_factorial:
  leave                 # move the stack pointer back to the base
                        # pointer and pop the old base pointer into %rbp
  ret

# LEGEND
# ------
#
# C call:
#   args: RDI, RSI, RDX, RCX, R8, R9
#   return value in RAX
#
# Syscall:
#   syscall number in RAX
#   args: RDI, RSI, RDX, R10, R8, R9
#   syscall return value in RAX
#   destroyed registers: RCX and R11
