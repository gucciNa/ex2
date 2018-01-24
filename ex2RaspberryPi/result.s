	@ �������Υꥶ��Ȥ�ɽ�����륵�֥롼����

	@ r3: ������
	@ r4: on/off�ڤ��ؤ� (1:on, 0:off)
	@   �����費���ۤ�ξ����ֳ֤��뤿��
	@ r5: ���ѥ����ޡ�
	@ r6: �ʤοʹ�
	@ r7: �����ܤ�ɽ�����٤����򼨤��쥸����
	@ r8: 8*8�ɥåȥޥȥꥯ��LED�Σ��Ԥ�ɽ�����륿�����ѥ����ޡ�
	@ r9: 0.1�å�����ȥ����ޡ�
	@ r10: ����ѥ쥸����
	@ r11: ����ѥ쥸����
	.include "common.h"

	.equ	TEMPO,		90
	.equ	MIN_LEN,	8
	.equ	TIMER_HZ,	1000*1000*60 / TEMPO / MIN_LEN
	@ SOUND_LENGTH�ϲ���ο�(���������Ҥ��äƤ��벻��ϰ�Ĥȿ����뤳�ȡ�
	.equ	SOUND_LENGTH,	43
	
	.section .text
	.global result
result:
	str	r14, [sp, #-4]!		@ push r14
	@ �����ޡ��ν������, �쥸�����ν������Ԥ�
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]
	ldr	r1, =MINUTE_HZ
	add	r9, r8, r1
	ldr	r1, =TIMER_HZ
	add	r5, r8, r1
	ldr	r1, =(MINUTE_HZ / 100)
	add	r8, r8, r1
	mov	r7, #0
	cmp	r3, #100
	mov	r10, #1
	mov	r11, #1
	beq	fullCombo
	@ r2: ��ΰ�, r3: ���ΰ�
	mov	r4, #10
	udiv	r6, r3, r4
	mul	r6, r4, r6
	sub	r2, r3, r6
	sub	r3, r3, r2
	udiv	r3, r3, r4
	ldr	r1, =frame_buffer
	bl	makeNum
next:
	mov	r4, #0
	mov	r6, #0
timer:
	cmp	r6, #SOUND_LENGTH
	bmi	nextTimer
	ldr	r0, =GPIO_BASE		@ GPIO �����Ѥ�����
	@ GPIO #26 (SW2) �ؤ����Ϥ򸡾� (���Υܥ���)
	ldr 	r1, [r0, #(GPLEV0 + SW2_PORT / 32 * 4)]
	mov	r1, r1, lsr #(SW2_PORT % 32)
	ands	r1, r1, #0x1
	ldrne	r14, [sp], #4		@ pop r14
	bxne	r14
	mov	r6, #SOUND_LENGTH
nextTimer:	
	ldr	r0, =TIMER_BASE
	ldr	r1, [r0, #CLO]
	cmp	r5, r1
	blmi	jumpSoundMusic
	cmp	r9, r1
	blmi	count
	cmp	r8, r1
	blmi	jumpDisplay
	b	timer
	
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

jumpSoundMusic:
	str	r14, [sp, #-4]!		@ push r14
	str	r7, [sp, #-4]!		@ push r7
	str	r9, [sp, #-4]!		@ push r9
	str	r10, [sp, #-4]!		@ push r10
	ldr	r7, =TIMER_HZ
	ldr	r9, =sound_buffer
	ldr	r10, =soundLen_buffer
	bl	soundMusic
	cmp	r4, #1
	addeq	r6, r6, #1
	ldr	r10, [sp], #4		@ pop r10
	ldr	r9, [sp], #4		@ pop r9
	ldr	r7, [sp], #4		@ pop r7
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
count:
	str	r14, [sp, #-4]!		@ push r14
	str	r4, [sp, #-4]!		@ push r4
	str	r3, [sp, #-4]!		@ push r3
	str	r2, [sp, #-4]!		@ push r2
	str	r1, [sp, #-4]!		@ push r1
	cmp	r6, #32
	bpl	fullOrNot
	mov	r2, #10
	and	r4, r1, #3
	add	r10, r10, r4
	add	r10, r10, #1
	cmp	r10, #10
	subpl	r10, r10, #10
	mov	r2, #2
	mul	r11, r2, r11
	add	r11, r11, r4, lsr #1
	cmp	r11, #10
	subpl	r11, r11, #10
	mov	r2, r10
	mov	r3, r11
	b	resultScore
fullOrNot:
	cmp	r3, #100
	bne	resultScore
fullCombo:	
	ldr	r1, =frame_buffer
	mov	r4, #0x18
	strb	r4, [r1], #1
	mov	r4, #0x24
	strb	r4, [r1], #1
	mov	r4, #0x42
	strb	r4, [r1], #1
	mov	r4, #0x81
	strb	r4, [r1], #1
	mov	r4, #0x81
	strb	r4, [r1], #1
	mov	r4, #0x42
	strb	r4, [r1], #1
	mov	r4, #0x24
	strb	r4, [r1], #1
	mov	r4, #0x18
	strb	r4, [r1]
resultScore:
	ldr	r1, =frame_buffer
	bl	makeNum
	ldr	r1, =MINUTE_HZ
	add	r9, r9, r1
	ldr	r1, [sp], #4		@ pop r1
	ldr	r2, [sp], #4		@ pop r2
	ldr	r3, [sp], #4		@ pop r3
	ldr	r4, [sp], #4		@ pop r4
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
jumpDisplay:	
	str	r14, [sp, #-4]!		@ push r14
	ldr	r0, =frame_buffer
	bl	display
	add	r7, r7, #1
	cmp	r7, #8
	moveq	r7, #0
	ldr	r1, =(MINUTE_HZ / 100)
	add	r8, r8, r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

	.section .data
frame_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0

soundLen_buffer:
	@ �ɥ�������̣
	.byte 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1
	@ �ե���ե�����(FF:�����Υե���ե�����)
	.byte 2, 2, 2, 6, 6, 6, 2, 2
	.byte 2, 8, 8, 8
	

sound_buffer:
	@ �ɥ�������̣
	.word F3, F5, F3, F5, F3, F5, F3, F5
	.word F3, F5, F3, F5, F3, F5, F3, F5
	.word F3, F5, F3, F5, F3, F5, F3, F5
	.word F3, F5, F3, F5, F3, F5, F3, F5
	@ �ե���ե�����(FF:�����Υե���ե�����)	
	.word D5, D5, D5, D5, B5F, C5, D5, 0
	.word C5, D5,  0,  0
