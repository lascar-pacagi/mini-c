	.text
	.globl	main
main:
	movq $1, %r10
	movq %r10, %r8
	movq $65, %r10
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
