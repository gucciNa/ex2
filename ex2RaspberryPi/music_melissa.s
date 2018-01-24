	@ 音ゲーを実行するサブルーチン (ver.メリッサ)
	
	@ 定義部分は曲を変えるとき変更すること
	@ NOTES_SPEED は適当に割る数をいじってあげて調整
	@ TIMER_HZ と NOTES_SPEED は必ず変更

	@ r3: 音ゲースコア
	@ r4: on/off切り替え (1:on, 0:off)
	@   →　毎音、ほんの少し間隔を作るため
	@ r5: 曲用タイマー
	@ r6: 曲の進行
	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9: 音ゲー譜面用タイマー
	@ r10: 音ゲー画面表示更新(渦巻き)用タイマー
	@ r11: 音ゲースイッチ入力状態管理用
	@ r12: 音ゲー譜面の進行
	
	.include "common.h"
	.include "melissa.h"
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH, 264
	.equ	NOTES_COUNT, 	32		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ / 2	@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	100		@ これは仮の数！　書き換え必須
	
	.section .text
	.global music_melissa
music_melissa:
	@ タイマーの初期化等, レジスタの初期化を行う
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]
	ldr	r1, =TIMER_HZ
	add	r9, r8, r1
	mov	r5, r9
	ldr	r1, =NOTES_SPEED
	add	r10, r8, r1
	@ r9: 譜面表示は目的とするタイミングの8つ手前から光らせ始める
	mov	r4, #8			@ 上の理由から 8
	mul	r1, r4, r1
	sub	r9, r1
	ldr	r1, =(TIMER_HZ / 100)
	add	r8, r8, r1		@ ディスプレイ表示用
	mov	r7, #0			@ 最初は1行目
	mov	r12, #0			@ 譜面,曲の進行は初期値0
	mov	r6, #0
	mov	r3, #0			@ スコアの初期化
	mov	r4, #0			@ ON/OFF 用初期化
	mov	r11, #0			@ スイッチ管理用レジスタの初期化	
