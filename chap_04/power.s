# PURPOSE: Program to illustrate how functions work.
#          Computes the value of 2^3 + 5^2

# Everything in the main program is stored in registers,
# so the data section doesn't have anything.

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

  popq %rdi             # pop our first answer into %rdi, the first arg to the exit syscall
  addq %rax, %rdi       # add our second answer, still in %rax, to our second answer (now in %rdi)

  movq $60, %rax        # Now that %rax is free, put the system call for exit in %rax
  syscall               # Do the system call

.type power, @function
power:
  pushq %rbp            # save the old base pointer
  movq %rsp, %rbp       # make the stack pointer the base pointer
  movq %rdi, %rax       # Let's use %rax as our ongoing answer, seeing as the return value needs to end up there

power_loop_start:
  cmpq $1, %rsi         # if the power is 1, we are done
  je end_power
  imulq %rdi, %rax      # multiply our base (first arg, still in %rdi) by our ongoing answer
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
