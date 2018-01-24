	@ 選曲画面を表示するサブルーチン

	@ 曲を書き換えるとき、
	@ .equのうちの、TEMPO, MIN_LEN, SOUND_LENGTH
	@ bufferのうちの、sound_buffer, soundLen_buffer
	@ を書き換えること
	
	@ r4: on/off切り替え (1:on, 0:off)
	@   →　毎音、ほんの少し間隔を作るため
	@ r5: 曲用タイマー
	@ r6: 曲の進行
	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9 : ストップウォッチ用タイマー
	@ r11: 曲情報 (こいつはメリッサのため r11 = 2)
	@ r12: スイッチの状態記憶

	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH, 68
	.equ	CHAR_LENGTH, 32		@ 曲名のスクロール回数

	.include "common.h"
	.include "melissa.h"
	.section .text
	.global choose_melissa
choose_melissa:
	str	r14, [sp, #-4]!		@ push r14
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]
	mov	r9, r8
	ldr	r1, =TIMER_HZ
	add	r9, r9, r1
	mov	r5, r9
	ldr	r1, =(TIMER_HZ / 100)
	add	r8, r8, r1
	mov	r10, #0				@ 表示のカウンタ
	mov	r7, #0				@ 最初は1行目
	ldr	r1, =frame_buffer
	bl	select
	mov	r6, #0
	mov	r4, #0

timer:	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9 : ストップウォッチ用タイマー
	ldr	r0, =GPIO_BASE		@ GPIO 制御用の番地
	@ GPIO #13 (SW1) への入力を検証 (緑のボタン)
	ldr 	r2, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW1_PORT % 32)
	ands	r1, r2, #0x1
	ldrne	r14, [sp], #4		@ pop r14
	bne	music_melissa
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
	@ 音の長さを示すバッファ
soundLen_buffer:
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p2	SOUND_LEN: 8
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p2	SL:  16
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p3	SL:  24
	.byte 4, 3, 7, 2		@ p3	SL:  28
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p3-p4 SL:  36
	.byte 2, 1, 1, 1, 1, 1, 3	@ p4	SL:  43
	.byte 2, 2, 2, 4, 4		@ p4	SL:  48
	.byte 8, 4, 2, 2		@ p5	SL:  52
	.byte 1, 1, 1, 1, 1, 1, 1, 1	@ p5	SL:  60
	.byte 1, 1, 1, 1, 1, 2, 9	@ p6	SL:  67
	.byte 8			@ p6-p7 SL:  68

	@ sound_buffer
	@ 音程を示すバッファ
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
	@ 音程に違和感があれば別サイトで音程を照合して書き換えよろしく
sound_buffer:	
	.word  E5,  E5,  A5,   0,  E5,   0,  F5,   0		@ p2
	.word  D5,  D5,  G5,   0,  D5,   0,  E5,   0		@ p2
	.word  C5,  C5,  F5,   0,  C5,   0,  D5,  C5		@ p3
	.word  B4,  E5,  C5,   0				@ p3
	.word  E5,  E5,  A5,   0,  E5,   0,  F5,   0		@ p3-p4
	.word  D5,  D5,  G5,   0,  D5,   0,  F5			@ p4
	.word  E5,  D5,  E5,  C5,  E5				 @ p4
	.word  A4,   0,  A4,  B4				@ p5
	.word   0,  C5,  C5,  C5,  C5,  C5,  C5,  C5		@ p5
	.word  D5,  D5,  D5,  D5,  G5,  G5,  A5			@ p6
	.word   0  						@ p6-p7 
