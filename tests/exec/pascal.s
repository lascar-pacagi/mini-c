	.text
get:
	movq %rdi, %r8
	movq %rsi, %r10
	movq %r10, %r9
	cmpq $0, %r9
	movq $0, %r9
	sete %r9b
	testq %r9, %r9
	jz L6
	movq %r8, %r10
	movq 0(%r10), %rax
L1:
	ret
L6:
	movq 8(%r8), %r8
	addq $-1, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call get
	jmp L1
set:
	movq %rdi, %r9
	movq %rsi, %r8
	movq %rdx, %r10
	movq %r8, %rax
	cmpq $0, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L18
	movq %r9, %r8
	movq %r10, 0(%r8)
L12:
	movq %r10, %rax
	ret
L18:
	movq 8(%r9), %r9
	addq $-1, %r8
	movq %r9, %rdi
	movq %r8, %rsi
	movq %r10, %rdx
	call set
	movq %rax, %r10
	jmp L12
create:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %rbx
	movq %rbx, %r10
	cmpq $0, %r10
	movq $0, %r10
	sete %r10b
	testq %r10, %r10
	jz L37
	movq $0, %r12
L25:
	movq %r12, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L37:
	movq $16, %r10
	movq %r10, %rdi
	call sbrk
	movq %rax, %r12
	movq %r12, %r10
	movq $0, %r8
	movq %r8, 0(%r10)
	movq %rbx, %r10
	addq $-1, %r10
	movq %r10, %rdi
	call create
	movq %rax, %r10
	movq %r10, 8(%r12)
	jmp L25
print_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rbx, -24(%rbp)
	movq %r12, -16(%rbp)
	movq %rdi, -8(%rbp)
	movq %rsi, %rbx
	movq $0, %r12
L62:
	cmpq %rbx, %r12
	jle L59
	movq $10, %rdi
	call putchar
	movq $0, %rax
	movq -24(%rbp), %rbx
	movq -16(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L59:
	movq -8(%rbp), %rdi
	movq %r12, %rsi
	call get
	cmpq $0, %rax
	movq $0, %rax
	setne %al
	testq %rax, %rax
	jz L52
	movq $42, %rdi
	call putchar
L50:
	movq $1, %r10
	addq %r10, %r12
	jmp L62
L52:
	movq $46, %rdi
	call putchar
	jmp L50
mod7:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq $7, %rbx
	movq %r12, %r9
	movq $7, %rcx
	movq %r9, %rax
	cqto
	idivq %rcx
	movq %rax, %r9
	imulq %r9, %rbx
	subq %rbx, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
compute_row:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rbx, -24(%rbp)
	movq %r12, -16(%rbp)
	movq %rdi, %rbx
	movq %rsi, %r10
	movq %r10, %r12
L96:
	movq %r12, %r10
	cmpq $0, %r10
	jg L94
	movq %rbx, %r8
	movq $0, %r12
	movq $1, %r10
	movq %r8, %rdi
	movq %r12, %rsi
	movq %r10, %rdx
	call set
	movq $0, %rax
	movq -24(%rbp), %rbx
	movq -16(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L94:
	movq %rbx, %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call get
	movq %rax, -8(%rbp)
	movq %rbx, %r8
	movq %r12, %r10
	addq $-1, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call get
	movq %rax, %r10
	addq %r10, -8(%rbp)
	movq -8(%rbp), %rdi
	call mod7
	movq %rax, %r10
	movq %rbx, %rdi
	movq %r12, %rsi
	movq %r10, %rdx
	call set
	addq $-1, %r12
	jmp L96
pascal:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rbx, -24(%rbp)
	movq %r12, -16(%rbp)
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %r10
	movq $1, %r12
	addq %r12, %r10
	movq %r10, %rdi
	call create
	movq %rax, %rbx
	movq $0, %r12
L118:
	movq -8(%rbp), %r10
	cmpq %r10, %r12
	jl L115
	movq $0, %r10
	movq %r10, %rax
	movq -24(%rbp), %rbx
	movq -16(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L115:
	movq %rbx, %r8
	movq $0, %r10
	movq %r8, %rdi
	movq %r12, %rsi
	movq %r10, %rdx
	call set
	movq %rbx, %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call compute_row
	movq %rbx, %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call print_row
	movq $1, %r10
	addq %r10, %r12
	jmp L118
	.globl	main
main:
	movq $42, %r10
	movq %r10, %rdi
	call pascal
	movq $0, %r10
	movq %r10, %rax
	ret
	.data
