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
	@ r11: �ʾ��� (������ۤȤ��ƺ餯�֤�ǡ���Τ��� r11 = 5)
	@ r12: �����å��ξ��ֵ���

	@ SOUND_LENGTH�ϲ���ο�(���������Ҥ��äƤ��벻��ϰ�Ĥȿ����뤳�ȡ�
	.equ	SOUND_LENGTH, 40
	.equ	CHAR_LENGTH, 106		@ �ʤΥ���������

	.include "rinsaku.h"
	.include "common.h"
	.section .text
	.global choose_rinsaku
choose_rinsaku:
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
	bne	music_rinsaku
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
	.byte 4, 4, 4, 4, 2, 2, 4, 2, 2		@ 39-40
	.byte 2, 2, 2, 2, 2, 2, 2, 2		@ 41
	.byte 4, 2, 2, 2, 1, 1, 2, 2		@ 42
	.byte 4, 2, 2, 2, 2, 2, 2		@ 43
	.byte 4, 2, 2, 4, 2, 2			@ 44
	.byte 2, 2, 2, 2, 4, 2, 2		@ 45
	.byte 4, 2, 2, 4, 2, 2			@ 46
	.byte 16, 12, 2, 2, 2, 14		@ 47-9
	.byte 0, 0, 0
	
	@ sound_buffer
	@ �����򼨤��Хåե�
	@ http://guitarlist.net/bandscore/beniirolitmus/rintoshite/rintoshite2.php
	@ ��¦��@�θ�ο����ϡ����Υ����ȤǤβ������ܤˤ��뤫�򼨤�
sound_buffer:	
	.word   0, C4S,  E4, F4S, F4S,  A4, C5S,  B4, C5S @ �����Ƥ����ƤĤ�
	.word  B4, C5S,  B4,  A4, F4S,   0,  E4, C4S	@ �ˤ��ͤ��� ����
	.word  B3,  B3, C4S,  E4, F4S,  E4, C4S,  E4	@ �䤫�ʤ����ˤ�
	.word F4S,  F4, F4S, G4S,   0, C4S,  E4		@ �������礦 ����
	.word F4S, F4S,  A4, C5S,  B4, C5S		@ �� ���餺 ����
	.word  B4, C5S,  E5, F5S, C5S,  B4,  A4		@ ��Ȥʤ����Ĥ�
	.word F4S, F4S, G4S,  E4, C4S,  E4		@ �ߤϤ椯����
	.word F4S, F4S, C4S,  E4, F4S,   0		@ �줺���Τޤ�
