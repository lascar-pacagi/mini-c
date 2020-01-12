	.text
	.globl	main
main:
	movq $104, %rdi
	call putchar
	movq $101, %rdi
	call putchar
	movq $108, %rdi
	call putchar
	movq $108, %rdi
	call putchar
	movq $111, %rdi
	call putchar
	movq $32, %rdi
	call putchar
	movq $119, %rdi
	call putchar
	movq $111, %rdi
	call putchar
	movq $114, %r10
	movq %r10, %rdi
	call putchar
	movq $108, %r10
	movq %r10, %rdi
	call putchar
	movq $100, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
