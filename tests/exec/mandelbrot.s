	.text
add:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq %rsi, %r9
	addq %r9, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
sub:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq %rsi, %r9
	subq %r9, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
mul:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq %rsi, %r9
	imulq %r9, %r12
	movq $4096, %r9
	addq %r9, %r12
	movq $8192, %r9
	movq %r12, %rax
	cqto
	idivq %r9
	movq %rax, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
div:
	movq %rbx, %r8
	movq %rdi, %rax
	movq %rsi, %r10
	movq $8192, %r9
	imulq %rax, %r9
	movq %r10, %rax
	movq $2, %rbx
	cqto
	idivq %rbx
	addq %rax, %r9
	movq %r9, %rax
	cqto
	idivq %r10
	movq %rax, %r9
	movq %r9, %rax
	movq %r8, %rbx
	ret
of_int:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq $8192, %rax
	imulq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
iter:
	pushq %rbp
	movq %rsp, %rbp
	addq $-80, %rsp
	movq %rbx, -80(%rbp)
	movq %r12, -72(%rbp)
	movq %rdi, -32(%rbp)
	movq %rsi, -40(%rbp)
	movq %rdx, -48(%rbp)
	movq %rcx, -24(%rbp)
	movq %r8, -16(%rbp)
	movq -32(%rbp), %r10
	cmpq $100, %r10
	movq $0, %r10
	sete %r10b
	testq %r10, %r10
	jz L70
	movq $1, %rax
L35:
	movq -80(%rbp), %rbx
	movq -72(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L70:
	movq -24(%rbp), %r12
	movq -24(%rbp), %r10
	movq %r12, %rdi
	movq %r10, %rsi
	call mul
	movq %rax, -8(%rbp)
	movq -16(%rbp), %r12
	movq -16(%rbp), %r10
	movq %r12, %rdi
	movq %r10, %rsi
	call mul
	movq %rax, %rbx
	movq -8(%rbp), %rdi
	movq %rbx, %rsi
	call add
	movq %rax, %r12
	movq $4, %rdi
	call of_int
	cmpq %rax, %r12
	movq $0, %r12
	setg %r12b
	testq %r12, %r12
	jz L54
	movq $0, %rax
	jmp L35
L54:
	movq -32(%rbp), %r12
	movq $1, %r10
	addq %r10, %r12
	movq -40(%rbp), %r15
	movq %r15, -64(%rbp)
	movq -8(%rbp), %rdi
	movq %rbx, %rsi
	call sub
	movq -40(%rbp), %r10
	movq %rax, %rdi
	movq %r10, %rsi
	call add
	movq %rax, -56(%rbp)
	movq $2, %rdi
	call of_int
	movq %rax, %rbx
	movq -24(%rbp), %rdi
	movq -16(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq %rbx, %rdi
	call mul
	movq -48(%rbp), %r10
	movq %rax, %rdi
	movq %r10, %rsi
	call add
	movq %rax, %r8
	movq %r12, %rdi
	movq -64(%rbp), %rsi
	movq -48(%rbp), %rdx
	movq -56(%rbp), %rcx
	call iter
	jmp L35
inside:
	pushq %rbp
	movq %rsp, %rbp
	addq $-32, %rsp
	movq %rbx, -32(%rbp)
	movq %r12, -24(%rbp)
	movq %rdi, -8(%rbp)
	movq %rsi, %rbx
	movq $0, -16(%rbp)
	movq $0, %rdi
	call of_int
	movq %rax, %r12
	movq $0, %rdi
	call of_int
	movq %rax, %r8
	movq -16(%rbp), %rdi
	movq -8(%rbp), %rsi
	movq %rbx, %rdx
	movq %r12, %rcx
	call iter
	movq -32(%rbp), %rbx
	movq -24(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
run:
	pushq %rbp
	movq %rsp, %rbp
	addq $-64, %rsp
	movq %rbx, -64(%rbp)
	movq %r12, -56(%rbp)
	movq %rdi, -8(%rbp)
	movq $-2, %rdi
	call of_int
	movq %rax, -32(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, %rdi
	movq -32(%rbp), %rsi
	call sub
	movq %rax, %r12
	movq $2, %rdi
	imulq -8(%rbp), %rdi
	call of_int
	movq %rax, %rsi
	movq %r12, %rdi
	call div
	movq %rax, -48(%rbp)
	movq $-1, %rdi
	call of_int
	movq %rax, -16(%rbp)
	movq $1, %rdi
	call of_int
	movq %rax, %r10
	movq %r10, %rdi
	movq -16(%rbp), %rsi
	call sub
	movq %rax, %r12
	movq -8(%rbp), %rdi
	call of_int
	movq %rax, %rsi
	movq %r12, %rdi
	call div
	movq %rax, -40(%rbp)
	movq $0, %rbx
L129:
	cmpq -8(%rbp), %rbx
	jl L126
	movq $0, %r10
	movq %r10, %rax
	movq -64(%rbp), %rbx
	movq -56(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L126:
	movq %rbx, %rdi
	call of_int
	movq %rax, %rdi
	movq -40(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -16(%rbp), %rdi
	call add
	movq %rax, -24(%rbp)
	movq $0, %r12
L117:
	movq $2, %r10
	imulq -8(%rbp), %r10
	cmpq %r10, %r12
	jl L112
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $1, %r10
	addq %r10, %rbx
	jmp L129
L112:
	movq %r12, %rdi
	call of_int
	movq %rax, %rdi
	movq -48(%rbp), %rsi
	call mul
	movq %rax, %rsi
	movq -32(%rbp), %rdi
	call add
	movq %rax, %r10
	movq %r10, %rdi
	movq -24(%rbp), %rsi
	call inside
	movq %rax, %r10
	testq %r10, %r10
	jz L99
	movq $48, %r10
	movq %r10, %rdi
	call putchar
L97:
	movq $1, %r10
	addq %r10, %r12
	jmp L117
L99:
	movq $49, %r10
	movq %r10, %rdi
	call putchar
	jmp L97
	.globl	main
main:
	movq $30, %rdi
	call run
	movq $0, %rax
	ret
	.data
