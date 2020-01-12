	.text
f:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq %rsi, %r9
	addq %r9, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
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
	movq $65, %rdi
	movq $3, %rsi
	call f
	movq %rax, %r12
	movq %r12, %rdi
	call putchar
	movq $1, %r10
	addq %r10, %r12
	movq %r12, %rdi
	call putchar
	movq $10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
