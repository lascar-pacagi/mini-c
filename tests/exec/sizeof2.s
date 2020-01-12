	.text
	.globl	main
main:
	movq $73, %rdi
	call putchar
	movq $10, %rdi
	call putchar
	movq $81, %rdi
	call putchar
	movq $10, %rdi
	call putchar
	movq $0, %rax
	ret
	.data
