#
# toupper.s
#
# From pp 81 - 87 of Programming from the Ground Up; 64 bit version
#
# Build with build_toupper.sh, in this same directory.
#
# Also, you will need to run this with two arguments,
# so when you need to run it using gdb, do this to
# make the arguments work:
#
# $ gdb --args ./toupper test_file.txt new_file.txt
#
# Intended to show file management through linux system calls
# from assembly. All of the system calls are numbered differently
# in 64 bit linux.
#
# Also introduces us to the .equ compiler directive

.section .data
# system call numbers
.equ SYS_OPEN, 2
.equ SYS_WRITE, 1
.equ SYS_READ, 0
.equ SYS_CLOSE, 3
.equ SYS_EXIT, 60

# options for open; described more in the linux source at
# include/uapi/asm-generic/fcntl.h. You can combine them
# by adding them or ORing them.
.equ O_RDONLY, 0
# In the book, it's 03101, but I think TRUNC became 1000, not 3000,
# with 64 bit.
.equ O_CREAT_WRONLY_TRUNC, 01101

# standard file descriptors
.equ STDIN, 0
.equ STOUT, 1
.equ STERR, 2

# This is the return value of read, which means
# we've hit the end of the file
.equ END_OF_FILE, 0

.equ NUMBER_ARGUMENTS, 2

.section .bss
# This buffer is where data are loaded into from the data file
# and written to the output file. Apparently, exceeding 16,000
# is a bad idea for various reasons.
.equ BUFFER_SIZE, 500
.comm BUFFER_DATA, BUFFER_SIZE

.section .text

# stack posiitons
# notice how these are all double their 32 bit versions
.equ ST_SIZE_RESERVE, 16
.equ ST_FD_IN, -8
.equ ST_FD_OUT, -16
.equ ST_ARGC, 0  # number of command line args
.equ ST_ARGV_0, 8  # name of program
.equ ST_ARGV_1, 16 # input file name
.equ ST_ARGV_2, 24 # output file name

.globl _start
_start:
  # save the stack pointer; the base pointer points to where
  # the stack pointer points
  movq %rsp, %rbp

  # Allocate space on the stack for our local vars:
  # the file descriptors
  subq $ST_SIZE_RESERVE, %rsp

# Here, we are reminded that Linux's 64-bit system calling
# convention uses registers in a different order than 32-bit
# Linux. The 64-bit Linux syscall args go into registers in
# the following order:
# syscall number goes into %rax
# Args go in this order: %rdi, %rsi, %rdx, %r10, %r8, %r9
# The result is returned in %rax

open_files:
open_fd_in:
  ### open input files ###
  # put open syscall number in correct register
  movq $SYS_OPEN, %rax
  # The input filename is the first command line arg;
  # put it in the first syscall arg slot
  movq ST_ARGV_1(%rbp), %rdi
  # read-only flag goes into flags argument
  movq $O_RDONLY, %rsi
  # 0444 goes into mode argument
  movq $0444, %rdx
  syscall

store_fd_in:
  # save the file descriptor that we got back into our local
  # variable on the stack:
  movq %rax, ST_FD_IN(%rbp)

open_fd_out:
  ### open output file ###
  # put open syscall number in correct register
  movq $SYS_OPEN, %rax
  # The output filename is the second command line arg;
  # put it in the first syscall arg slot
  movq ST_ARGV_2(%rbp), %rdi
  # write-enabled flags go into flags argument
  movq $O_CREAT_WRONLY_TRUNC, %rsi
  # use a permissive mode to allow writing/creating the file
  movq $0666, %rdx
  syscall

store_fd_out:
  # save the file descriptor that wew got back into our local
  # variable on the stack:
  movq %rax, ST_FD_OUT(%rbp)

### begin main loop ###
read_loop_begin:

  ### read a block from the input file ###
  movq $SYS_READ, %rax
  # use our input file descriptor
  movq ST_FD_IN(%rbp), %rdi
  # tell it to read into our buffer
  movq $BUFFER_DATA, %rsi
  # tell it how many bytes to read into our buffer
  movq $BUFFER_SIZE, %rdx
  syscall
  # now the number of bytes read is waiting in %rax

  ### exit if we have reached the end ###
  # check for EOF marker
  cmpq $END_OF_FILE, %rax
  # if EOF, or if an error (errors are negative ints),
  # go to the end
  jle end_loop

continue_read_loop:
  ### convert the block uppercase ###
  # put the location of the buffer into convert_to_upper's arg1
  movq $BUFFER_DATA, %rdi
  # put the size of the buffer into convert_to_upper's arg2
  movq %rax, %rsi
  # save the size of the buffer on the stack, in case
  # calling convert_to_upper clobbers %rax
  pushq %rax
  call convert_to_upper
  # restore size of buffer into %rax
  popq %rax

  ### write the block to the outpuf file ###
  # let's put the size of the buffer into %rdx first,
  # because we need to write our system call number into %rax next
  movq %rax, %rdx
  movq $SYS_WRITE, %rax
  movq ST_FD_OUT(%rbp), %rdi
  movq $BUFFER_DATA, %rsi
  syscall

  ### continue the loop ###
  jmp read_loop_begin

end_loop:
  ### close the files ###
  movq $SYS_CLOSE, %rax
  movq ST_FD_OUT(%rbp), %rdi
  syscall
  movq $SYS_CLOSE, %rax
  movq ST_FD_IN(%rbp), %rdi
  syscall

  ### exit ###
  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall

.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 'A' - 'a'

convert_to_upper:
  pushq %rbp
  movq %rsp, %rbp

  ### set up variables ###
  # translation of 32 bit vars used in the book
  # to registers I will be using:
  # %eax --> %rdi  # buffer data pointer
  # %ebx --> %rsi  # size of buffer
  # %edi --> %rdx  # current byte offset of buffer
  # %cl  --> %cl (first byte of %rcx) # current byte of buffer
  # Note that %rdi and %rsi are already populated
  # as the first two args to our function; furthermore,
  # we hijack %rdx (usually used for a third function arg
  # if there is one) to keep track of our offset; so much
  # easier than using the stack. We hijack the lowest byte
  # of %rcx (usually the 4th arg) to do the same thing
  movq $0, %rdx

  # If a buffer of zero length was given to us, leave
  cmpq $0, %rsi
  je end_convert_loop

convert_loop:
  # get the current byte (NOTE the 'b' in movb! we need only a byte!)
  # Oh, interesting! Also note the use of register %cl, which
  # is only one byte large! It is the first byte of %rcx, which
  # is usually the 4th arg of a function, but we are not using that
  # 4th arg, so we can hijack that register for our own uses here.
  movb (%rdi, %rdx, 1), %cl
  
  # go to the next byte unless it is between 'a' and 'z'
  # Note again the use of 'b' in cmpb!
  cmpb $LOWERCASE_A, %cl
  jl next_byte
  cmpb $LOWERCASE_Z, %cl
  jg next_byte

  # otherwise, conert the byte to uppercase
  addb $UPPER_CONVERSION, %cl
  # and store it back
  movb %cl, (%rdi, %rdx, 1)

next_byte:
  incq %rdx

  # now that we have incremened %rdx, have we reached the end?
  # If it is equual to %rsi, the size of the buffer, we have reached
  # the end.
  cmpq %rdx, %rsi
  jne convert_loop

end_convert_loop:
  # no return value; just leave
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
