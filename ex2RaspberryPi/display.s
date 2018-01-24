@ 画面点灯系統サブルーチン
	.include "common.h"
	.section .text
	.global	display
	@ r7 に格納された今現在表示すべき列を点灯し, 手前の列を消灯するサブルーチン
	@ r0 にあらかじめ、(frame_bufferの)番地を格納する必要がある
display:
	str	r14, [sp, #-4]!		@ push r14
	str	r3, [sp, #-4]!		@ push r3
	str	r1, [sp, #-4]!		@ push r1
	str	r0, [sp, #-4]!		@ push r0
	mov	r3, r0
	ldr	r0, =GPIO_BASE
	cmp	r7, #1
	beq	lightRow2
	cmp	r7, #2
	beq	lightRow3
	cmp	r7, #3
	beq	lightRow4
	cmp	r7, #4
	beq	lightRow5
	cmp	r7, #5
	beq	lightRow6
	cmp	r7, #6
	beq	lightRow7
	cmp	r7, #7
	beq	lightRow8

lightRow1:
	@ 1行目を点灯
	@ 第1行だけ点灯
	mov     r1, #(1 << ROW8_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW1_PORT)
	str     r1, [r0, #GPCLR0]		@ 点灯
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow2:	
	@ 2行目を点灯
	@ 第2行だけ点灯
	mov     r1, #(1 << ROW1_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW2_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow3:	
	@ 3行目を点灯
	@ 第3行だけ点灯
	mov     r1, #(1 << ROW2_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW3_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow4:
	@ 4行目を点灯
	@ 第4行だけ点灯
	mov     r1, #(1 << ROW3_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW4_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow5:	
	@ 5行目を点灯
	@ 第5行だけ点灯
	mov     r1, #(1 << ROW4_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW5_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow6:	
	@ 6行目を点灯
	@ 第6行だけ点灯
	mov     r1, #(1 << ROW5_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW6_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow7:	
	@ 7行目を点灯
	@ 第7行だけ点灯
	mov     r1, #(1 << ROW6_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW7_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd
lightRow8:	
	@ 8行目を点灯
	@ 第8行だけ点灯
	mov     r1, #(1 << ROW7_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW8_PORT)         
	str     r1, [r0, #GPCLR0]
	@ 列の点灯
	bl	lightUpCol
	b	displayEnd

displayEnd:
	ldr	r0, [sp], #4		@ pop r0
	ldr	r1, [sp], #4		@ pop r1
	ldr	r3, [sp], #4		@ pop r3
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

	@ r3 に格納してある番地(frame_buffer)から読み出し，表示するサブルーチン
lightUpCol:
	str	r14, [sp, #-4]!		@ push r14
	str	r4, [sp, #-4]!		@ push r4
	str	r1, [sp, #-4]!		@ push r1
	ldrb	r4, [r3, r7]
	mov     r1, #(1 << COL8_PORT)
	bl	onOff
	mov     r1, #(1 << COL7_PORT)
	bl	onOff
	mov     r1, #(1 << COL6_PORT)
	bl	onOff
	mov     r1, #(1 << COL5_PORT)
	bl	onOff
	mov     r1, #(1 << COL4_PORT)
	bl	onOff
	mov     r1, #(1 << COL3_PORT)
	bl	onOff
	mov     r1, #(1 << COL2_PORT)
	bl	onOff
	mov     r1, #(1 << COL1_PORT)
	bl	onOff
	ldr	r1, [sp], #4		@ pop r1
	ldr	r4, [sp], #4		@ pop r4
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

onOff:
	str	r14, [sp, #-4]!		@ push r14
	str	r5, [sp, #-4]!		@ push r5
	str	r1, [sp, #-4]!		@ push r1
	ands	r5, r4, #1
	streq   r1, [r0, #GPCLR0]
	strne	r1, [r0, #GPSET0]
	lsr	r4, r4, #1
	ldr	r1, [sp], #4		@ pop r1
	ldr	r5, [sp], #4		@ pop r5
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