timer:	@ r7: 何行目を表示すべきかを示すレジスタ
	@ r8: 8*8ドットマトリクスLEDの１行を表示するタスク用タイマー
	@ r9 : ストップウォッチ用タイマー
	ldr	r0, =TIMER_BASE
	ldr	r1, [r0, #CLO]
	cmp	r5, r1
	blmi	jumpSoundMusic
	cmp	r9, r1
	blmi	readNotes	@ 定期的にノーツの追加読み込み
	cmp	r10, r1
	blmi	jumpRenewNotes
	cmp	r8, r1
	blmi	jumpDisplay
	ldr	r1, =SOUND_LENGTH
	cmp	r6, r1
	beq	jumpToResult
	b	timer
jumpToResult:
	mov	r1, #100
	mul	r3, r1, r3
	mov	r1, #NOTES_SUM
	udiv	r3, r3, r1		@ ％でスコア表示
	bl	result
	b	_start
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
		
readNotes:	@ ノーツの追加を読み込むサブルーチン
	str	r14, [sp, #-4]!		@ push r14
	str	r11, [sp, #-4]!		@ push r11
	str	r1, [sp, #-4]!		@ push r1
	ldr	r11, =notes_buffer
	bl	makeNotes
	add	r12, r12, #1
	cmp	r12, #NOTES_COUNT
	moveq	r12, #0
	ldr	r1, =TIMER_HZ
	add	r9, r9, r1
	ldr	r1, [sp], #4		@ pop r1
	ldr	r11, [sp], #4		@ pop r11
	ldr	r14, [sp], #4		@ pop r14
	bx	r14

jumpRenewNotes:
	str	r14, [sp, #-4]!		@ push r14
	str	r1, [sp, #-4]!		@ push r1
	ldr	r1, =frame_buffer
	bl	renewNotes
	ldr	r1, =NOTES_SPEED
	add	r10, r10, r1
	ldr	r1, [sp], #4		@ pop r1
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
	@ メリッサ
	@http://guitarlist.net/bandscore/pornograffitti/melissa/melissa2.php
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
	.byte 8, 8			@ p6-p7 SL:  74
	.byte 2, 1, 1, 1, 1, 1, 1	@ p7	SL:  81
	.byte 1, 1, 1, 1, 1, 2, 1	@ p8	SL:  88
	.byte 4, 1, 1, 1, 3, 1		@ p8	SL:  94
	.byte 2, 1, 2, 5, 1, 2, 2	@ p8	SL: 101
	.byte 2, 1, 2, 1, 5, 1, 2	@ p8	SL: 108
	.byte 4, 4, 2, 1, 2, 1, 1, 1	@ p9	SL: 116
	.byte 1, 1, 1, 1, 1, 2, 1	@ p9	SL: 123
	.byte 4, 1, 1, 1, 3		@ p9	SL: 128 
	.byte 1, 2, 1, 2, 5, 1, 2	@ p9	SL: 135
	.byte 2, 2, 1, 3, 5, 1, 2	@ p10	SL: 142
	.byte 2, 2, 4, 6, 1, 1		@ p10	SL: 148
	.byte 2, 1, 2, 2, 7, 2		@ p10	SL: 154
	.byte 2, 1, 2, 2, 7, 2		@ p11	SL: 160
	.byte 2, 2, 3, 1, 6, 2		@ p11	SL: 166
	.byte 2, 2, 6, 1, 1		@ p11	SL: 171
	.byte 2, 1, 2, 3, 4, 4, 4, 4	@ p12	SL: 179
	.byte 1, 1, 1, 1, 1, 1, 1, 1	@ p12	SL: 187
	.byte 1, 1, 1, 1, 2, 1, 1	@ p12	SL: 194
	.byte 1, 1, 1, 1, 2, 2		@ p13	SL: 200
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p13	SL: 208
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ 13-14 SL: 216
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p14	SL: 224
	.byte 4, 3, 7, 2		@ 14-15	SL: 228
	.byte 2, 1, 1, 1, 1, 1, 7, 2	@ p15	SL: 236
	.byte 2, 1, 1, 1, 1, 1, 3	@ 15-16 SL: 243
	.byte 2, 2, 2, 4, 4, 8, 4, 2, 2 @ p16	SL: 252
	.byte 1, 1, 1, 1, 1, 1, 1, 1	@ p17	SL: 260
	.byte 1, 1, 1, 1, 1, 2, 9, 1, 1	@ p17	SL: 267 (-5) 264
	
	@ sound_buffer
	@ 音程を示すバッファ
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
	.word   0,   0						@ p6-p7 
	.word  C5,  C5,  C5,   0,  C5,  C5,  C5			@ p7	
	.word  B4,  B4,  B4,  B4,  B4,  C5,  A4			@ p8	
	.word   0,   0,  A4,  C5,  D5,   0			@ p8	
	.word  D5,  C5,  B4,  C5,  D5,  C5,  B4			@ p8	
	.word   0,  B4,  C5,  C5,  D5,  C5,  B4			@ p8	
	.word  C5,   0,  C5,  C5,  C5,  C5,  C5, C5		@ p9	
	.word  B4,  B4,  B4,  B4,  B4,  C5,  A4			@ p9	
	.word   0,   0,  A4,  C5,  D5				@ p9	
	.word   0,  D5,  C5,  B4,  C5,  D5,  C5			@ p9	
	.word  B4,   0,  B4,  C5,  D5,  E5,  D5			@ p10	
	.word  C5,   0, D5S,  E5,   0,  E5			@ p10	
	.word  E5, D5S,  C5,  E5, D5S,   0			@ p10	
	.word D5S,  C5,  B4, D5S,  C5,  B4			@ p11	
	.word A4S, A4S, D5S,  B4,  C5,   0			@ p11	
	.word  C5,  D5, D5S,   0,  D5				@ p11	
	.word D5S,  D5,  C5, D5S,  D5,  C5, A4S,  D5		@ p12	
	.word   0,  C5,  C5, A4S,  C5,  C5,  C5, A4S		@ p12	
	.word   0,  C5,  C5, A4S,  C5,  C5,  C5			@ p12	
	.word   0,  C5,  C5, A4S,  D5,  D5			@ p13	
	.word  E5,  E5,  A5,   0,  E5,   0,  F5,  0		@ p13	
	.word  D5,  D5,  G5,   0,  D5,   0,  E5,  0		@ 13-14 
	.word  C5,  C5,  F5,   0,  C5,   0,  D5, C5		@ p14	
	.word  B4,  E5,  C5,   0				@ 14-15	
	.word  E5,  E5,  A5,   0,  E5,   0,  F5,  0		@ p15	
	.word  D5,  D5,  G5,   0,  D5,   0,  F5			@ 15-16 
	.word  E5,  D5,  E5,  C5,  E5,  A4,   0,  A4,  B4	@ p16	
	.word   0,  C5,  C5,  C5,  C5,  C5,  C5,  C5		@ p17	
	.word  D5,  D5,  D5,  D5,  G5,  G5,  A5,   0,   0	@ p17	

	@ 音ゲーの譜面を格納するバッファ
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  4 きみのってっで
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  5
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  6 きりさっいって
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  7
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  8 とおいっひっのー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@  9 ーき
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 10 おーくーを
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 11 ー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 12 かなしっみっのー	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 13 ー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 14 いきのっねっをー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 15 ーとめて
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 16 くーれー	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 17 よーー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 18 　　　　　さあ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 19 あいにこがれた
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 20 むねをつらぬけ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 21 ーーーーーーー　
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 22
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 30 あすがっくるは
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 31 ずのそらをみて
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 32 　　　　まよう
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 33 ー　　　ばかり
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 34 のーここ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 35 ろ　もてあ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 36 まーしてい
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 37 る
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 38 かたわらのと
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 39 りがはばたいた	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 40 　　　　どこか
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 41 ー　ひかり
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 42 をーー　みつ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 43 け　られ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 44 たーー　のか
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 45 な　なーー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 46 あーーー　お
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 47 まえのせに	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 48 ーーーー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 49 おれものせー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 50 ーーて
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 51 くれない	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 52 かーー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 53 そーしー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 54 てーー　い
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 55 ちばんた
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 56 かいーとー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 57 こーでー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 58 おきざりにして
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 59 やさしさから	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 60 とおざけて
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 61 きみのってっで
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 62 ーー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 63 きりさっいてー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 64 ーー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 65 とおいっひっの
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 66 ーーーき
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 67 おーくーをー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 68 ーー
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 69 かなしっみっの
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 70 ーーー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 71 いきのっねっを	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 72 ーとめて
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 73 くーれー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 74 よーーーー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 75      　　さあ
	
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 76 あいにこがれた
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 77 むねをつらぬけ
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@ 78 ーーーーーー













