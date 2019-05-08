		;		ARM Programming Assignment #3: 32 bit IEEE 754 single-precision multiplier
		;
		;		Write a 32-bit floating point multiplier. The numbers will be represented
		;       in the single-precision IEEE 754 floating-point standard. The result should
		;       also be in IEEE 754 binary32. Assume you only have normalized numbers, i.e.
		;       the exponent is never 0b00000000.
		;		Write the result in the provided "fill" word.

		;		Your code here

floats	DCD		0xa0bcff0d, 0x13c0adea
result	FILL	8
space	FILL	8

main
		adr		r0, floats 							; get ready to load  numbers into adress
		ldr		r1, [r0], #4							; load first number into address r1
		ldr		r2, [r0], #8							; load second number into address r2
		adr		r0, result							; r0 no longer needed, get ready to put answer into r0
		lsr		r3, r1, #24							;isolate most significant bit
		lsr		r4, r2, #24							;isolate most significant bit
		add		r6, r3, r4							;add exponents
		sub		r6, r6, #127							;subtract biased exponent
		mov		r5, #10								; counter
		bl		multiply							;branch to multiply instruction
		mov		r2, r3								;places top half in r1, and bottom half in r2
		lsl		r1, r1, #2							;gets rid of understood bits
		lsr		r1, r1, #2							;lines up r2 again
		
shift
		
		lsrs		r1, r1, #1
		lsr		r2, r2, #1
		subs		r3, r3, #1
		bne		shift
		
		adr		r0, floats
		ldr		r6, [r0], #4
		ldr		r7, [r0]
		lsr		r6, r6, #23
		lsr		r7, r7, #23
		lsr		r4, r6, #8
		lsr		r5, r7, #8
		eors		r3, r4, r5
		
		add		r6, r6, r7
		sub		r6, r6, #0x7f
		lsl		r6, r6, #20
		add		r1, r1, r6
		adr		r0, result
		str		r1, [r0], #4
		str		r2, [r0]
		
		end
		
multiply
		mov		r3, #1	 				 ;setting mask to 1
		
		;splits	two numbers into halfs to be multiplied
		mov		r9, r1, lsr #16
		bic		r11, r1, r9, lsl #16
		mov		r10, r2, lsr #16
		bic		r12, r2, r10, lsl #16
		
		;num1	bottom half * num2 bottom half
		mov		r1,r11
		mov		r2,r12
		bl		ctr
		str		r6, [r0] 				;stores result in memory for due to lack of registers
		
		;num1	bottom half * num2 top half
		mov		r1,r11
		mov		r2,r10
		bl		ctr
		str		r6,[r0,#4]
		
		;num		1 top half * num 2 bottom half
		mov		r1, r9
		mov		r2,r12
		bl		ctr
		str		r6,[r0,#8]
		
		;num		1 top half * num 2 top half
		mov		r1,r9
		mov		r2,r10
		bl		ctr
		str		r6, [r0,#12]
		
		;adding	results together and setting flags
		ldr		r1, [r0,#4]
		ldr		r2, [r0,#8]
		adds		r1, r1,r2
		
		;loads	results from memory into registers
		ldr		r2, [r0, #12]
		ldr		r3,[r0,#8]
		ldr		r4,[r0,#4]
		ldr		r5,[r0]
		
		;adds	carry and shifts result 16 bits
		addcs	r2,r2, #&10000
		adds		r5,r5,r1,lsl #16
		adc		r2,r2,r1, lsr #16
		
		;stores	result
		str		r2, [r0]
		str		r5, [r0,#4]
		
		end
		
		;resets	ctr register and accumulator
ctr		mov		r5, #16
		mov		r6, #0
		
		;Multiply	uses
mul		mov		r10, #0
		
loop		movs		r9, r9, lsr #1
		addcs		r10, r10, r8
		mov		r8, r8, lsl #1
		cmp		r9, #1
		bgt		loop
		
		movs		r9, r9, lsr #1
		addcs		r10, r10, r8
		mov		pc, lr
