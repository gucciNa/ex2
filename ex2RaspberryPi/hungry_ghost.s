	@ 反射ゲームを実行するサブルーチン
	
	@ 定義部分は曲を変えるとき変更すること
	@ TIMER_HZは必ず変更
	@ r2: 差分切り替え用
	@ r3: 状態を表す
	@     1:通常 2:喜び 3:食べ物 4:食べられないもの 5:ゲームオーバー
	@ r4: on/off切り替え (1:on, 0:off)
	@   →　毎音、ほんの少し間隔を作るため
	@ r5: 曲用タイマー
	@ r6: 曲の進行
	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9: キャラ表示進行
	@ r10: 差分タイマー
	@ r11: オブジェクトを出現させた回数
	@ r12: ボタンタイマー

	.include "common.h"	
	@ TEMPOは楽譜の左上にあるテンポに変更すること
	@ MIN_LENは、楽譜内で最短の音の長さに合わせて設定すること
	@	四分音符: 1, 八分音符: 2, 十六分音符: 4, 三十二分音符: 8
	.equ	TEMPO,		190
	.equ	MIN_LEN,	4
	.equ	TIMER_HZ,	1000*1000*60 / TEMPO / MIN_LEN
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,	96

	.equ	OBJECT_LENGTH,	24	
	
	.section .text
	.global hungry_ghost
hungry_ghost:		
	@ タイマーの初期化等, レジスタの初期化を行う
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]		@ r8 に現在時刻読み出し
	ldr	r1, =TIMER_HZ		@ 曲中最初のワンテンポ分
	add	r5, r8, r1
	ldr	r1, =(MINUTE_HZ * 5)	@ キャラの差分の動き
	add	r10, r8, r1
	ldr	r1, =(MINUTE_HZ / 1000)
	add	r12, r8, r1		@ ボタン判定
	ldr	r1, =(MINUTE_HZ / 100)
	add	r8, r8, r1		@ ディスプレイ表示用
	mov	r7, #0			@ 最初は1行目
	mov	r11, #0			@ オブジェクトを出現させた回数
	mov	r9, #0			@ キャラの表示進行
	mov	r6, #0			@ 曲の進行の初期化
	mov	r3, #1			@ キャラ状態の初期化
	mov	r4, #0			@ ON/OFF 用初期化
	mov	r2, #0			@ 差分切り替え初期化
	mov	r11, #0			@ スイッチ管理用レジスタの初期化
	ldreq	r0, =alive_time		@ alive_timeの初期化
	moveq	r1, #500
	streq	r1, [r0]
