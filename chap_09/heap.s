.section .data
.equ SYS_EXIT, 60
.equ SYS_BRK, 12

.section .text
.globl _start
_start:

# syscall number goes into %rax
# Args go in this order: %rdi, %rsi, %rdx, %r10, %r8, %r9
# The result is returned in %rax

# Find out where the system break is...
movq $SYS_BRK, %rax
# ... by asking for the system break to advance by 0 bytes
movq $0, %rdi
syscall

# Now %rax has the memory address of the system break
# Let's put in in %r12.
movq %rax, %r12

# Ask the kernel to move the sytem break by
# 16 bytes. First, add 16 to the current system
# break address that we stored in %r12
addq $16, %r12

# Now actually ask Linux to move the system break
movq $SYS_BRK, %rax
movq %r12, %rdi
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
# address to %r12, and then let's store an integer at
# that memory address.
movq %rax, %r12
movq $92, (%r12)

# In fact, let's use that integer as our exit code,
# so we can prove to ourselves that we successfully
# moved the system break, stored a value there, and
# were able to read it back.
# (TODO: use the difference between the new and
# old system break as the return value so you can
# see how much Linux actually moved the system break.)
movq $SYS_EXIT, %rax
movq (%r12), %rdi
syscall
