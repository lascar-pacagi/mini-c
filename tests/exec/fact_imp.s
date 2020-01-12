	.text
fact_imp:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq $1, %r9
L13:
	cmpq $1, %r12
	jg L11
	movq %r9, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
L11:
	addq $-1, %r12
	movq %r12, %rbx
	movq $1, %rax
	addq %rax, %rbx
	imulq %rbx, %r9
	jmp L13
	.globl	main
main:
	movq $0, %rdi
	call fact_imp
	cmpq $1, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L31
	movq $49, %rdi
	call putchar
L31:
	movq $1, %rdi
	call fact_imp
	cmpq $1, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L25
	movq $50, %rdi
	call putchar
L25:
	movq $5, %rdi
	call fact_imp
	cmpq $120, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L19
	movq $51, %rdi
	call putchar
L19:
	movq $10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	ret
	jmp L19
	jmp L25
	jmp L31
	.data
