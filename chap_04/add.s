# PURPOSE: Program to illustrate how functions work.
#          Just adds 2 and 3

# Everything in the main program is stored in registers,
# so the data section doesn't have anything.

.section .data

.section .text
.globl _start
_start:
  movq $2, %rdi          # first argument
  movq $3, %rsi          # second argument
  call add       # call the add function

  movq %rax, %rdi       # Our answer is in %rax, but we want to print it as the exit status,
                        # so put it into %rdi, the first arg for system calls.

  movq $60, %rax        # Now that %rax is free, put the system call for exit in %rax
  syscall               # Do the systen call

.type add, @function
add:
  pushq %rbp            # save the old base pointer
  movq %rsp, %rbp       # make the stack pointer the base pointer
  
  movq %rdi, -8(%rbp)   # put first arg on stack (local variable)
  movq %rsi, -16(%rbp)  # put second arg on stack (local variable)
  movq -8(%rbp), %rdx   # put first local variable in %rdx in preparation for add
  movq -16(%rbp), %rax  # put second local variable in %rax, the "return value" register
  addq %rdx, %rax       # add %rdx and %rax, putting the result in %rax, our return register
  
  popq %rbp             # restore base pointer
  ret

# http://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
# google search "linux amd64 c calling convention"

# This is really good too:
# http://nickdesaulniers.github.io/blog/2014/04/18/lets-write-some-x86-64/
