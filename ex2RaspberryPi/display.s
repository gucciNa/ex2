@ ���������������֥롼����
	.include "common.h"
	.section .text
	.global	display
	@ r7 �˳�Ǽ���줿������ɽ�����٤����������, ���������������륵�֥롼����
	@ r0 �ˤ��餫���ᡢ(frame_buffer��)���Ϥ��Ǽ����ɬ�פ�����
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
	@ 1���ܤ�����
	@ ��1�Ԥ�������
	mov     r1, #(1 << ROW8_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW1_PORT)
	str     r1, [r0, #GPCLR0]		@ ����
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow2:	
	@ 2���ܤ�����
	@ ��2�Ԥ�������
	mov     r1, #(1 << ROW1_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW2_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow3:	
	@ 3���ܤ�����
	@ ��3�Ԥ�������
	mov     r1, #(1 << ROW2_PORT)
	str     r1, [r0, #GPSET0]
	mov     r1, #(1 << ROW3_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow4:
	@ 4���ܤ�����
	@ ��4�Ԥ�������
	mov     r1, #(1 << ROW3_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW4_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow5:	
	@ 5���ܤ�����
	@ ��5�Ԥ�������
	mov     r1, #(1 << ROW4_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW5_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow6:	
	@ 6���ܤ�����
	@ ��6�Ԥ�������
	mov     r1, #(1 << ROW5_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW6_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow7:	
	@ 7���ܤ�����
	@ ��7�Ԥ�������
	mov     r1, #(1 << ROW6_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW7_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd
lightRow8:	
	@ 8���ܤ�����
	@ ��8�Ԥ�������
	mov     r1, #(1 << ROW7_PORT)
	str     r1, [r0, #GPSET0]		
	mov     r1, #(1 << ROW8_PORT)         
	str     r1, [r0, #GPCLR0]
	@ �������
	bl	lightUpCol
	b	displayEnd

displayEnd:
	ldr	r0, [sp], #4		@ pop r0
	ldr	r1, [sp], #4		@ pop r1
	ldr	r3, [sp], #4		@ pop r3
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

	@ r3 �˳�Ǽ���Ƥ�������(frame_buffer)�����ɤ߽Ф���ɽ�����륵�֥롼����
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
