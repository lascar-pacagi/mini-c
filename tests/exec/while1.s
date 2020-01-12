	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $10, %r12
L15:
	addq $-1, %r12
	movq %r12, %r8
	movq $1, %r10
	addq %r10, %r8
	testq %r8, %r8
	jz L4
	movq $65, %r10
	addq %r12, %r10
	movq %r10, %rdi
	call putchar
	jmp L15
L4:
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
