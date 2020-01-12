	.text
print_int:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %rbx
	movq %rbx, %r12
	movq $10, %r10
	movq %r12, %rax
	cqto
	idivq %r10
	movq %rax, %r12
	cmpq $9, %rbx
	jg L12
L10:
	movq $48, %r10
	movq %rbx, %r8
	movq $10, %r9
	imulq %r12, %r9
	subq %r9, %r8
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L12:
	movq %r12, %rdi
	call print_int
	jmp L10
	.globl	main
main:
	movq $42, %rdi
	call print_int
	movq $10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
