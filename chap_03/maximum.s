# PURPOSE: Finds the maximum of a set of numbers

# VARIABLES: Here's how we are using the various registers:
# %rdi - Holds the index of the data item being examined
# %rbx - Largest data item found
# %rax - Current data item

.section .data

data_items:
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
  # flags in the EFLAGS register, according to the results of the comparison.
  cmpq $0, %rax

  # If the EFLAGS register says the previous comparison was equal,
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
  # the value in %rax and set appropriate status flags in the EFLAGS register.
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


