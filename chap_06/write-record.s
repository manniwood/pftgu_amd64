# write-record.s
# From p 99 of Programming from the Ground Up; 64 bit version
# 

.include "record-def.s"
.include "linux.s"

.section .text
.globl write_record
.type write_record, @function

write_record:
  pushq %rbp
  movq %rsp, %rbp

  # first arg, file descriptor, is in %rdi,
  # second arg, write buffer, is in %rsi

  movq $SYS_WRITE, %rax
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

