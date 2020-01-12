	.text
fact:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	cmpq $1, %r12
	jle L7
	movq %r12, %rdi
	addq $-1, %rdi
	call fact
	imulq %rax, %r12
L1:
	movq %r12, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L7:
	movq $1, %r12
	jmp L1
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq $0, %r12
L25:
	cmpq $4, %r12
	jle L23
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L23:
	movq $65, %rbx
	movq %r12, %rdi
	call fact
	addq %rax, %rbx
	movq %rbx, %rdi
	call putchar
	movq $1, %r10
	addq %r10, %r12
	jmp L25
	.data
