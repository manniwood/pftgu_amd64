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

#  C call: RDI, RSI, RDX, RCX, R8, R9
# Syscall: RDI, RSI, RDX, R10, R8, R9

