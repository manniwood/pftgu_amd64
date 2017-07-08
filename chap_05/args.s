# This is not in the book; it is an exploration of printing
# command line args

# From
# https://stackoverflow.com/questions/
#    3683144/linux-64-command-line-parameters-in-assembly:
# 
# (%rsp) -> number of arguments
# 8(%rsp) -> address of the name of the executable
# 16(%rsp) -> address of the first command line argument (if exists)
# ... so on ...

.section .text
.globl _start
_start:
  # make the base pointer point at the stack pointer
  movq %rsp, %rbp

  # put the address of argv[0] into the first argument of print_arg
  movq 8(%rbp), %rdi
  call print_arg

  movq $60, %rax
  movq $0, %rdi
  syscall

.type print_arg, @function
print_arg:
  # save the old base pointer
  pushq %rbp
  # make the base pointer point at the stack pointer
  movq %rsp, %rbp
  # %rdi is our first arg, which is the address of
  # the arg we want to print; let's save it as our
  # first local variable on the stack. Remember,
  # for a leaf function, we don't need to subtract
  # from the stack pointer; we can just chuck our
  # local vars at negative offsets from the base pointer.
  movq %rdi, -8(%rbp)

  # print the first char of the arg
  movq $1, %rax
  movq $1, %rdi
  movq -8(%rbp), %rsi
  movq $1, %rdx
  syscall

  # restore the base pointer
  popq %rbp
  ret
