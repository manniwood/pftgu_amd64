#
# read-records.s
#
# From pp 108-110 of Programming from the Ground Up, by Jonathan Bartlett
# but translated to amd64
#
# Build with build_read_records.sh, in this same directory.

.include "linux.s"
.include "record-def.s"

.section .data
file_name:
.ascii "test.dat\0"

.section .bss
.comm record_buffer, RECORD_SIZE

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
  movq $record_buffer, %rsi
  call read_record

  # Returns the number of bytes read in %rax
  # If it isn't the same number we requested,
  # then it's either and EOF or an error, so
  # we quit.
  cmpq $RECORD_SIZE, %rax
  jne finished_reading

  # Otherwise, printout the first name,
  # after determining its size.
  movq $RECORD_FIRSTNAME + record_buffer, %rdi
  call count_chars

  # The length is returned in %rax, so put it in the third arg
  # of a write syscall
  movq %rax, %rdx
  movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
  movq $SYS_WRITE, %rax
  movq $RECORD_FIRSTNAME + record_buffer, %rsi
  syscall

  movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
  call write_newline

  jmp record_read_loop

finished_reading:
  movq $SYS_EXIT, %rax
  movq $0, %rdi
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
