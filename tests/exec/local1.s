	.text
	.globl	main
main:
	movq $65, %r10
	movq %r10, %rdi
	call putchar
	movq $66, %r10
	movq %r10, %rdi
	call putchar
	movq $67, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
