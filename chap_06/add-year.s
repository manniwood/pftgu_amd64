.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
.ascii "test.dat\0"

output_file_name:
.ascii "testout.dat\0"

.section .bss
.comm record_buffer, RECORD_SIZE

# Local variables that we will push onto the stack
.equ ST_INPUT_DESCRIPTOR, -8
.equ ST_OUTPUT_DESCRIPTOR, -16

# In the book, it's 0101
.equ O_CREAT_WRONLY_TRUNC, 01101

.section .text
.globl _start

_start:
  # Copy the stack pointer to %rbp
  # (base pointer now points to same address
  # as stack pointer)
  movq %rsp, %rbp

  # Allocate space on the stack to hold the file descriptors
  subq $16, %rsp

  # Open file for reading
  movq $SYS_OPEN, %rax
  movq $input_file_name, %rdi
  # Use 0 for the flags, which means open read-only
  movq $0, %rsi
  movq $0666, %rdx
  syscall

  # System calls always put their return values in %rax;
  # save our return value to our local variable
  movq %rax, ST_INPUT_DESCRIPTOR(%rbp)

  # Open file for writing
  # put open syscall number in correct register
  movq $SYS_OPEN, %rax
  # put the output file name in the first syscall arg slot
  movq $output_file_name, %rdi
  # read/write-only flag goes into flags argument
  movq $O_CREAT_WRONLY_TRUNC, %rsi
  # 0666 goes into mode argument
  movq $0666, %rdx
  syscall

  # System calls always put their return values in %rax;
  # save our return value to our local variable
  movq %rax, ST_OUTPUT_DESCRIPTOR(%rbp)

loop_begin:
  movq ST_INPUT_DESCRIPTOR(%rbp), %rdi
  movq $record_buffer, %rsi
  call read_record

  # Returns the number of bytes read in %rax
  # If it isn't the same number we requested,
  # then it's either and EOF or an error, so
  # we quit.
  cmpq $RECORD_SIZE, %rax
  jne loop_end

  # increment the age. We are incrementing the quad
  # word at the address of the record_buffer
  # plus the offset to the age field.
  incq record_buffer + RECORD_AGE

  # Write the record out
  movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
  movq $record_buffer, %rsi
  call write_record

  jmp loop_begin

loop_end:
  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall
