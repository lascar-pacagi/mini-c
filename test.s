	.text
	.globl	main
main:
	movq %rbx, %r8
	movq $1, %r10
	movq %r10, %rax
	movq $42, %r9
	addq %r9, %rax
	movq %r10, %r9
	movq %rax, %r10
	addq %r10, %r9
	movq $2, %r10
	imulq %r9, %r10
	movq $0, %r9
	cmpq %r9, %r10
	jl L16
L2:
	movq $0, %rax
	movq %r8, %rbx
	ret
L16:
	movq $12, %r9
	movq $2, %rax
	addq %rax, %r10
	movq %r9, %rax
	addq %r10, %rax
	movq %r9, %r10
	addq %r10, %rax
	jmp L2
	.data
