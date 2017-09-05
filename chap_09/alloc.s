.section .data

### GLOBAL VARIABLES ###

# Points to the beginning of the memory we are managing.
heap_begin:
  .quad 0

# Points to one location past the memory we are managing.
current_break:
  .quad 0

### STRUCT INFO ###

# Size of space for memory region header
.equ HEADER_SIZE, 16

# Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0

# Location of the size field in the header
.equ HDR_SIZE_OFFSET, 8

### CONSTANTS ###

# Memory that has been geven out.
.equ UNAVAILABLE, 0

# Memory that is available to be given out.
.equ AVAILABLE, 1

# Syscall number for the break system call
.equ SYS_BRK, 12

.section .text

### FUNCTIONS ###

# Initializes our global variables.
.globl allocate_init
.type allocate_init,@function
allocate_init:
  # Standard enter function stuff
  pushq %rbp
  movq %rsp, %rbp

  # Find out where the system break is...
  movq $SYS_BRK, %rax
  # ... by asking for the system break to advance by 0 bytes
  movq $0, %rdi
  syscall

  # Now %rax has the memory address of the system break.
  
  # Store the current break
  movq %rax, current_break

  # Store the current break as our first address.
  # This will cause the allocate funcion to get more
  # memory from the kernel the first time it is run.
  movq %rax, heap_begin

  # Standard leave function stuff
  movq %rbp, %rsp
  popq %rbp
  ret

.globl allocate
.type allocate,@function
allocate:
  # Standard enter function stuff
  pushq %rbp
  movq %rsp, %rbp

  # move our first argument into rcx,
  # which will hold the size we are looking for.
  movq %rdi, %rcx

  # rax will hold the current search location
  movq heap_begin, %rax

  # rbx will hold the current system break
  movq current_break, %rbx

# Iterate through each memory region
alloc_loop_begin:
  # Need more memory if these are equal
  cmpq %rbx, %rax
  je move_break

  # Grab the size of this memory chunk
  movq HDR_SIZE_OFFSET(%rax), %rdx

  # If the space is unavailable, go to the next block
  cmpq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
  je next_location

  # If the space is available, see if it is big
  # enough.
  cmpq %rdx, %rcx
  # if it is <= to the needed size, go to allocate_here
  # otherwise you can see we fall through to next_location
  # which sends us to alloc_loop_begin after doing some math
  jle allocate_here

next_location:
  # The total size of the memory region is 
  # the sum of the size requested (currently
  # in %rdx) plus another 16 bytes for the header
  # (8 for the available/unavailable flag,
  # 8 more for the size of the region). So, adding
  # %rdx and $16 to %rax will get the address of
  # the next memory region.
  addq $HEADER_SIZE, %rax
  addq %rdx, %rax
  
  # Go look at the next location
  jmp alloc_loop_begin

allocate_here:
  # If we've made it here, that means the region header
  # of the region to aloocate is in %rax

  # Mark space as unavailable, because we are about to
  # loan it out.
  movq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)

  # Move %rax past the header to the usable memory
  # (since that's what we return)
  addq $HEADER_SIZE, %rax

  # Return from the function
  movq %rbp, %rsp
  popq %rbp
  ret

move_break:
  # If we've made it here, that means that we have exhausted
  # all addressable memory, and we need to ask for more.
  # %rbx holds the current endpoint of the data, and
  # %rcx holds its size.

  # We need to increase %rbx to where we _want_ memory
  # to end, so we add space for the headers structure
  addq $HEADER_SIZE, %rbx

  # Add space to the break for the data requested
  addq %rcx, %rbx

  # Ask the kernal for more memory

  # Save needed registers
  pushq %rax
  pushq %rcx
  pushq %rbx

  movq $SYS_BRK, %rax
  movq %rbx, %rdi
  syscall

  # Under normal conditions, this should return the new break
  # in %rax, which will be either 0 if it fails, or equal to
  # or larger than what we asked for.

  # Check for error
  cmpq $0, %rax
  je error

  # restore saved registers
  popq %rbx
  popq %rcx
  # Interesting, clobbers return value in %rax
  popq %rax

  # Set this memory as unavailable, since we're about to
  # loan it out.
  movq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
  # Set the size of the memory
  movq %rcx, HDR_SIZE_OFFSET(%rax)

  # Move %rax to the actual start of usable memory.
  # %rax now holds this function's return value.
  addq $HEADER_SIZE, %rax

  # Save the new break
  movq %rbx, current_break

  # Return from the function
  movq %rbp, %rsp
  popq %rbp
  ret

error:
  # On error, we return 0
  movq $0, %rax

  # Return from the function
  movq %rbp, %rsp
  popq %rbp
  ret

.globl deallocate
.type deallocate,@function
deallocate:
  # Since the function is so simple, don't bother with
  # any of the usual stack maintenance stuff.
  
  # Get the address of the memory to free. It is our
  # first arg.
  movq %rdi, %rax

  # Get the pointer to the real beginning of the segment
  subq $HEADER_SIZE, %rax

  # Mark it as available
  movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax)

  # Return
  ret

# C call: RDI, RSI, RDX, RCX, R8, R9
#
# Syscall:
#   syscall number in RAX
#   args: RDI, RSI, RDX, R10, R8, R9
#   syscall return value in RAX

