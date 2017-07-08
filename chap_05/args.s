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

  # put the number of arguments in $r12; that is, argc is in %r12
  movq (%rsp), %r12

  # put the address of argv[0] into the first argument of print_arg
  # movq 8(%rsp), %rdi
  # put the address of an argument into the first argument of print_arg
  movq $0, %r13
.L_argv_loop:
  movq 8(%rsp, %r13, 8), %rdi
  call print_arg
  incq %r13
  cmpq %r12, %r13
  jl .L_argv_loop

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
  # of the first char of the arg. Copy the address into r10,
  # which we will advance until we find '\0'
  # NOTE that we pick r10 because it does not conflict with
  # r12 and r13, which we are using in _start
  movq %rdi, %r10
.L_find_null:
  # NOTE the use of cmpb; the b in cmpb means byte;
  # we are comparing a byte, that is, only the first
  # 8 bits of the 64 bits available in the %r10 register.
  cmpb $0, (%r10)
  je .L_end_find_null
  # we have not yet found '\0', so increment the address to
  # point to the next byte
  incq %r10
  jmp .L_find_null
.L_end_find_null:
  # r10 points to '\0', so r10-rdi is the length
  # store the length in %r10
  sub %rdi, %r10

  # print the arg
  movq $1, %rax
  movq $1, %rdi
  movq -8(%rbp), %rsi
  movq %r10, %rdx
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
