	.text
	.globl	main
main:
	movq $65, %r10
	movq $0, %r8
	testq %r8, %r8
	jz L34
	movq $1, %r8
	testq %r8, %r8
	jz L34
	movq $1, %r8
L33:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $0, %r8
	testq %r8, %r8
	jz L25
	movq $2, %r8
	testq %r8, %r8
	jz L25
	movq $1, %r8
L24:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $1, %r8
	testq %r8, %r8
	jz L16
	movq $0, %r8
	testq %r8, %r8
	jz L16
	movq $1, %r8
L15:
	addq %r8, %r10
	movq %r10, %rdi
	call putchar
	movq $65, %r10
	movq $0, %r8
	testq %r8, %r8
	jz L7
	movq $0, %r8
	testq %r8, %r8
	jz L7
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
L7:
	movq $0, %r8
	jmp L6
	jmp L7
L16:
	movq $0, %r8
	jmp L15
	jmp L16
L25:
	movq $0, %r8
	jmp L24
	jmp L25
L34:
	movq $0, %r8
	jmp L33
	jmp L34
	.data
