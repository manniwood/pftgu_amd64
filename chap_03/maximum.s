#
# maximum.s
#
# From pp 32 and 33 of Programming from the Ground Up; 64 bit version
#
# Build with build_maximum.sh, in this same directory.
#
# Exits with a status code that holds the largest number from an
# array of numbers held in the data section of the ELF file.

.section .data

data_items:
# .quad is a compiler directive, saying there will be a list
# of quad (64 bit) words
.quad 3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text
.globl _start
_start:

# Move 0 into the index register
movq $0, %rdi

# Load the first number from data_items into %rax
movq data_items(,%rdi,8), %rax

# Also move the first number into %rbx, which holds
# the largest number. We are on the first number, so
# guess what? It's the biggest number so far!
movq %rax, %rbx

start_loop:
  # Does %rax hold 0? Because, of our data_items, we are using 0 as
  # a sentry value to mean stop. cmpq has a side effect: it sets status
  # flags in the RFLAGS register, according to the results of the comparison.
  # Note that RFLAGS starts with an R just like all the other 64-bit registers,
  # but back in 32-bit days, it was EFLAGS, and before that, just FLAGS.
  cmpq $0, %rax

  # If the RFLAGS register says the previous comparison was equal,
  # we jump to loop_exit. (So in this case, we exit if we have read
  # the 0 sentry value in data_items.)
  je loop_exit

  # Increment the value in %rdi by one. In our case, it means
  # we want %rdi to point to the next item in data_items.
  incq %rdi

  # Move the item in data_items at the index/offset %rdi into
  # the %rax register.
  movq data_items(,%rdi,8), %rax

  # Compare the contents of %rbx (our current largest value) with
  # the value in %rax and set appropriate status flags in the RFLAGS register.
  cmpq %rbx, %rax

  # Jump to start_loop if %rax was less than or equal to %rbx
  jle start_loop

  # Looks like %rax was larger than %rbx, meaning we have a new
  # largest value. Put that largest value into %rbx.
  movq %rax, %rbx

  # Jump to start loop
  jmp start_loop

loop_exit:
  # Be sure the largest number, currently in %rbx, gets moved
  # to %rdi, because even though we were using %rdi for the index
  # into _data_items, Linux's exit system call uses %rdi for its
  # first (and only) argument, and we want to make the largest number
  # the exit value of our program.
  movq %rbx, %rdi
  movq $60, %rax
  syscall

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
