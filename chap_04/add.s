# add.s
# Not from Programming from the Ground up; just exploring
# simple function call that has local variables. Illustrates
# how a 'leaf function' (a function that calls no other functions)
# Doesn't need to subtract from the stack pointer to make room
# on the stack for local variables; instead, with the 64 bit
# calling convention, a certain amount of memory past the stack
# pointer is automatically available for use by local variables.

# Compile and link like so:
# $ as add.s -o add.o
# $ ld add.o -o add

# Just adds 2 and 3 and puts the result in the exit code.

# Nothing for the data section
.section .data

.section .text
.globl _start
_start:
  movq $2, %rdi          # first argument
  movq $3, %rsi          # second argument
  call add               # call the add function

  movq %rax, %rdi       # Our answer is in %rax, but we want to print
                        # it as the exit status, so put it into %rdi,
                        # the first arg for system calls.

  movq $60, %rax        # Now that %rax is free, put the system call
                        # for exit in %rax

  syscall               # Do the system call

.type add, @function
add:
  pushq %rbp            # save the old base pointer
  movq %rsp, %rbp       # make the stack pointer the base pointer
  
  movq %rdi, -8(%rbp)   # put first arg on stack (local variable)
  movq %rsi, -16(%rbp)  # put second arg on stack (local variable)
  movq -8(%rbp), %rdx   # put first local variable in %rdx in preparation
                        # for add

  movq -16(%rbp), %rax  # put second local variable in %rax,
                        # the "return value" register

  addq %rdx, %rax       # add %rdx and %rax, putting the result in %rax,
                        # our return register
  
  popq %rbp             # restore base pointer
  ret

# http://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
# google search "linux amd64 c calling convention"

# This is really good too:
# http://nickdesaulniers.github.io/blog/2014/04/18/lets-write-some-x86-64/
