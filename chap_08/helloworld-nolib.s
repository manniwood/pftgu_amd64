#
# helloworld-nolib.s
#
# From pp 130,131 of Programming from the Ground Up; 64 bit version
#
# Build with build_helloworld-nolib.sh, in this same directory.

.include "linux.s"

.section .data

helloworld:
  .ascii "hello world\n"
helloworld_end:

  .equ helloworld_len, helloworld_end - helloworld

  .section .text
  .globl _start
_start:
  movq $SYS_WRITE, %rax
  movq $STDOUT, %rdi
  movq $helloworld, %rsi
  movq $helloworld_len, %rdx
  syscall

  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall

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
