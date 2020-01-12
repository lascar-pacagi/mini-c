	.text
f:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq %rbx, -32(%rbp)
	movq %r12, -24(%rbp)
	movq %rdi, %r12
	movq %rsi, -16(%rbp)
	movq %rdx, -8(%rbp)
	movq %rcx, %rbx
	testq %r12, %r12
	jz L2
	movq %r12, %rdi
	call putchar
	movq -16(%rbp), %rdi
	movq -8(%rbp), %rsi
	movq %rbx, %rdx
	movq %r12, %rcx
	call f
L1:
	movq -32(%rbp), %rbx
	movq -24(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L2:
	movq $0, %rax
	jmp L1
	.globl	main
main:
	movq $65, %rdi
	movq $66, %rsi
	movq $67, %rdx
	movq $0, %rcx
	call f
	movq $10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
