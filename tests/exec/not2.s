	.text
	.globl	main
main:
	movq $0, %r10
	movq $65, %rdi
	cmpq $0, %r10
	movq $0, %r10
	sete %r10b
	addq %r10, %rdi
	call putchar
	movq $1, %r10
	movq $65, %r8
	cmpq $0, %r10
	movq $0, %r10
	sete %r10b
	addq %r10, %r8
	movq %r8, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
