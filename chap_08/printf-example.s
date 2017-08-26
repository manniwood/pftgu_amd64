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

#  C call: RDI, RSI, RDX, RCX, R8, R9
# Syscall: RDI, RSI, RDX, R10, R8, R9
