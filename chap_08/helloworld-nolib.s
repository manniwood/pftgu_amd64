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

#  C call: RDI, RSI, RDX, RCX, R8, R9
# Syscall: RDI, RSI, RDX, R10, R8, R9
