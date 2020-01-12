	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq $16, %r10
	movq %r10, %rdi
	call sbrk
	movq %rax, %rbx
	movq $24, %r10
	movq %r10, %rdi
	call sbrk
	movq %rax, %r12
	movq $16, %r10
	movq %r10, %rdi
	call sbrk
	movq %rax, %r10
	movq %r10, 8(%r12)
	movq %r12, %r10
	movq $65, %r8
	movq %r8, 0(%r10)
	movq %r12, %r10
	movq $66, %r8
	movq %r8, 16(%r10)
	movq %r12, %r10
	movq 8(%r10), %r10
	movq $120, %r8
	movq %r8, 0(%r10)
	movq %r12, %r10
	movq 8(%r10), %r10
	movq $121, %r8
	movq %r8, 8(%r10)
	movq %r12, %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	movq 8(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 16(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq %rbx, %r10
	movq $88, %r8
	movq %r8, 0(%r10)
	movq %rbx, %r10
	movq $89, %r8
	movq %r8, 8(%r10)
	movq %r12, %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	movq 8(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 16(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq %rbx, %r8
	movq %r8, 8(%r10)
	movq 0(%r12), %rdi
	call putchar
	movq 8(%r12), %r10
	movq 0(%r10), %rdi
	call putchar
	movq 8(%r12), %r10
	movq 8(%r10), %rdi
	call putchar
	movq %r12, %r10
	movq 16(%r10), %r10
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
