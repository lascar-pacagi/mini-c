	.text
fact_rec:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	cmpq $1, %r12
	jle L7
	movq %r12, %rdi
	addq $-1, %rdi
	call fact_rec
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
	movq $0, %rdi
	call fact_rec
	cmpq $1, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L25
	movq $49, %rdi
	call putchar
L25:
	movq $1, %rdi
	call fact_rec
	cmpq $1, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L19
	movq $50, %rdi
	call putchar
L19:
	movq $5, %rdi
	call fact_rec
	cmpq $120, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L13
	movq $51, %rdi
	call putchar
L13:
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	ret
	jmp L13
	jmp L19
	jmp L25
	.data
