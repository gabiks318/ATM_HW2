.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
        # rdi - input
        # rsi - key
        # r9  - i
        pushq %rbp
        movq %rsp, %rbp
        xorq %r9,%r9
        
    xor_op:
        # Calculate XOR and store value
        xor %rbx, %rbx
        xor %rcx, %rcx
        movb (%rdi), %bl
        movb (%rsi), %cl
        xor %bl, %cl
        movb %cl, (%rdi)
        
        # Increment values
        addq $1, %rdi
        addq $1, %rsi
        inc %r9
        cmp $16, %r9
        jne xor_op
        
        leave
	ret


byteSubstitution:
        # rdi - input
        # r9  - i
        # r10 - current address
        # r11 - sbox address
        # bl  - current byte
        # cl  - swapped byte
        pushq %rbp
        movq %rsp, %rbp
        xorq %r9, %r9
        xorq %r11, %r11
        leaq sbox(%rip), %r11
        
        subsitute:
        xorq %r10, %r10
        xorq %rbx, %rbx
        xorq %rcx, %rcx
        movb (%rdi), %bl
        add  %r11, %rbx
        movb (%rbx), %cl
        movb %cl, (%rdi)
        
        addq $1, %rdi
        inc %r9
        cmp $16, %r9
        jne subsitute
        
        leave
	ret


shiftRows:
        # rdi - input
        # r9  - i
        # r10 - j
        # al  - row[0]
        # bl  - row[1]
        # cl  - row[2]
        # dl  - row[3]
        pushq %rbp
        movq %rsp, %rbp
        xorq %r9, %r9
        xorq %r10, %r10
        
        inner_loop:
        cmp %r10, %r9
        je outer_loop
        inc %r10
        
        xorq %rax, %rax
        xorq %rbx, %rbx
        xorq %rcx, %rcx
        xorq %rdx, %rdx
        
        movb (%rdi), %al
        movb 1(%rdi), %bl
        movb 2(%rdi), %cl
        movb 3(%rdi), %dl
        
        movb %al, 3(%rdi)
        movb %bl, (%rdi)
        movb %cl, 1(%rdi)
        movb %dl, 2(%rdi)
        
        
        jmp inner_loop
        
        outer_loop:
        xorq %r10, %r10
        inc %r9
        addq $4, %rdi
        cmp $4,%r9
        jne inner_loop
                
        
        leave
	ret


cipher:
        # rdi - input
        # rsi - key
        # rdx - len
        # r9  - i
        # r10 - j
        # r11 - input_copy
        pushq %rbp
        movq %rsp, %rbp
        
        xorq %r9, %r9
        xorq %r10, %r10
        movq %rdi, %r11
        
        # 1.Key mixing
        key_mix:
        push %rdi
        push %rsi
        push %rdx
        push %r9
        
        call keyMixing
        
        pop %r9
        pop %rdx
        pop %rsi
        pop %rdi
        
        loop:
        # a.byteSubstitution
        push %rdi
        push %rsi
        push %rdx
        push %r9
        
        call byteSubstitution
        
        pop %r9
        pop %rdx
        pop %rsi
        pop %rdi
        
        # b.shiftRows
        push %rdi
        push %rsi
        push %rdx
        push %r9
        
        call shiftRows
        
        pop %r9
        pop %rdx
        pop %rsi
        pop %rdi
        
        # c.mixColumns
        push %rdi
        push %rsi
        push %rdx
        push %r9
        
        call mixColumns
        
        pop %r9
        pop %rdx
        pop %rsi
        pop %rdi
        
        # d.keyMixing
        push %rdi
        push %rsi
        push %rdx
        push %r9
        
        call keyMixing
        
        pop %r9
        pop %rdx
        pop %rsi
        pop %rdi
        
        inc %r10
        cmp $9, %r10
        jne loop
        xor %r10, %r10
        /*
        # 3.byteSubstitution
        push %rdi
        push %rsi
        push %rdx
        
        call byteSubstitution
        
        pop %rdx
        pop %rsi
        pop %rdi
        
        # 4.shiftRows
        push %rdi
        push %rsi
        push %rdx
        
        call shiftRows
        
        pop %rdx
        pop %rsi
        pop %rdi
        
        # 5.keyMixing
        push %rdi
        push %rsi
        push %rdx
        
        call keyMixing
        
        pop %rdx
        pop %rsi
        pop %rdi
        */
        addq $16, %rdi
        inc %r9
        cmp %r9, %rdx
        jl key_mix
        
        leave
	ret
