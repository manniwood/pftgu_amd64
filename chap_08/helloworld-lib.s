.section .data
helloworld:
.ascii "hello world\n\0"
.section .text
.globl _start
_start:
movq $helloworld, %rdi
xorq %rax, %rax  # 0 floating point parameters to printf
call printf
movq $0, %rdi
call exit
