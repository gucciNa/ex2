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
	@ r11: �ʾ��� (�����ĤϤϤ�ڤ��������Τ��� r11 = 6)
	@ r12: �����å��ξ��ֵ���

	@ TEMPO�ϳ���κ���ˤ���ƥ�ݤ��ѹ����뤳��
	@ MIN_LEN�ϡ�������Ǻ�û�β���Ĺ���˹�碌�����ꤹ�뤳��
	@	��ʬ����: 1, Ȭʬ����: 2, ��ϻʬ����: 4, ����ϻʬ����: 8
	.equ	TEMPO,         190
	.equ	MIN_LEN,       4
	.equ	TIMER_HZ,      1000*1000*60 / TEMPO / MIN_LEN
	@ SOUND_LENGTH�ϲ���ο�(���������Ҥ��äƤ��벻��ϰ�Ĥȿ����뤳�ȡ�
	.equ	SOUND_LENGTH, 96
	.equ	CHAR_LENGTH, 64

	.include "common.h"
	.section .text
	.global choose_hungry
choose_hungry:
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
	bne	hungry_ghost	
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
	.byte 2, 2, 2, 2			@ 1
	.byte 2, 2, 2, 2, 4, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2
	.byte 4, 4, 4, 2, 2			@ 5
	.byte 4, 4, 4, 2, 2
	.byte 4, 4, 4, 2, 2
	.byte 4, 4, 4, 4
	.byte 4, 1, 1, 1, 1, 2, 2, 2, 2		@ 9
	.byte 4, 4, 2, 4, 2
	.byte 4, 4, 2, 4, 2
	.byte 4, 4, 4, 4
	.byte 2, 2, 2, 2, 4, 2, 2		@ 13
	.byte 4, 4, 4, 2, 2
	.byte 4, 4, 4, 4
	.byte 4, 4, 4, 4
	.byte 2, 1, 1, 1, 1, 2, 4, 4		@ 17
	
	@ sound_buffer
	@ �����򼨤��Хåե�
	@ ��¦��@�θ�ο����ϡ����Υ����ȤǤβ������ܤˤ��뤫�򼨤�
	@ �����˰��´���������̥����Ȥǲ�����ȹ礷�ƽ񤭴����������
sound_buffer:	
	.word   0,   0,   0,  G5			@ 1
	.word  G5,  G5,  E5,  E5,  F5,   0,  G5
	.word  G5,  G5, C5S, C5S,  D5,   0,  G5
	.word  G5, F5S,  F5,  E5,  D5, C5S,  B4,  A4
	.word  G4,  G5,  G4,  G5,  G5			@ 5
	.word  E5,  G5,  G5,   0,  G5
	.word  F5,  G5,  G5,   0,  G5
	.word  E5,  G5,  B5,  A5
	.word  G5,  G4, G4S,  A4, A4S,  A4,  G4,  A4, G4	@ 9
	.word  E4,  G4,  E4,  G4,  G4
	.word  F4,  G4,  F4,  G4,  G4
	.word  E4,  G4,  B4,  A4
	.word  G4, F4S,  F4,  E4,  D4,   0,  G4		@ 13
	.word  E4,  G4,  G4,   0,  G4
	.word  F4,  A4,  A4,  C5
	.word  E5,   0,  D5,   0
	.word  C5,  G4, G4S,  A4, A4S,  B4,  C4,   0	@ 17