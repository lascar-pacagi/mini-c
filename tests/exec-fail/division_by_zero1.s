	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq $1, %r10
	movq $0, %r8
	movq %r10, %rax
	cqto
	idivq %r8
	movq %rax, %r10
	movq %r10, %rdi
	call putchar
	movq -8(%rbp), %rax
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
