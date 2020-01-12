	.text
make:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	movq $24, %rdi
	call sbrk
	movq %rax, %r10
	movq %r12, 0(%r10)
	movq %r10, %r12
	movq %r10, %r8
	movq %r8, 16(%r10)
	movq %r8, 8(%r12)
	movq %r10, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
inserer_apres:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	movq %rsi, %r10
	movq %r10, %rdi
	call make
	movq %rax, %r10
	movq 8(%r12), %r8
	movq %r8, 8(%r10)
	movq %r10, 8(%r12)
	movq 8(%r10), %r8
	movq %r10, 16(%r8)
	movq %r12, 16(%r10)
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
supprimer:
	movq %rbx, %r8
	movq %r12, %r10
	movq %rdi, %r12
	movq 16(%r12), %r9
	movq 8(%r12), %rax
	movq %rax, 8(%r9)
	movq 8(%r12), %r9
	movq 16(%r12), %r12
	movq %r12, 16(%r9)
	movq $0, %r12
	movq %r12, %rax
	movq %r8, %rbx
	movq %r10, %r12
	ret
afficher:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %rbx
	movq %rbx, %r12
	movq %r12, %r10
	movq 0(%r10), %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	movq 8(%r10), %r12
L59:
	movq %r12, %r8
	movq %rbx, %r10
	cmpq %r10, %r8
	movq $0, %r8
	setne %r8b
	testq %r8, %r8
	jz L48
	movq 0(%r12), %rdi
	call putchar
	movq 8(%r12), %r12
	jmp L59
L48:
	movq $10, %rdi
	call putchar
	movq $0, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
cercle:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %r12
	movq $1, %r10
	movq %r10, %rdi
	call make
	movq %rax, %rbx
L80:
	movq %r12, %r8
	movq $2, %r10
	cmpq %r10, %r8
	movq $0, %r8
	setge %r8b
	testq %r8, %r8
	jz L69
	movq %rbx, %r8
	movq %r12, %r10
	movq %r8, %rdi
	movq %r10, %rsi
	call inserer_apres
	addq $-1, %r12
	jmp L80
L69:
	movq %rbx, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
josephus:
	pushq %rbp
	movq %rsp, %rbp
	addq $-16, %rsp
	movq %rbx, -16(%rbp)
	movq %r12, -8(%rbp)
	movq %rdi, %r10
	movq %rsi, %rbx
	movq %r10, %rdi
	call cercle
	movq %rax, %r12
L112:
	movq %r12, %r8
	movq %r12, %r10
	movq 8(%r10), %r10
	cmpq %r10, %r8
	movq $0, %r8
	setne %r8b
	testq %r8, %r8
	jz L88
	movq $1, %r10
L105:
	movq %rbx, %r8
	cmpq %r8, %r10
	jl L102
	movq %r12, %r10
	movq %r10, %rdi
	call supprimer
	movq %r12, %r10
	movq 8(%r10), %r12
	jmp L112
L102:
	movq 8(%r12), %r12
	movq $1, %r8
	addq %r8, %r10
	jmp L105
L88:
	movq %r12, %r10
	movq 0(%r10), %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
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
	jg L127
L125:
	movq $48, %r10
	movq %rbx, %r8
	movq $10, %r9
	imulq %r12, %r9
	subq %r9, %r8
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %r10
	movq %r10, %rax
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L127:
	movq %r12, %r10
	movq %r10, %rdi
	call print_int
	jmp L125
	.globl	main
main:
	movq $7, %rdi
	movq $5, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq $10, %rdi
	call putchar
	movq $5, %rdi
	movq $5, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq $10, %rdi
	call putchar
	movq $5, %rdi
	movq $17, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq $10, %rdi
	call putchar
	movq $13, %rdi
	movq $2, %rsi
	call josephus
	movq %rax, %rdi
	call print_int
	movq $10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
