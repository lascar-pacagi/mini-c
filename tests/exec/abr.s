	.text
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-24, %rsp
	movq %rbx, -24(%rbp)
	movq %r12, -16(%rbp)
	movq %rdi, %r12
	movq %rsi, %rbx
	movq %rdx, -8(%rbp)
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq %r12, 0(%r10)
	movq %rbx, %r12
	movq %r12, 8(%r10)
	movq -8(%rbp), %r12
	movq %r12, 16(%r10)
	movq %r10, %rax
	movq -24(%rbp), %rbx
	movq -16(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
insere:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %r10
	movq %rsi, %r12
	movq %r12, %r8
	movq 0(%r10), %r9
	cmpq %r9, %r8
	movq $0, %r8
	sete %r8b
	testq %r8, %r8
	jz L48
	movq $0, %rax
L15:
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L48:
	movq 0(%r10), %r8
	cmpq %r8, %r12
	jl L44
	movq 16(%r10), %r8
	cmpq $0, %r8
	movq $0, %r8
	sete %r8b
	testq %r8, %r8
	jz L20
	movq %r10, %rbx
	movq %r12, %r8
	movq $0, %r12
	movq $0, %r10
	movq %r8, %rdi
	movq %r12, %rsi
	movq %r10, %rdx
	call make
	movq %rax, %r10
	movq %r10, 16(%rbx)
L16:
	movq $0, %rax
	jmp L15
L20:
	movq 16(%r10), %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call insere
	jmp L16
L44:
	movq 8(%r10), %r8
	cmpq $0, %r8
	movq $0, %r8
	sete %r8b
	testq %r8, %r8
	jz L34
	movq %r10, %rbx
	movq %r12, %r8
	movq $0, %r12
	movq $0, %r10
	movq %r8, %rdi
	movq %r12, %rsi
	movq %r10, %rdx
	call make
	movq %rax, %r10
	movq %r10, 8(%rbx)
	jmp L16
L34:
	movq 8(%r10), %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call insere
	jmp L16
contient:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r10
	movq %rsi, %r12
	movq %r12, %r8
	movq 0(%r10), %r9
	cmpq %r9, %r8
	movq $0, %r8
	sete %r8b
	testq %r8, %r8
	jz L76
	movq $1, %rax
L55:
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L76:
	movq 0(%r10), %r8
	cmpq %r8, %r12
	jl L72
L64:
	movq 16(%r10), %r8
	cmpq $0, %r8
	movq $0, %r8
	setne %r8b
	testq %r8, %r8
	jz L56
	movq 16(%r10), %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call contient
	jmp L55
L56:
	movq $0, %rax
	jmp L55
L72:
	movq 8(%r10), %r8
	cmpq $0, %r8
	movq $0, %r8
	setne %r8b
	testq %r8, %r8
	jz L64
	movq 8(%r10), %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call contient
	jmp L55
	jmp L64
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
	movq %rbx, %r10
	cmpq $9, %r10
	jg L94
L92:
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
L94:
	movq %r12, %r10
	movq %r10, %rdi
	call print_int
	jmp L92
print:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	movq $40, %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r10
	cmpq $0, %r10
	movq $0, %r10
	setne %r10b
	testq %r10, %r10
	jz L113
	movq %r12, %r10
	movq 8(%r10), %r10
	movq %r10, %rdi
	call print
L113:
	movq %r12, %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call print_int
	movq %r12, %r10
	movq 16(%r10), %r10
	cmpq $0, %r10
	movq $0, %r10
	setne %r10b
	testq %r10, %r10
	jz L103
	movq %r12, %r10
	movq 16(%r10), %r10
	movq %r10, %rdi
	call print
L103:
	movq $41, %r10
	movq %r10, %rdi
	call putchar
	movq %rax, %r10
	movq %r10, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	jmp L103
	jmp L113
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $1, %rdi
	movq $0, %rsi
	movq $0, %rdx
	call make
	movq %rax, %r12
	movq $17, %rsi
	movq %r12, %rdi
	call insere
	movq $5, %rsi
	movq %r12, %rdi
	call insere
	movq $8, %rsi
	movq %r12, %rdi
	call insere
	movq %r12, %rdi
	call print
	movq $10, %rdi
	call putchar
	movq $5, %rsi
	movq %r12, %rdi
	call contient
	testq %rax, %rax
	jz L137
	movq $0, %rsi
	movq %r12, %rdi
	call contient
	cmpq $0, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L137
	movq $17, %rsi
	movq %r12, %rdi
	call contient
	testq %rax, %rax
	jz L137
	movq $3, %rsi
	movq %r12, %rdi
	call contient
	cmpq $0, %rax
	movq $0, %rax
	sete %al
	testq %rax, %rax
	jz L137
	movq $111, %rdi
	call putchar
	movq $107, %rdi
	call putchar
	movq $10, %rdi
	call putchar
L137:
	movq $42, %rsi
	movq %r12, %rdi
	call insere
	movq $1000, %rsi
	movq %r12, %rdi
	call insere
	movq $0, %rsi
	movq %r12, %rdi
	call insere
	movq %r12, %rdi
	call print
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	jmp L137
	jmp L137
	jmp L137
	jmp L137
	.data
