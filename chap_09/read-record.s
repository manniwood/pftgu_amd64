#
# read-record.s
#
# From pp 97,98 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64
# 
# Should be compiled and linked with write-records.s

.include "record-def.s"
.include "linux.s"

.section .text
.globl read_record
.type read_record, @function

read_record:
  pushq %rbp
  movq %rsp, %rbp

  # first arg, file descriptor, is in %rdi,
  # second arg, read buffer, is in %rsi

  ### read a block from the input file ###
  movq $SYS_READ, %rax
  # First arg to our function is also the first arg to read syscall
  # movq %rdi, %rdi
  # Second arg to our function is also the second arg to read syscall
  # movq %rsi, %rsi
  # Third arg is from record-def.s
  movq $RECORD_SIZE, %rdx
  syscall
  # now the number of bytes read is waiting in %rax,
  # which also happens to be the return register for
  # function calls

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

