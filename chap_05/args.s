# This is not in the book; it is an exploration of printing
# command line args

# From
# https://stackoverflow.com/questions/
#    3683144/linux-64-command-line-parameters-in-assembly:
#
# and
# http://eli.thegreenplace.net/2013/07/24/displaying-all-argv-in-x64-assembly
# 
# (%rsp) -> number of arguments
# 8(%rsp) -> address of the name of the executable
# 16(%rsp) -> address of the first command line argument (if exists)
# ... so on ...

.section .data
newline:
  .ascii "\n"

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
  # the first byte of the arg we want to print
  # first local variable on the stack. Remember,
  # for a leaf function, we don't need to subtract
  # from the stack pointer; we can just chuck our
  # local vars at negative offsets from the base pointer.
  movq %rdi, -8(%rbp)

  # Let's get the length of the string by finding the address
  # of its terminating null and then subtracting that address
  # from the start address.

  # %rdi still has our first arg, which is the address
  # of the first char of the arg. Copy the address into r12,
  # which we will advance until we find '\0'
  movq %rdi, %r12
find_null:
  cmpb $0, (%r12)
  je end_find_null
  # we have not yet found '\0', so increment the address to
  # point to the next byte
  inc %r12
  jmp find_null
end_find_null:
  # r12 points to '\0', so r12-rdi is the length
  # store the length in %r12
  sub %rdi, %r12

  # print the arg
  movq $1, %rax
  movq $1, %rdi
  movq -8(%rbp), %rsi
  movq %r12, %rdx
  syscall

  # print a newline
  movq $1, %rax
  movq $1, %rdi
  movq $newline, %rsi
  movq $1, %rdx
  syscall

  # restore the base pointer
  popq %rbp
  ret
