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
  
  # Now %rax has the memory address of the system break.
  # Let's put it into both of our local varaiables on
  # the stack, one of which we will leave alone,
  # and one which we will modify.
  movq %rax, ST_ORIG_SYS_BRK(%rbp)
  movq %rax, ST_NEW_SYS_BRK(%rbp)
  
  # Ask the kernel to move the sytem break by
  # 16 bytes. First, add 16 to the current system
  # break address that we stored in %r12
  addq $16, ST_NEW_SYS_BRK(%rbp)
  
  # Now actually ask Linux to move the system break
  movq $SYS_BRK, %rax
  movq ST_NEW_SYS_BRK(%rbp), %rdi
  syscall
  
  # Now %rax has the memory address of the new system break,
  # or 0 if it failed to allocate more memory.
  # (This pretty much never happens anymore, because
  # Linux is just as happy to over-prescribe memory.)
  cmpq $0, %rax
  jne carry_on
  
exit_sadly:
  movq $SYS_EXIT, %rax
  movq $1, %rdi
  syscall
  
carry_on:
  # If we got here, we have moved our system break,
  # and its new value is in %rax. Let's move that memory
  # address to our local variable, and then let's store an integer at
  # the memory address that begins our heap; where our
  # system break originally was.
  movq %rax, ST_NEW_SYS_BRK(%rbp)

  # It's a shame this has to be done in two steps.
  # Move the address from the tmp var into r11
  movq ST_ORIG_SYS_BRK(%rbp), %r11
  # Move 92 into the address pointed to by r11.
  # That address is at the start of the heap.
  movq $92, (%r11)
  
  # In fact, let's use that integer as our exit code,
  # so we can prove to ourselves that we successfully
  # moved the system break, stored a value there, and
  # were able to read it back.
  movq $SYS_EXIT, %rax
  movq (%r11), %rdi
  syscall
