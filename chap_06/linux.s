#
# linux.s
#
# From pp 96,97 of Programming from the Ground Up; 64 bit version

# system call numbers
.equ SYS_READ, 0
.equ SYS_WRITE, 1
.equ SYS_OPEN, 2
.equ SYS_CLOSE, 3
.equ SYS_BRK, 12
.equ SYS_EXIT, 60


# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ END_OF_FILE, 0

