# read-records.s
# From pp 108-110 of Programming from the Ground Up; 64 bit version
# 

.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
# .comm record_buffer, RECORD_SIZE
record_buffer_ptr:
.quad 0

.section .text
.globl _start
_start:
  # Local variables that we will push onto the stack
  .equ ST_INPUT_DESCRIPTOR, -8
  .equ ST_OUTPUT_DESCRIPTOR, -16

  # Copy the stack pointer to %rbp
  movq %rsp, %rbp

  # Allocate space on the stack to hold the file descriptors
  subq $16, %rsp

  # Initialize the memory manager
  call allocate_init

  # Allocate enough memory to hold a record
  movq $RECORD_SIZE, %rdi
  call allocate
  movq %rax, record_buffer_ptr

  # Open the file
  movq $SYS_OPEN, %rax
  movq $file_name, %rdi
  # Use 0 for the flags, which means open read-only
  movq $0, %rsi
  movq $0666, %rdx
  syscall

  # System calls always put their return values in %rax;
  # save our return value to our local variable
  movq %rax, ST_INPUT_DESCRIPTOR(%rbp)

  # Even though it's a constant, we are saving the output
  # file descriptor to a local variable so that if we later
  # decide that it isn't always going to be STDOUT, we can
  # change it easily.
  movq $STDOUT, ST_OUTPUT_DESCRIPTOR(%rbp)

record_read_loop:
  movq ST_INPUT_DESCRIPTOR(%rbp), %rdi
  movq record_buffer_ptr, %rsi
  call read_record

  # Returns the number of bytes read in %rax
  # If it isn't the same number we requested,
  # then it's either and EOF or an error, so
  # we quit.
  cmpq $RECORD_SIZE, %rax
  jne finished_reading

  # Otherwise, printout the first name,
  # after determining its size.
  ## movq $RECORD_FIRSTNAME + record_buffer, %rdi
  movq record_buffer_ptr, %rdi
  addq $RECORD_FIRSTNAME, %rdi
  call count_chars

  # The length is returned in %rax, so put it in the third arg
  # of a write syscall
  movq %rax, %rdx
  movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
  movq $SYS_WRITE, %rax
  ## movq $RECORD_FIRSTNAME + record_buffer, %rsi
  movq record_buffer_ptr, %rsi
  addq $RECORD_FIRSTNAME, %rsi
  syscall

  movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
  call write_newline

  jmp record_read_loop

finished_reading:

  # Deallocate the memory we used
  movq record_buffer_ptr, %rdi
  call deallocate

  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall

#  C call: RDI, RSI, RDX, RCX, R8, R9
# Syscall: RDI, RSI, RDX, R10, R8, R9