timer:	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9 : ストップウォッチ用タイマー
	ldr	r0, =TIMER_BASE
	ldr	r1, [r0, #CLO]
	cmp	r3, #5
	bne	renewSomething
	mov	r6, #SOUND_LENGTH
	bl	notSound
	mov	r12, #0
	bl	checkButton
	cmp	r0, #1
	beq	hungry_ghost
	cmp	r0, #2
	beq	_start
	b	displayAct	@ GameOver時、音と画面更新を行わない
renewSomething:	
	cmp	r5, r1
	blmi	jumpSoundMusic
	cmp	r10, r1
	blmi	changeChar
	cmp	r12, r1
	blmi	buttonAct
displayAct:	
	cmp	r8, r1
	blmi	jumpDisplay
	blmi	live
	ldr	r1, =SOUND_LENGTH
	cmp	r6, r1
	moveq	r6, #0
	
	b	timer
	
loop:	b       loop
	
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

changeChar:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	cmp	r9, #12
	moveq	r9, #6			@ 進行の初期化
	rsb	r2, r2, #8
	cmp	r9, #5
	bleq	appearObj
	cmp	r9, #11
	bleq	appearObj
next:	
	add	r9, r9, #1
	ldr	r1, =(MINUTE_HZ * 5)
	add	r10, r10, r1
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

appearObj:
	str	r14, [sp, #-4]!		@ push r14
	str	r4, [sp, #-4]!		@ push r4
	str	r12, [sp, #-4]!		@ push r12
	cmp	r11, #OBJECT_LENGTH
	moveq	r11, #0
	ldr	r0, =obj_buffer
	ldrb	r12, [r0, r11]
	and	r4, r12, #1		@ 食べものかそうでないか
	cmp	r4, #1
	moveq	r3, #4
	movne	r3, #3
	lsr	r4, r12, #1		@ オブジェクトのパターン
	and	r4, r4, #1
	cmp	r4, #1
	moveq	r2, #8
	movne	r2, #0
	add	r11, r11, #1
	ldr	r12, [sp], #4		@ pop r12
	ldr	r4, [sp], #4		@ pop r4
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

jumpDisplay:	
	str	r14, [sp, #-4]!		@ push r14
	cmp	r3, #1
	ldreq	r0, =frame_buffer
	addeq	r0, r0, r2
	cmp	r3, #2
	ldreq	r0, =hurt_buffer
	addeq	r0, r0, r2
	cmp	r3, #3
	ldreq	r0, =food_buffer
	addeq	r0, r0, r2
	cmp	r3, #4
	ldreq	r0, =noFood_buffer
	addeq	r0, r0, r2
	cmp	r3, #5
	ldreq	r0, =last_buffer
	bl	display
	add	r7, r7, #1
	cmp	r7, #8
	moveq	r7, #0
	ldr	r1, =(TIMER_HZ / 100)
	add	r8, r8, r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

live:	@ 生存判定を行う GameOverまでのカウントダウン
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	cmp	r3, #3
	ldreq	r0, =alive_time
	ldreq	r1, [r0]
	subeq	r1, r1, #1
	streq	r1, [r0]
	cmp	r3, #4
	ldreq	r0, =alive_time
	ldreq	r1, [r0]
	subeq	r1, r1, #1
	streq	r1, [r0]
	ldr  	r0, =alive_time
	ldr  	r1, [r0]
	cmp	r1, #0
	moveq	r3, #5
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
buttonAct:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	str	r2, [sp, #-4]!		@ push r2
	ldr	r0, =GPIO_BASE		@ GPIO 制御用の番地
	@ GPIO #13 (SW1) への入力を検証 (赤のボタン)
	ldr 	r2, [r0, #(GPLEV0 + SW1_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW1_PORT % 32)
	ands	r1, r2, #0x1
	blne	button1
	@ GPIO #26 (SW2) への入力を検証 (青のボタン)
	ldr 	r2, [r0, #(GPLEV0 + SW2_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW2_PORT % 32)
	ands	r1, r2, #0x1
	blne	button2
	ldr	r1, =(MINUTE_HZ / 1000)
	add	r12, r12, r1
	ldr	r2, [sp], #4		@ pop r2
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
button1:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	cmp	r3, #3
	moveq	r3, #2
	ldreq	r0, =alive_time
	ldreq	r1, [r0]
	moveq	r1, #500
	streq	r1, [r0]
	cmp	r3, #4
	moveq	r3, #5
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

button2:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	cmp	r3, #4
	moveq	r3, #2
	ldreq	r0, =alive_time
	ldreq	r1, [r0]
	moveq	r1, #500
	streq	r1, [r0]
	cmp	r3, #3
	moveq	r3, #5
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

notSound:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	ldreq	r0, =PWM_BASE
	ldreq	r1, =PWM_CLR
	streq	r1, [r0]
	ldr	r1, [sp], #4		@ pop r1
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
	
	.section .data
frame_buffer:
	@ 通常
	.byte 0x00, 0x18, 0x24, 0x56
	.byte 0x4a, 0x42, 0x84, 0x78
	@ ジャンプ
	.byte 0x1c, 0x22, 0x55, 0x4a
	.byte 0x22, 0x44, 0xb8, 0x00
hurt_buffer:	
	@ ハート通常
	.byte 0x02, 0x1b, 0x24, 0x56
	.byte 0x4a, 0x42, 0x84, 0x78
	@ ハート差分
	.byte 0x40, 0xc0, 0x1c, 0x22
	.byte 0x56, 0x4a, 0x44, 0xf8
food_buffer:	
	@ プリン(可食)
	.byte 0x00, 0x00, 0x3c, 0x7e
	.byte 0x42, 0x42, 0xc3, 0xff
	@ ドリンク(可食)
	.byte 0x02, 0x04, 0xff, 0x52
	.byte 0x7e, 0x7e, 0x7e, 0x3c
noFood_buffer:	
	@ フォーク(不食)
	.byte 0x90, 0x44, 0x22, 0x98
	.byte 0x58, 0x24, 0x02, 0x01
	@ 太陽(不食)
	.byte 0x48, 0x21, 0x1a, 0xbc
	.byte 0x3e, 0x58, 0x84, 0x12
last_buffer:	
	@ Game Over
	.byte 0x18, 0x18, 0x7e, 0x7e
	.byte 0x18, 0x18, 0x7e, 0xff

	@ soundLen_buffer
	@ 音の長さを示すバッファ
	@ このバッファに入っている個数は, 必ず4の倍数個にすること
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
	@ 音程を示すバッファ
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
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

	@ 2ビットずつセットで見ていく
	@ 1ビット目が0:food_buffer 1:noFood_buffer
	@ 2ビット目が0:1つめ 1:2つめ
obj_buffer:
	.byte 0, 2, 3, 2, 0, 2, 1, 3
	.byte 0, 1, 2, 0, 3, 0, 1, 0
	.byte 2, 3, 2, 0, 1, 3, 2, 0

alive_time:
	.word 500
	
