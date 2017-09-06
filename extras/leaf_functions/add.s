	.file	"add.c"
	.text
	.globl	add_more
	.type	add_more, @function
add_more:
.LFB0:
	.cfi_startproc

	// push the old base pointer onto the stack
	// (modifies rsp, the stack pointer)
	pushq	%rbp

	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16

	// make the base pointer point to the head of the stack
	movq	%rsp, %rbp

	.cfi_def_cfa_register 6
	// without moving the stack pointer, put a 20 bytes past
	// the base pointer, into the stack
	movl	%edi, -20(%rbp)

	// without moving the stack pointer, put b 24 bytes past
	// the base pointer, into the stack
	movl	%esi, -24(%rbp)

	// move a into eax
	movl	-20(%rbp), %eax

	// move eax to local variable x, 12 bytes past the
	// base pointer, into the stack (now x == a)
	movl	%eax, -12(%rbp)

	// move b into eax
	movl	-24(%rbp), %eax

	// move eax to local variable y, 8 bytes past the
	// base pointer, into the stack (now y == b)
	movl	%eax, -8(%rbp)

	// move x into edx
	movl	-12(%rbp), %edx

	// move y into edx
	movl	-8(%rbp), %eax

	// add edx to eax (essentially x += y but in registers;
	// original x and y are left alone)
	addl	%edx, %eax

	// move eax into local variable answer, 4 bytes past the
	// head of the stack (essentially answer == x + y)
	movl	%eax, -4(%rbp)

	// move answer into eax, where return values go
	movl	-4(%rbp), %eax

	// pop the old base pointer into rbp; we never moved sp,
	// so this is possible
	popq	%rbp

	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	add_more, .-add_more
	.globl	add
	.type	add, @function
add:
.LFB1:
	.cfi_startproc

	// push the current base pointer onto the stack
	// (modifies rsp, the stack pointer)
	pushq	%rbp

	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16

	// make the base pointer point to the head of
	// the stack
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6

	// make room for 24 bytes' worth of local variables
	// at the head of the stack
	subq	$24, %rsp

	// move a 20 bytes past the base pointer into
	// local variable x
	movl	%edi, -20(%rbp)

	// move b 24 bytes past the base pointer into
	// local variable y
	movl	%esi, -24(%rbp)

	// move x into eax
	movl	-20(%rbp), %eax

	// move x/eax into local variable z,
	// 16 bytes past the base pointer
	movl	%eax, -16(%rbp)

	// move y into eax
	movl	-24(%rbp), %eax

	// move y/eax into local varible answer,
	// 12 bytes past the base pointer
	movl	%eax, -12(%rbp)

	// put second argument to add_more in esi
	movl	$76, %esi

	// put first argument to add_more in edi
	movl	$25, %edi

	call	add_more

	// put the return value 8 bytes past the
	// base pointer, into what local var?
	movl	%eax, -8(%rbp)

	// put local variable z into edx
	movl	-16(%rbp), %edx

	// put local variable x into eax
	movl	-12(%rbp), %eax

	// add eax to edx
	addl	%eax, %edx

	// put return value into eax
	movl	-8(%rbp), %eax

	// add edx to eax
	addl	%edx, %eax

	// put eax 4 bytes past the base pointer
	movl	%eax, -4(%rbp)

	// put 4 bytes past the base pointer back into eax
	movl	-4(%rbp), %eax

	// move the stack pointer back to the base pointer
	// and pop the old base pointer into rbp
	leave

	.cfi_def_cfa 7, 8
	ret  // return
	.cfi_endproc
.LFE1:
	.size	add, .-add
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$88, %esi
	movl	$77, %edi
	call	add
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
