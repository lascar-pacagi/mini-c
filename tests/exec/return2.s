	.text
f:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r9
	movq %rsi, %r12
	movq $2, %rax
	imulq %r12, %rax
	addq %rax, %r9
	movq %r9, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
	.globl	main
main:
	movq $65, %rdi
	movq $0, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq $65, %rdi
	movq $1, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq $65, %rdi
	movq $2, %rsi
	call f
	movq %rax, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	ret
	.data
