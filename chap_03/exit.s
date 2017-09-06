#
# exit.s
#
# From page 20 of Programming from the Ground Up; 64 bit version
#
# Build with build_exit.sh, in this same directory.
#
# Exits with a status code that can be seen with $?

# This program is so simple, there's nothing in the .data section
.section .data

# The text is the executable instructions part of the ELF binary
# that gets built.
.section .text
# We need the _start address/label to be visible to the outside world.
.globl _start
# By convention, an ELF binary starts executing at the _start address/label.
_start:

# 60 is the system call number (linux kernel command number) for exit.
# It needs to go in rax, because that's where syscall expects to find it.
# All of the system call numbers are listed in the linux kernel at
# arch/x86/entry/syscalls/syscall_64.tbl. Another useful online resource is
# http://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/
movq $60, %rax

# 0 is the status number we will return
movq $0, %rdi

# Assembler for 64 bit linux has a syscall instruction. This is nicer
# than 32 bit, which uses an interrupt to make a syscall.
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
# Returning from the syscall, register %rax contains the result of the
# system-call.
# A value in the range between -4095 and -1 indicates an error, it is -errno.
# Only values of class INTEGER or class MEMORY are passed to the kernel.



