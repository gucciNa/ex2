@ 音を鳴らす処理系等のサブルーチン

@ r4: on/off切り替え (1:on, 0:off)
@   →　毎音、ほんの少し間隔を作るため
@ r5: 曲用タイマー
@ r6: 曲の進行
	.include "common.h"

	.section .text
	.global soundMusic
	@ r7: TIMER_HZ, r8: SOUND_LENGTH
	@ r9: sound_buffer, r10: soundLen_buffer
soundMusic:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	str	r2, [sp, #-4]!		@ push r2
	rsbs	r4, #1			@ on/off切り替え
	moveq	r2, r7, lsr #3
	addeq	r5, r5, r2
	beq	notSound
	@ PWMの動作モードの設定
	ldr	r0, =PWM_BASE
	ldr	r1, =PWM_SET
	str	r1, [r0]
	ldr 	r0, =PWM_BASE
	bl	checkSound		@ r1に何の音かを入れる
	cmp	r1, #0
	beq	notSound
	str 	r1, [r0, #PWM_RNG2]
	lsr 	r1, r1, #3
	str 	r1, [r0, #PWM_DAT2]
notSound:	
	ldreq	r0, =PWM_BASE
	ldreq	r1, =PWM_CLR
	streq	r1, [r0]
	ldr	r2, [sp], #4		@ pop r2
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

checkSound:
	str	r14, [sp, #-4]!		@ push r14
	str	r4, [sp, #-4]!		@ push r4
	str	r3, [sp, #-4]!		@ push r3
	str	r2, [sp, #-4]!		@ push r2
	mov	r1, #0
	ldr	r1, [r9, r6, lsl #2]
	ldrb	r3, [r10, r6]
	mul	r3, r7, r3
	sub	r3, r3, r7, lsr #3	@ 音と音の間の間隔を引き算
	add	r5, r5, r3
	
	ldr	r2, [sp], #4		@ pop r2
	ldr	r3, [sp], #4		@ pop r3
	ldr	r4, [sp], #4		@ pop r4
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
