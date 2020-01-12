	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq $65, %rbx
	movq %rbx, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	testq %r10, %r10
	jz L14
	movq $66, %r10
	movq %r10, %rdi
	call putchar
L6:
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
L14:
	movq $67, %r10
	movq $68, %r12
	movq %r10, %rdi
	call putchar
	movq %r12, %rdi
	call putchar
	jmp L6
	.data
