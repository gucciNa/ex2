	@ ���ʲ��̤�ɽ�����륵�֥롼����
	
	@ �ʤ�񤭴�����Ȥ���
	@ .equ�Τ����Ρ�TEMPO, MIN_LEN, SOUND_LENGTH
	@ buffer�Τ����Ρ�sound_buffer, soundLen_buffer
	@ ��񤭴����뤳��
	
	@ r4: on/off�ڤ��ؤ� (1:on, 0:off)
	@   �����費���ۤ�ξ����ֳ֤��뤿��
	@ r5: ���ѥ����ޡ�
	@ r6: �ʤοʹ�
	@ r7: �����ܤ�ɽ�����٤����򼨤��쥸����
	@ r8: 8*8�ɥåȥޥȥꥯ��LED�Σ��Ԥ�ɽ�����륿�����ѥ����ޡ�
	@ r9 : ���ȥåץ����å��ѥ����ޡ�
	@ r11: �ʾ��� (����ϥ��ߥ�곤�����Τ��� r11 = 2)
	@ r12: �����å��ξ��ֵ���

	@ SOUND_LENGTH�ϲ���ο�(���������Ҥ��äƤ��벻��ϰ�Ĥȿ����뤳�ȡ�
	.equ	SOUND_LENGTH, 80
	.equ	CHAR_LENGTH, 81

	.include "common.h"
	.include "umiyuri.h"
	.section .text
	.global choose_umiyuri
choose_umiyuri:
	str	r14, [sp, #-4]!		@ push r14
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]
	mov	r9, r8
	ldr	r1, =TIMER_HZ
	add	r9, r9, r1
	mov	r5, r9
	ldr	r1, =(TIMER_HZ / 100)
	add	r8, r8, r1
	mov	r10, #0				@ ɽ���Υ�����
	mov	r7, #0				@ �ǽ��1����
	ldr	r1, =frame_buffer
	bl	select
	mov	r6, #0
	mov	r4, #0

timer:	@ r7: �����ܤ�ɽ�����٤����򼨤��쥸����
	@ r8: 8*8�ɥåȥޥȥꥯ��LED�Σ��Ԥ�ɽ�����륿�����ѥ����ޡ�
	@ r9 : ���ȥåץ����å��ѥ����ޡ�
	ldr	r0, =GPIO_BASE		@ GPIO �����Ѥ�����
	@ GPIO #13 (SW1) �ؤ����Ϥ򸡾� (�ФΥܥ���)
	ldr 	r2, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW1_PORT % 32)
	ands	r1, r2, #0x1
	ldrne	r14, [sp], #4		@ pop r14
	bne	music_umiyuri
	ldr	r0, =TIMER_BASE
	ldr	r1, [r0, #CLO]
	cmp	r5, r1
	blmi	jumpSoundMusic
	cmp	r9, r1
	blmi	count
	cmp	r0, #1
	addeq	r11, r11, #1
	ldreq	r14, [sp], #4		@ pop r14
	bxeq	r14
	cmp	r0, #2
	subeq	r11, r11, #1
	ldreq	r14, [sp], #4		@ pop r14
	bxeq	r14
	cmp	r8, r1
	blmi	jumpDisplay
	b	timer
	
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
	ldr	r9, =SOUND_LENGTH
	cmp	r6, r9
	moveq	r6, #0
	ldr	r10, [sp], #4		@ pop r10
	ldr	r9, [sp], #4		@ pop r9
	ldr	r7, [sp], #4		@ pop r7
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
count:
	str	r14, [sp, #-4]!		@ push r14
	ldr	r1, =frame_buffer
	bl	select
	ldr	r1, =TIMER_HZ
	add	r9, r9, r1
	add	r10, r10, #1
	cmp	r10, #CHAR_LENGTH
	moveq	r10, #0
	bl	checkButton
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

jumpDisplay:	
	str	r14, [sp, #-4]!		@ push r14
	ldr	r0, =frame_buffer
	bl	display
	add	r7, r7, #1
	cmp	r7, #8
	moveq	r7, #0
	ldr	r1, =(TIMER_HZ / 100)
	add	r8, r8, r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
	.section .data
frame_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0

	@ soundLen_buffer
	@ ����Ĺ���򼨤��Хåե�
soundLen_buffer:
	.byte 2, 2
	.byte 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1	@ 31
	.byte 2, 1, 1, 1, 1, 1, 1, 2, 2, 4
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 1, 1
	.byte 2, 2, 2, 2, 4, 2, 1, 1			@ 34
	.byte 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 2			@ 37
	.byte 2, 2, 2, 2, 4,10				@ 38
	
	@ sound_buffer
	@ �����򼨤��Хåե�
	@ ��¦��@�θ�ο����ϡ����Υ����ȤǤβ������ܤˤ��뤫�򼨤�
	@ �����˰��´���������̥����Ȥǲ�����ȹ礷�ƽ񤭴��������
sound_buffer:	

	.word   D5, B4F							@ 30
	.word  B4F,  F4,  F4,  C5, B4F, B4F,  D5,  F5, F5,  G5, D5, C5	@ 31
	.word  B4F,  D5,  D5,  C5, B4F, B4F,  C5,  D5, F5,  D5		@ 32
	.word  B4F,  F4,  C5, B4F,  C5,  D5,  F5,  D5, C5, B4F		@ 33
	.word  B4F,  D5,  C5,  D5, B4F,   0,  G4,  A4			@ 34
	.word  B4F,  F4,  F4,  C5, B4F,  C5,  D5,  F5, F5,  G5, D5, C5	@ 35
	.word  B4F, B4F,  D5,  D5,  C5, B4F, B4F,  C5, D5,  F5, D5	@ 36
	.word  B4F,  F4,  C5, B4F, B4F,  D5,  F5,  D5, C5		@ 37
	.word  B4F,  D5,  C5,  D5, B4F,   0				@ 38
