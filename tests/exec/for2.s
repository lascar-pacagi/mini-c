	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $10, %r12
L15:
	movq %r12, %r10
	cmpq $0, %r10
	jg L13
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L13:
	movq $65, %r10
	addq $-1, %r12
	addq %r12, %r10
	movq $1, %r8
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	jmp L15
	.data
