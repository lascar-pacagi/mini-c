	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $0, %r12
	movq $1, %r10
	cmpq $1, %r10
	movq $0, %r10
	sete %r10b
	testq %r10, %r10
	jz L9
	movq $97, %rdi
	call putchar
L9:
	movq %r12, %r10
	cmpq $0, %r10
	movq $0, %r10
	sete %r10b
	testq %r10, %r10
	jz L4
	movq $98, %r10
	movq %r10, %rdi
	call putchar
L4:
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	jmp L4
	jmp L9
	.data
