	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $10, %r12
L14:
	testq %r12, %r12
	jz L4
	addq $-1, %r12
	movq $65, %rdi
	addq %r12, %rdi
	call putchar
	jmp L14
L4:
	movq $10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
