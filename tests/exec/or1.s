	.text
	.globl	main
main:
	movq $65, %r10
	movq $1, %r8
	testq %r8, %r8
	jz L37
L35:
	movq $1, %r8
L33:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $0, %r8
	testq %r8, %r8
	jz L28
L26:
	movq $1, %r8
L24:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $1, %r8
	testq %r8, %r8
	jz L19
L17:
	movq $1, %r8
L15:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $0, %r8
	testq %r8, %r8
	jz L10
L8:
	movq $1, %r8
L6:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $10, %r10
	movq %r10, %rdi
	call putchar
	movq $0, %rax
	ret
L10:
	movq $0, %r8
	testq %r8, %r8
	jnz L8
	movq $0, %r8
	jmp L6
	jmp L8
L19:
	movq $0, %r8
	testq %r8, %r8
	jnz L17
	movq $0, %r8
	jmp L15
	jmp L17
L28:
	movq $2, %r8
	testq %r8, %r8
	jnz L26
	movq $0, %r8
	jmp L24
	jmp L26
L37:
	movq $1, %r8
	testq %r8, %r8
	jnz L35
	movq $0, %r8
	jmp L33
	jmp L35
	.data
