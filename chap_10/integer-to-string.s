#
# integer-to-string.s
#
# From pp 205-208 of Programming from the Ground Up; 64 bit version
#
# %rcx will hold the count of characters processed
# %rax will hold the current value
# %rdi will hold the base (10)

# 9,223,372,036,854,775,807 is the largest 64-bit
# integer, so we need to be handed a 20-character
# array; 19 chars for the numbers, and one for the
# terminating null.

.globl integer2string
.type integer2string, @function
integer2string:
  # Usual function beginning
  pushq %rbp
  movq %rsp, %rbp

  # Current character count
  movq $0, %rcx

  # First arg, representing current value, will go into %rax
  movq %rdi, %rax

  # When we divide by 10, the 10 can't be
  # a bare literal; it has to be placed in a register
  # or memory location.
  movq $10, %rdi

conversion_loop:
  # Division is actually performed on the combined
  # %rdx:%rax registers, as though %rdx:%rax were
  # a 128 bit number, with the most significant bits
  # in %rdx. The dividend must go in those two registers;
  # we cannot choose others.
  # So first, clear out %rdx.
  movq $0, %rdx

  # Divide %rdx:%rax by 10, which we placed in %rdi.
  # The divisor can be placed in a register of our choosing.
  # The quotient will be in %rax, and the remainder
  # will be in %rdx.
  divq %rdi

  # %rdx has the remainder, which is a number ranging
  # from 0 to 9. We will convert this into
  # an ascii character, '0' through '9'. The easiest way to
  # do this is to take the ascii value '0' and add the
  # remainder to it, benifitting from the fact that
  # characters '0' through '9' are contiguous in ascii.
  addq $'0', %rdx

  # Now we take this char and push it onto the stack.
  # We are pushing the whole register, but we only need
  # the byte in %dl (the last byte of %rdx)
  pushq %rdx

  # Increment the digit count
  incq %rcx

  # Check to see if %rax, where the quotient is, is zero.
  cmpq $0, %rax
  je end_conversion_loop

  # %rax contains the quotient, which is exactly what we
  # want to divide by when we return to the start of the
  # loop again.
  jmp conversion_loop

end_conversion_loop:
  # The string is now on the stack. Pop it off one
  # character at a time, into our buffer.

  # By C calling convention, our second arg, a pointer
  # to a buffer, is in %rsi. Copy it to %rdx.
  movq %rsi, %rdx

copy_reversing_loop:
  # We pushed a whole register, but we only need the last
  # byte. Pop off to the entire %rax register, but then
  # only move the least sigificant byte, %al, into the
  # character string.
  popq %rax
  movb %al, (%rdx)

  # Decrease %rcx so that we know when we are finished.
  decq %rcx

  # Increase %rdx so that it will point to the next byte
  incq %rdx

  # Check to see if we are finished
  cmpq $0, %rcx

  # If done, jump to end of function
  je end_copy_reversing_loop

  # Else repeat the loop
  jmp copy_reversing_loop

end_copy_reversing_loop:
  # Write a null byte and return.
  movb $0, (%rdx)

  # Usual function finishing stuff.
  movq %rbp, %rsp
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
