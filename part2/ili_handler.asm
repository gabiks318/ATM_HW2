.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
  	movq 48(%rsp), %r9
	
	xorq %rdx, %rdx
	xorq %rdi, %rdi
	movq $1, %rdx

  	cmpb $0x0F, (%r9)
  	jne one_byte
	inc %rdx
	movb 1(%r9), %dil
	jmp call_funtion

  one_byte:
	movb (%r9), %dil
  call_funtion:
  	call what_to_do
	
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	
	cmp $0, %rax
	jne our_handler

	call *old_ili_handler

  our_handler:
  	mov %rax, %rdi
	cmp $2, %rdx
	je add_two
	addq $1, (%rsp)
	jmp finish

	add_two:
	addq $2, (%rsp)
	finish:	
  	iretq
