	.text
	.globl	main
main:
	pushq %rbp
	movq %rsp, %rbp
	addq $-8, %rsp
	movq %r12, -8(%rbp)
	movq $65, %r12
	movq %r12, %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	testq %r10, %r10
	jz L38
	movq $66, %r12
L38:
	movq %r12, %r10
	movq %r10, %rdi
	call putchar
	movq %r12, %r10
	testq %r10, %r10
	jz L30
	movq $0, %r10
	testq %r10, %r10
	jz L30
	movq $67, %r12
L30:
	movq %r12, %r10
	movq %r10, %rdi
	call putchar
	testq %r12, %r12
	jz L22
	movq $1, %r10
	testq %r10, %r10
	jz L22
	movq $68, %r12
L22:
	movq %r12, %rdi
	call putchar
	testq %r12, %r12
	jz L18
L16:
	movq $69, %r12
L14:
	movq %r12, %rdi
	call putchar
	movq %r12, %r10
	testq %r10, %r10
	jz L10
L8:
	movq $70, %r12
L6:
	movq %r12, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	movq -8(%rbp), %r12
	movq %rbp, %rsp
	popq %rbp
	ret
L10:
	movq $1, %r10
	testq %r10, %r10
	jz L6
	jmp L8
L18:
	movq $0, %r10
	testq %r10, %r10
	jz L14
	jmp L16
	jmp L22
	jmp L22
	jmp L30
	jmp L30
	jmp L38
	.data
