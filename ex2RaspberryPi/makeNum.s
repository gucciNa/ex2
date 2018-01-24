@ r1: frame_bufferの番地
@ r2: 一の位, r3: 十の位	
@ を渡され、表示させる数字の形をframe_bufferに書き込むサブルーチン
	.equ	GPIO_BASE,  0x3f200000	@ GPIOベースアドレス
	.equ	LED_PORT,   10		@ LEDが接続されたGPIOのポート番号
	.equ	GPSET0,     0x1C	@ GPIOポートの出力値を1にするための番地のオフセット
	.equ	GPCLR0,     0x28	@ GPIOポートの出力値を0にするための番地のオフセット
	.equ	LIGHT1110, 0xe
	.equ  	LIGHT0100, 0x4
	.equ	LIGHT1100, 0xc
	.equ	LIGHT1000, 0x8
	.equ	LIGHT1010, 0xa
	.equ	LIGHT0010, 0x2

	.equ	LED_HZ,    800 * 1000
	
	.section .text
	.global	makeNum
makeNum:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	str	r2, [sp, #-4]!		@ push r2
	str	r3, [sp, #-4]!		@ push r3
	str	r4, [sp, #-4]!		@ push r4
	str	r5, [sp, #-4]!		@ push r5
	str	r6, [sp, #-4]!		@ push r6
	str	r7, [sp, #-4]!		@ push r7
	str	r8, [sp, #-4]!		@ push r8
	str	r9, [sp, #-4]!		@ push r9
	
	cmp	r3, #1
	moveq	r4, #(LIGHT0100 << 4)
	moveq	r5, #(LIGHT1100 << 4)
	moveq	r6, #(LIGHT0100 << 4)
	moveq	r7, #(LIGHT0100 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #2
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT0010 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT1000 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #3
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT0010 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT0010 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #4
	moveq	r4, #(LIGHT1010 << 4)
	moveq	r5, #(LIGHT1010 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT0010 << 4)
	moveq	r8, #(LIGHT0010 << 4)
	beq	cmpr2
	cmp	r3, #5
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT1000 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT0010 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #6
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT1000 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT1010 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #7
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT1010 << 4)
	moveq	r6, #(LIGHT0010 << 4)
	moveq	r7, #(LIGHT0010 << 4)
	moveq	r8, #(LIGHT0010 << 4)
	beq	cmpr2
	cmp	r3, #8
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT1010 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT1010 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2
	cmp	r3, #9
	moveq	r4, #(LIGHT1110 << 4)
	moveq	r5, #(LIGHT1010 << 4)
	moveq	r6, #(LIGHT1110 << 4)
	moveq	r7, #(LIGHT0010 << 4)
	moveq	r8, #(LIGHT1110 << 4)
	beq	cmpr2	
	mov	r4, #(LIGHT1110 << 4)
	mov	r5, #(LIGHT1010 << 4)
	mov	r6, #(LIGHT1010 << 4)
	mov	r7, #(LIGHT1010 << 4)
	mov	r8, #(LIGHT1110 << 4)
cmpr2:	
	cmp	r2, #1
	addeq	r4, r4, #LIGHT0100
	addeq	r5, r5, #LIGHT1100
	addeq	r6, r6, #LIGHT0100
	addeq	r7, r7, #LIGHT0100
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #2
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT0010
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT1000
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #3
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT0010
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT0010
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #4
	addeq	r4, r4, #LIGHT1010
	addeq	r5, r5, #LIGHT1010
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT0010
	addeq	r8, r8, #LIGHT0010
	beq	writeFrameBuffer
	cmp	r2, #5
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT1000
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT0010
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #6
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT1000
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT1010
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #7
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT1010
	addeq	r6, r6, #LIGHT0010
	addeq	r7, r7, #LIGHT0010
	addeq	r8, r8, #LIGHT0010
	beq	writeFrameBuffer
	cmp	r2, #8
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT1010
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT1010
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	cmp	r2, #9
	addeq	r4, r4, #LIGHT1110
	addeq	r5, r5, #LIGHT1010
	addeq	r6, r6, #LIGHT1110
	addeq	r7, r7, #LIGHT0010
	addeq	r8, r8, #LIGHT1110
	beq	writeFrameBuffer
	add	r4, r4, #LIGHT1110
	add	r5, r5, #LIGHT1010
	add	r6, r6, #LIGHT1010
	add	r7, r7, #LIGHT1010
	add	r8, r8, #LIGHT1110
writeFrameBuffer:	
	mov	r9, #0x0
	strb	r9, [r1], #1
	strb	r4, [r1], #1
	strb	r5, [r1], #1
	strb	r6, [r1], #1
	strb	r7, [r1], #1
	strb	r8, [r1], #1
	strb	r9, [r1], #1
	strb	r9, [r1]

	ldr	r9, [sp], #4	@ pop r9
	ldr	r8, [sp], #4	@ pop r8
	ldr	r7, [sp], #4	@ pop r7
	ldr	r6, [sp], #4	@ pop r6
	ldr	r5, [sp], #4	@ pop r5
	ldr	r4, [sp], #4	@ pop r4
	ldr	r3, [sp], #4	@ pop r3
	ldr	r2, [sp], #4	@ pop r2
	ldr	r1, [sp], #4	@ pop r1
	ldr	r14, [sp], #4	@ pop r14
	
	bx	r14
	
	.global lightOnLED
lightOnLED:
	@ r10: LED点灯用タイマー
	str	r14, [sp, #-4]!		@ push r14
	str	r0, [sp, #-4]!		@ push r0
	str	r1, [sp, #-4]!		@ push r1
	ldr	r0, =GPIO_BASE
	mov	r1, #(1 << (LED_PORT % 32))
	str 	r1, [r0, #(GPSET0 + LED_PORT / 32 * 4)]
	ldr	r1, [sp], #4		@ pop r1
	ldr	r0, [sp], #4		@ pop r0
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

	.global lightOffLED
lightOffLED:
	@ r11: LED消灯用タイマー
	str	r14, [sp, #-4]!		@ push r14
	str	r0, [sp, #-4]!		@ push r0
	str	r1, [sp, #-4]!		@ push r1
	ldr	r0, =GPIO_BASE
	mov	r1, #(1 << (LED_PORT % 32))
	str 	r1, [r0, #(GPCLR0 + LED_PORT / 32 * 4)]
	ldr	r1, [sp], #4		@ pop r1
	ldr	r0, [sp], #4		@ pop r0
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
