# power.s
# From pp 60-62 of Programming from the Ground Up; 64 bit version
#
# Compile and link like so:
# $ as power.s -o power.o
# $ ld power.o -o power
#
# By this point, the gdb debugger comes in handy.
# Compile and link for a debugger like so:
# $ as --gstabs power.s -o power.o
# $ ld power.o -o power
#
# Computes the value of 2^3 + 5^2 and puts the answer in
# the exit status code that can be seen with $?
#
# Intended to illustrate functions and stack management, but
# the 64 bit intel linux calling convention uses registers
# for the first 6 function argments, so stack use won't come
# until we learn about local variables in functions.

# Nothing for the data section this time.
.section .data

.section .text
.globl _start
_start:
  movq $2, %rdi         # first argument
  movq $3, %rsi         # second argument
  call power            # call the power function
  pushq %rax            # push our first answer onto the stack

  movq $2, %rdi         # first argument
  movq $5, %rsi         # second argument
  call power            # call the power function

  popq %rdi             # pop our first answer into %rdi,
                        # the first arg to the exit
                        # syscall

  addq %rax, %rdi       # add our second answer, still in %rax,
                        # to our second answer (now in %rdi)

  movq $60, %rax        # Now that %rax is free, put the system call
                        # for exit in %rax

  syscall               # Do the system call

# I forget exactly how this .type directive works, but obviously it's
# defining a function.
.type power, @function
power:
  pushq %rbp            # save the old base pointer
  movq %rsp, %rbp       # make the stack pointer the base pointer
  movq %rdi, %rax       # Let's use %rax as our ongoing answer,
                        # seeing as the return
                        # value needs to end up there

power_loop_start:
  cmpq $1, %rsi         # if the power is 1, we are done
  je end_power
  imulq %rdi, %rax      # multiply our base (first arg, still in %rdi)
                        # by our ongoing answer

  decq %rsi             # subtract 1 from our power (still in %rsi)
  jmp power_loop_start
end_power:
                        # Remember, our answer is already in %rax
  popq %rbp             # restore base pointer
  ret

# registar first 6 args: rdi, rsi, rdx, rcx, r8, r9
# register return value: rax

# http://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
# google search "linux amd64 c calling convention"

# This is really good too:
# http://nickdesaulniers.github.io/blog/2014/04/18/lets-write-some-x86-64/
