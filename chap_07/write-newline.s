#
# write-newline.s
#
# From p 107 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64

.include "linux.s"
.globl write_newline
.type write_newline, @function

.section .data
newline:
.ascii "\n"

.section .text
write_newline:
  pushq %rbp
  movq %rsp, %rbp

  movq $SYS_WRITE, %rax
  # First argument can be found in %rdi
  # and is also the first argument to write syscall
  # movq %rdi, %rdi

  # Second argument is the newline char
  movq $newline, %rsi
  # Third argument is how many bytes to write;
  # we just want to write one byte.
  movq $1, %rdx
  syscall

  # Now the number of bytes written is waiting in %rax,
  # which also happens to be the return register for
  # function calls.

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
