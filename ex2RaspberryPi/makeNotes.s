@	.equ	LIGHT111, 0xe0
@	.equ  LIGHT010, 0x40
@	.equ	LIGHT110, 0xc0
@	.equ	LIGHT100, 0x80
@	.equ	LIGHT101, 0xa0
@	.equ	LIGHT001, 0x20
@	.equ	LIGHT011, 0x60
	.equ	LIGHT000, 0x0

	.equ	LIGHT111, 0x70
	.equ  LIGHT010, 0x20
	.equ	LIGHT110, 0x60
	.equ	LIGHT100, 0x40
	.equ	LIGHT101, 0x50
	.equ	LIGHT001, 0x10
	.equ	LIGHT011, 0x30

	.include "common.h"
	.section .text
	.global	makeNotes
makeNotes:
	@ r11: notes_buffer
	@ r12: $B2;%2!<IhLL$N?J9T(B
	str	r14, [sp, #-4]!		@ push r14
	str	r4, [sp, #-4]!		@ push r4
	str	r3, [sp, #-4]!		@ push r3
	str	r2, [sp, #-4]!		@ push r2
	ldr	r3, =light_buffer
	ldrb	r2, [r11, r12] 
	@ $B1&>e$K?75,%N!<%D(B
	lsr	r4, r2, #3
	and	r4, r4, #1
	cmp	r4, #1
	streqb	r4, [r3, #3]
	@ $B:8>e$K?75,%N!<%D(B
	lsr	r4, r2, #2
	and	r4, r4, #1
	cmp	r4, #1
	streqb	r4, [r3, #2]
	@ $B1&2<$K?75,%N!<%D(B
	lsr	r4, r2, #1
	and	r4, r4, #1
	cmp	r4, #1
	streqb	r4, [r3, #1]
	@ $B:82<$K?75,%N!<%D(B
	lsr	r4, r2, #0
	and	r4, r4, #1
	cmp	r4, #1
	streqb	r4, [r3, #0]
	ldr	r2, [sp], #4		@ pop r2
	ldr	r3, [sp], #4		@ pop r3
	ldr	r4, [sp], #4		@ pop r4
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

	@ r11: $B%9%$%C%A$NF~NO>u67$rJ]4I(B
	@ r3 : $B%9%3%"(B
	@ r1 : frame_buffer
	.global renewNotes
renewNotes:	
	str	r14, [sp, #-4]!		@ push r14
	str	r0, [sp, #-4]!		@ push r0
	str	r1, [sp, #-4]!		@ push r1
	str	r2, [sp, #-4]!		@ push r2
	str	r4, [sp, #-4]!		@ push r4
	str	r5, [sp, #-4]!		@ push r5
	str	r6, [sp, #-4]!		@ push r6
	str	r7, [sp, #-4]!		@ push r7
	str	r8, [sp, #-4]!		@ push r8
	str	r9, [sp, #-4]!		@ push r9
	str	r10, [sp, #-4]!		@ push r10
	str	r12, [sp, #-4]!		@ push r12
	bl	lightOffLED
	ldr	r0, =GPIO_BASE
	@ GPIO #13 (SW1) $B$X$NF~NO$r8!>Z(B ($B:82<(B,$BNP$N%\%?%s(B)
	ldr 	r5, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
	mov	r5, r5, lsr #(SW1_PORT % 32)
	ands	r4, r5, #0x1
	mov	r10, r4, lsl #0
	@ GPIO #26 (SW2) $B$X$NF~NO$r8!>Z(B ($B1&2<(B,$B9u$N%\%?%s(B)
	ldr 	r5, [r0, #(GPLEV0 + SW2_PORT / 32 * 4)]
	mov	r5, r5, lsr #(SW2_PORT % 32)
	ands	r4, r5, #0x1
	add	r10, r10, r4, lsl #1
	@ GPIO #5 (SW3) $B$X$NF~NO$r8!>Z(B ($B:8>e(B,$B@V$N%\%?%s(B)
	ldr 	r5, [r0, #(GPLEV0 + SW3_PORT / 32 * 4)]
	mov	r5, r5, lsr #(SW3_PORT % 32)
	and	r4, r5, #0x1
	add	r10, r10, r4, lsl #2
	@ GPIO #6 (SW4) $B$X$NF~NO$r8!>Z(B ($B1&>e(B,$B@D$N%\%?%s(B)
	ldr 	r5, [r0, #(GPLEV0 + SW4_PORT / 32 * 4)]
	mov	r5, r5, lsr #(SW4_PORT % 32)
	and	r4, r5, #0x1
	add	r10, r10, r4, lsl #3
	eor	r12, r11, r10	@ $BGSB>E*O@M}OB(B
	and	r12, r12, r10	@ r12 $B$G(B 1 $B$NItJ,$OH=DjBP>](B
	mov	r11, r10	@ $B%9%$%C%A$NF~NO>u67$N99?7(B
	mov	r4, #0
	mov	r5, #0
	mov	r6, #0
	mov	r7, #0
	mov	r8, #0
	mov	r9, #0
	
	ldr	r0, =light_buffer
	ldrb	r2, [r0, #3]		@$B1&>e(B
	mov	r10, #3
	bl	compareLight
	strb	r2, [r0, #3]
	mov	r7, r4, lsr #3
	mov	r8, r5, lsr #3
	mov	r9, r6, lsr #3
	ldrb	r2, [r0, #2]		@$B:8>e(B
	mov	r10, #2
	bl	compareLight
	strb	r2, [r0, #2]
	add	r4, r4, r7			@ $B0lHV>e$N9T$N(Bframe_buffer$B$N%"%l(B
	add	r5, r5, r8
	add	r6, r6, r9
	@$B0lC6(Bframe_buffer$B$KFM$C9~$`(B
	strb	r4, [r1], #1
	strb	r5, [r1], #1
	strb	r6, [r1], #1

	ldrb	r2, [r0, #1]		@$B1&>e(B
	mov	r10, #1
	bl	compareLight
	strb	r2, [r0, #1]
	mov	r7, r4, lsr #3
	mov	r8, r5, lsr #3
	mov	r9, r6, lsr #3

	ldrb	r2, [r0, #0]		@$B:82<(B
	mov	r10, #0
	bl	compareLight
	strb	r2, [r0, #0]
	add	r4, r4, r7
	add	r5, r5, r8
	add	r6, r6, r9
	strb	r4, [r1], #1
	strb	r5, [r1], #1
	strb	r6, [r1], #1
	strb	r10, [r1], #1
	strb	r10, [r1]

	ldr	r12, [sp], #4	@pop r12
	ldr	r10, [sp], #4	@pop r10
	ldr	r9, [sp], #4	@pop r9
	ldr	r8, [sp], #4	@pop r8
	ldr	r7, [sp], #4	@pop r7
	ldr	r6, [sp], #4	@pop r6
	ldr	r5, [sp], #4	@pop r5
	ldr	r4, [sp], #4	@pop r4
	ldr	r2, [sp], #4	@pop r2
	ldr	r1, [sp], #4	@pop r1
	ldr	r0, [sp], #4	@pop r0
	ldr	r14, [sp], #4	@pop r14
	
	bx	r14

compareLight:
	str	r14, [sp, #-4]!		@ push r14
	str	r12, [sp, #-4]!		@ push r12
	str	r10, [sp, #-4]!		@ push r10
	
	cmp	r2, #0
	moveq	r4, #LIGHT000
	moveq	r5, #LIGHT000
	moveq	r6, #LIGHT000
	cmp	r2, #1
	moveq	r4, #LIGHT001
	moveq	r5, #LIGHT000
	moveq	r6, #LIGHT000
	cmp	r2, #2
	moveq	r4, #LIGHT011
	moveq	r5, #LIGHT000
	moveq	r6, #LIGHT000
	cmp	r2, #3
	moveq	r4, #LIGHT111
	moveq	r5, #LIGHT000
	moveq	r6, #LIGHT000
	cmp	r2, #4
	moveq	r4, #LIGHT111
	moveq	r5, #LIGHT100
	moveq	r6, #LIGHT000
	cmp	r2, #5
	moveq	r4, #LIGHT111
	moveq	r5, #LIGHT100
	moveq	r6, #LIGHT100
	cmp	r2, #6
	moveq	r4, #LIGHT111
	moveq	r5, #LIGHT100
	moveq	r6, #LIGHT110
	cmp	r2, #7
	moveq	r4, #LIGHT111
	moveq	r5, #LIGHT100
	moveq	r6, #LIGHT111
	cmp	r2, #8
	bne	cmp9
	mov	r4, #LIGHT111
	mov	r5, #LIGHT101
	mov	r6, #LIGHT111
	mov	r10, r12, lsr r10
	ands	r10, r10, #1
	addne	r3, r10
	blne	lightOnLED
cmp9:	
	cmp	r2, #9
	bne	cmp10
	mov	r4, #LIGHT111
	mov	r5, #LIGHT111
	mov	r6, #LIGHT111
	mov	r10, r12, lsr r10
	ands	r10, r10, #1
	addne	r3, r10
	blne	lightOnLED
cmp10:	
	cmp	r2, #10			@$BA4ItI=<($7$?>uBV$G$NM>Gr(B	$B>C$9$+$b(B
	bne	compareEnd
	mov	r4, #LIGHT111
	mov	r5, #LIGHT111
	mov	r6, #LIGHT111
	mov	r10, r12, lsr r10	@ r2 $B$,(B8,9,10$B$N$H$-(B
	ands	r10, r10, #1		@ $BBP1~$9$kF~NO$r$9$k$H(B
	addne	r3, r10			@ $B%9%3%"$r(B 1 $BA}2C(B
	blne	lightOnLED
compareEnd:	
	cmp	r2, #0
	addne	r2, r2, #1
	cmp	r2, #11
	moveq	r2, #0
	
	ldr	r10, [sp], #4	@pop r10
	ldr	r12, [sp], #4	@pop r12
	ldr	r14, [sp], #4	@pop r14
	bx	r14

	.section	.data
light_buffer:
	.byte	0, 0, 0, 0
