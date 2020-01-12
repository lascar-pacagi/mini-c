	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $0, %r12
	movq $0, %r10
L29:
	movq $10, %r8
	cmpq %r8, %r10
	jl L26
	movq %r12, %r10
	cmpq $100, %r10
	movq $0, %r10
	sete %r10b
	testq %r10, %r10
	jz L4
	movq $33, %r10
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
L26:
	movq $10, %r8
L24:
	cmpq $0, %r8
	jg L22
	movq $1, %r8
	addq %r8, %r10
	jmp L29
L22:
	movq $1, %r9
	addq %r9, %r12
	addq $-1, %r8
	jmp L24
	.data
