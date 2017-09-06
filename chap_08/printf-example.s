#
# helloworld-lib.s
#
# From pp 136,137 of Programming from the Ground Up; 64 bit version
#
# Build with build_printf-example.sh, in this same directory.

.section .data

firststring:
  .ascii "Hello, %s is a %s who loves the number %d\n\0"

name:
  .ascii "Manni\0"

personstring:
  .ascii "person\0"

# This could also have been an .equ, but for fun,
# let's give it a real memory location.
numberloved:
  .long 3

.section .text
.globl _start
_start:
  movq $firststring, %rdi
  movq $name, %rsi
  movq $personstring, %rdx
  movq numberloved, %rcx
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
