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
	movq $0, %rax
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
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $65, %rdi
	call make
	movq %rax, %r12
	movq %r12, %rdi
	call afficher
	movq $66, %rsi
	movq %r12, %rdi
	call inserer_apres
	movq %r12, %rdi
	call afficher
	movq $67, %rsi
	movq %r12, %rdi
	call inserer_apres
	movq %r12, %rdi
	call afficher
	movq 8(%r12), %rdi
	call supprimer
	movq %r12, %rdi
	call afficher
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
	.data
