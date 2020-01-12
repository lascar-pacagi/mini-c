	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $16, %r10
	movq %r10, %rdi
	call sbrk
	movq %rax, %r12
	movq %r12, %r10
	movq $65, %r8
	movq %r8, 0(%r10)
	movq %r12, %r10
	movq 0(%r10), %rdi
	call putchar
	movq %r12, %r10
	movq 0(%r10), %rdi
	call putchar
	movq %r12, %r10
	movq $66, %r8
	movq %r8, 8(%r10)
	movq %r12, %r10
	movq 8(%r10), %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
