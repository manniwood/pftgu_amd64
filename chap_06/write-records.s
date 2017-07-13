# write-records.s
# From pp 100-103 of Programming from the Ground Up; 64 bit version
# 
# compile like so:
# $ as write-record.s -o write-record.o
# $ as write-records.s -o write-records.o
# $ ld write-record.o write-records.o -o write-records

.include "linux.s"
.include "record-def.s"

.section .data

record1:
  .ascii "Fredrick\0"
  .rept 31 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "Bartlett\0"
  .rept 31 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "4242 S Prairie\nTulsa, OK 55555\0"
  .rept 209 #Padding to 240 bytes
  .byte 0
  .endr

  .quad 45

record2:
  .ascii "Marilyn\0"
  .rept 32 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "Taylor\0"
  .rept 33 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "2224 S Johannan St\nChicago, IL 12345\0"
  .rept 203 #Padding to 240 bytes
  .byte 0
  .endr

  .quad 29

record3:
  .ascii "Derrick\0"
  .rept 32 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "McIntire\0"
  .rept 31 #Padding to 40 bytes
  .byte 0
  .endr

  .ascii "500 W Oakland\nSan Diego, CA 54321\0"
  .rept 206 #Padding to 240 bytes
  .byte 0
  .endr

  .quad 36

file_name:
  .ascii "test.dat\0"
  # .asciz "test.dat"

.section .text

.equ ST_FILE_DESCRIPTOR, -8
# In the book, it's 0101
.equ O_CREAT_WRONLY_TRUNC, 01101

.globl _start
_start:
  
  movq %rsp, %rbp
  # allocate space to hold the file descriptor in a local var
  subq $8, %rsp

  # open the file
  # put open syscall number in correct register
  movq $SYS_OPEN, %rax
  # The input filename is the first command line arg;
  # put it in the first syscall arg slot
  movq $file_name, %rdi
  # read-only flag goes into flags argument
  movq $O_CREAT_WRONLY_TRUNC, %rsi
  # 0444 goes into mode argument
  movq $0666, %rdx
  syscall

  # store the file descriptor in its local var
  movq %rax, ST_FILE_DESCRIPTOR(%rbp)

  # Write the first record
  movq ST_FILE_DESCRIPTOR(%rbp), %rdi
  movq $record1, %rsi
  call write_record

  # Write the second record
  movq ST_FILE_DESCRIPTOR(%rbp), %rdi
  movq $record2, %rsi
  call write_record

  # Write the third record
  movq ST_FILE_DESCRIPTOR(%rbp), %rdi
  movq $record3, %rsi
  call write_record

  # Close the file descriptor
  movq $SYS_CLOSE, %rax
  movq ST_FILE_DESCRIPTOR(%rbp), %rdi
  syscall

  # Exit the program
  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall
  

