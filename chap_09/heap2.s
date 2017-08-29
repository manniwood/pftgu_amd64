.section .data
.equ SYS_EXIT, 60
.equ SYS_BRK, 12

# Offset of original system break local varable
.equ ST_ORIG_SYS_BRK, -8
# Offset of new system break local varable
.equ ST_NEW_SYS_BRK, -16

.section .text
.globl _start
_start:

  # save the stack pointer; the base pointer points to where
  # the stack pointer points
  movq %rsp, %rbp

  # Make room for our two local variables
  # on the stack
  subq $16, %rsp
  
  # syscall number goes into %rax
  # Args go in this order: %rdi, %rsi, %rdx, %r10, %r8, %r9
  # The result is returned in %rax
  
  # Find out where the system break is...
  movq $SYS_BRK, %rax
  # ... by asking for the system break to advance by 0 bytes
  movq $0, %rdi
  syscall
  
  # Now %rax has the last valid memory address before the system break.
  # Storing a 64 bit value there will still segfault.
  # movq $92, (%rax)

  # Let's save the original system break in a local var
  movq %rax, ST_ORIG_SYS_BRK(%rbp)

  # Let's increase the system break by 8 bytes.
  addq $8, %rax
  movq %rax, ST_NEW_SYS_BRK(%rbp)
  movq $SYS_BRK, %rax
  movq ST_NEW_SYS_BRK(%rbp), %rdi
  syscall

  # Now let's store a value at the address of the original
  # system break, because there are now 8 bytes of storage
  # beyond that adress.
  movq ST_ORIG_SYS_BRK(%rbp), %r12
  movq $92, (%r12)

  # Now let's try to exit
  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall
