# PURPOSE: Simple program that exits and returns a status code
#          back to the linux kernel

# INPUT:   none

# OUTPUT:  Returns a status code. This can be viewed by typing
#          echo $?
#          after running the program

# VARIABLES:
# %rax holds the system call number
# %rdi holds the return status

.section .data

.section .text
.globl _start
_start:

# 60 is the system call number (linux kernel command number) for exit.
# It needs to go in rax, because that's where syscall expects to find it.
movq $60, %rax

# 0 is the status number we will return
movq $0, %rdi

# Spiffy! Assembler for x86 linux has a syscall instruction!
syscall

# This is an excellent resource on linux x86 syscall conventions:
# http://stackoverflow.com/questions/2535989/
#   what-are-the-calling-conventions-for-unix-linux-system-calls-on-x86-64
# But here it is in a nutshell:
#
# User-level applications use as integer registers for passing the
#   sequence %rdi, %rsi, %rdx, %rcx, %r8 and %r9.
# The kernel interface uses %rdi, %rsi, %rdx, %r10, %r8 and %r9.
# A system-call is done via the syscall instruction.
# The kernel destroys registers %rcx and %r11.
# The number of the syscall has to be passed in register %rax.
# System-calls are limited to six arguments;
#   no argument is passed directly on the stack.
# Returning from the syscall, register %rax contains the result of the system-call.
# A value in the range between -4095 and -1 indicates an error, it is -errno.
# Only values of class INTEGER or class MEMORY are passed to the kernel.



