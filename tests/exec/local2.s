	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq $65, %r12
	movq %r12, %rdi
	call putchar
	movq $1, %r10
	addq %r10, %r12
	movq %r12, %rdi
	call putchar
	movq %r12, %rbx
	movq $1, %r10
	addq %r10, %rbx
	movq %r12, %r10
	movq %r10, %rdi
	call putchar
	movq %rbx, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
