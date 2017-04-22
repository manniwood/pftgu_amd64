# PURPOSE: Simple program that exits and returns a status code
#          back to the linux kernel

# INPUT:   none

# OUTPUT:  Returns a status code. This can be viewed by typing
#          echo $?
#          after running the program

# VARIABLES:
# %eax holds the system call number
# %ebx holds the return status

.section .data

.section .text
.globl _start
_start:
movq $60, %rax
movq $0, %rbx
syscall

