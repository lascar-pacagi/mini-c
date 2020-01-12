	.text
many:
	pushq %rbp
	movq %rsp, %rbp
	addq $-80, %rsp
	movq %rbx, -80(%rbp)
	movq %r12, -72(%rbp)
	movq %rdi, %r12
	movq %rsi, -48(%rbp)
	movq %rdx, -40(%rbp)
	movq %rcx, -32(%rbp)
	movq %r8, -24(%rbp)
	movq %r9, -16(%rbp)
	movq 40(%rbp), %r11
	movq %r11, -56(%rbp)
	movq 32(%rbp), %r11
	movq %r11, -64(%rbp)
	movq 24(%rbp), %rbx
	movq 16(%rbp), %r11
	movq %r11, -8(%rbp)
	movq $64, %rdi
	addq %r12, %rdi
	call putchar
	movq $64, %rdi
	addq -48(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -40(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -32(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -24(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -16(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -8(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq %rbx, %rdi
	call putchar
	movq $64, %rdi
	addq -64(%rbp), %rdi
	call putchar
	movq $64, %rdi
	addq -56(%rbp), %rdi
	call putchar
	movq $10, %rdi
	call putchar
	movq $10, %r10
	cmpq %r10, %r12
	jl L13
L2:
	movq $0, %rax
	movq -80(%rbp), %rbx
	movq -72(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L13:
	movq -48(%rbp), %rdi
	movq -40(%rbp), %rsi
	movq -32(%rbp), %rdx
	movq -24(%rbp), %rcx
	movq -16(%rbp), %r8
	movq -8(%rbp), %r9
	pushq %r12
	pushq -56(%rbp)
	pushq -64(%rbp)
	pushq %rbx
	call many
	jmp L2
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq $1, %rdi
	movq $2, %rsi
	movq $3, %rdx
	movq $4, %rcx
	movq $5, %r8
	movq $6, %r9
	movq $7, %rbx
	movq $8, %rax
	movq $9, %r12
	movq $10, %r10
	pushq %r10
	pushq %r12
	pushq %rax
	pushq %rbx
	call many
	movq $0, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
