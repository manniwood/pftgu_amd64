#
# error-exit.s
#
# From pp 123,124 of Programming from the Ground Up; 64 bit version

.include "linux.s"

.globl error_exit
.type error_exit, @function
error_exit:
  # Local variables that we will push onto the stack
  .equ ST_ERROR_CODE, -8
  .equ ST_ERROR_MSG, -16

  # push our base pointer onto the stack
  pushq %rbp
  # make the base pointer point at stack top
  movq %rsp, %rbp

  # Allocate stack space for two local vars,
  # the error code ptr, and the error message ptr
  subq $16, %rsp
  # NOTE that later, a `leave` would
  # put the stack pointer back to the base,
  # but because we are exiting here anyway,
  # we won't bother.

  # Put the two args to this function,
  # error code ptr and error message ptr,
  # into their local variables.
  movq %rdi, ST_ERROR_CODE(%rbp)
  movq %rsi, ST_ERROR_MSG(%rbp)

  ## write out error code

  # I realize the error code is still already in
  # %rdi, but copy the local var into the first
  # sysarg register to be pedantic.
  movq ST_ERROR_CODE(%rbp), %rdi
  call count_chars
  # The length of the arg in %rdi awaits us in %rax,
  # so put it in the third arg of a write syscall.
  movq %rax, %rdx
  movq $SYS_WRITE, %rax
  # Put our error code ptr into the second syscall arg
  movq ST_ERROR_CODE(%rbp), %rsi
  # Put stderr file descriptor in first arg
  movq $STDERR, %rdi
  syscall

  ## write out error message

  movq ST_ERROR_MSG(%rbp), %rdi
  call count_chars
  # The length of the arg in %rdi awaits us in %rax,
  # so put it in the third arg of a write syscall.
  movq %rax, %rdx
  movq $SYS_WRITE, %rax
  # Put our error message ptr into the second syscall arg
  movq ST_ERROR_MSG(%rbp), %rsi
  # Put stderr file descriptor in first arg
  movq $STDERR, %rdi
  syscall

  movq $STDERR, %rdi
  call write_newline

  ## exit with status 1
  movq $SYS_EXIT, %rax
  movq $1, %rdi
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
