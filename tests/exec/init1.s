	.text
	.globl	main
main:
	movq %r8, %r10
	cmpq %r10, %r8
	movq $0, %r8
	sete %r8b
	testq %r8, %r8
	jz L4
	movq $97, %rdi
	call putchar
L4:
	movq $10, %rdi
	call putchar
	movq $0, %rax
	ret
	jmp L4
	.data
