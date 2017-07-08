# toupper.s
# From pp 81 - 87 of Programming from the Ground Up; 64 bit version
#
# Compile and link like so:
# $ as toupper.s -o toupper.o
# $ ld toupper.o -o toupper
#
# By this point, the gdb debugger comes in handy.
# Compile and link for a debugger like so:
# $ as --gstabs toupper.s -o toupper.o
# $ ld toupper.o -o toupper
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
.lcomm BUFFER_DATA, BUFFER_SIZE

.section text

# stack posiitons OK, time to go simpler; just write a program that
# prints the command line arguments to see if you can get that to work.
# One step at a time...


