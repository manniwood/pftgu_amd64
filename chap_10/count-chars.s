#
# count-chars.s
#
# From pp 105-106 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64

.section .text
.type count_chars, @function
.globl count_chars

count_chars:
  pushq %rbp
  movq %rsp, %rbp

  # Counter starts at 0
  movq $0, %rcx
  # first argument can be found in %rdi
  movq %rdi, %rdx

count_loop_begin:
  # Grab the current char; NOTE the use of 'b' for byte
  movb (%rdx), %al
  # Is it null?
  cmpb $0, %al
  # If yes, we're done
  je count_loop_end
  # Otherwise, increment the counter and the pointer
  incq %rcx
  incq %rdx
  # Go back to the beginning of the loop
  jmp count_loop_begin

count_loop_end:
  # We're done; move the count into %rax (to be returned)
  movq %rcx, %rax

  popq %rbp
  ret

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
