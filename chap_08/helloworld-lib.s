#
# helloworld-lib.s
#
# From pp 131,132 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64
#
# Build with build_helloworld-lib.sh, in this same directory.

.section .data

helloworld:
.ascii "hello world\n\0"

.section .text

.globl _start
_start:
  movq $helloworld, %rdi
  movq $0, %rax  # 0 floating point parameters to printf
  call printf

  movq $0, %rdi
  call exit

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
