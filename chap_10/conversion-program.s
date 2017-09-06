.include "linux.s"

.section .data

tmp_buffer:
.ascii "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

.section .text
.globl _start
_start:

  movq %rsp, %rbp

  # Number to convert is first arg to integer2string
  movq $824, %rdi

  # tmp buffer is second arg to integer2string
  movq $tmp_buffer, %rsi

  call integer2string

  # Get the character count for our system call
  movq $tmp_buffer, %rdi

  call count_chars

  # Answer from count_chars is in %rax and we want to
  # use it as the 3rd ard to sys_write, so store in %rdx
  movq %rax, %rdx
  movq $STDOUT, %rdi
  movq $tmp_buffer, %rsi
  movq $SYS_WRITE, %rax
  syscall

  # Write a carriage return
  movq $STDOUT, %rdi
  call write_newline

  # Exit
  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall
