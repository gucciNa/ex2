	@ 音ゲーを実行するサブルーチン (ver.ウミユリ海底譚)
	
	@ 定義部分は曲を変えるとき変更すること
	@ NOTES_SPEED は適当に割る数をいじってあげて調整
	@ TIMER_HZ と NOTES_COUNT は必ず変更

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
	.include "umiyuri.h"
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,	284
	.equ	NOTES_COUNT, 	552		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ*2/5	@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	170		@ これは仮の数！　書き換え必須
	
	.section .text
	@ このラベルの名前は [music_曲名] で統一
	.global music_umiyuri
music_umiyuri:	
	@ タイマーの初期化等, レジスタの初期化を行う
	ldr	r0, =TIMER_BASE
	ldr	r8, [r0, #CLO]		@ r8 に現在時刻読み出し
	ldr	r1, =TIMER_HZ		@ 曲中最初のワンテンポ分
	add	r9, r8, r1
	mov	r5, r9			@ 曲初めはワンテンポ先
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
	@ このバッファに入っている個数は, 必ず4の倍数個にすること
soundLen_buffer:
	.byte 2, 2, 2, 2, 2, 2, 2, 2              	@ kankan
	.byte 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1  	@ 2
	.byte 2, 1, 1, 1, 1, 1, 1, 2, 2, 4
	.byte 2, 2, 2, 1, 1, 1, 1, 2, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 1, 1              	@ 5, 9
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 2           	@ 10
	.byte 2, 2, 2, 2, 4, 2, 1, 1
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 1, 1
	.byte 2, 2, 2, 1, 1, 4, 2, 2              	@ 13
	.byte 2, 4, 2, 2, 2, 2, 2                 	@ 14
	.byte 4, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 2
	.byte 2, 2, 2, 2, 2, 2, 2, 2              	@ 18
	.byte 2, 2, 2, 2, 2, 2, 2, 2
	.byte 4, 2, 2, 4, 2, 2
	.byte 2, 2, 4, 4, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 2                 	@ 22
	.byte 2, 2, 2, 2, 4, 1, 1, 1, 1
	.byte 4, 2, 2, 2, 2, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 2
	.byte 2, 2, 2, 2, 4, 2, 2                 	@ 26
	.byte 2, 2, 2, 2, 4, 1, 1, 1, 1
	.byte 4, 2, 2, 2, 2, 2, 2                 	@ 28
	.byte 4, 2, 2, 2, 2, 2, 2
	.byte 4, 2, 2, 4, 2, 2
	.byte 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1  	@ 31
	.byte 2, 1, 1, 1, 1, 1, 1, 2, 2, 4
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 1, 1
	.byte 2, 2, 2, 2, 4, 2, 1, 1              	@ 34
	.byte 2, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4
	.byte 2, 2, 2, 1, 1, 2, 2, 2, 2           	@ 37
	.byte 2, 2, 2, 2, 4, 10                    	@ 38
	@ sound_buffer
	@ 音程を示すバッファ
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
sound_buffer:	
	.word  F5S,   0, F5S,   0, F5S,   0, F5S,   0                 	@ kankan
	.word  B4F,  F4,  F4,  C5, B4F, B4F,  D5,  F5, F5,  G5, D5, C5	@ 2
	.word  B4F,  D5,  D5,  C5, B4F, B4F,  C5,  D5, F5,  D5        	@ 3	
	.word  B4F,  F4,  C5, B4F, B4F,  D5,  D5,  F5, D5,  C5        	@ 4
	.word  B4F,  D5,  C5,  D5, B4F,   0,  D5,  F5                 	@ 5, 9
	.word   G5,  G5,  G5,  F5,  D5,  C5,  D5, B4F, D5             	@ 10
	.word   C5,  D5,  C5,  F5,  D5,  D5,  C5, B4F                 	@ 11
	.word   G5,  G5,  G5,  F5,  D5,  C5,  A5, B5F, D5,  C5        	@ 12
	.word   G4,  C5,  F5,  D5,  C5, B4F,  G4,  F4                 	@ 13
	.word    0,  D5,  D5,  C5, B4F,  A4,  C5                       	@ 14
	.word  B4F,   0,  F4,  F4, E4F,  D4,  D4                      	@ 15
	.word    0,  D5,  D5,  D5,  C5, B4F,  A4,  F4                 	@ 16
	.word   F4,  D5,  C5, B4F,  D5,  C5, B4F                      	@ 17
	.word    0,  F4,  D5,  F5,   0,  D5,  A4, B4F                 	@ 18
	.word    0,  F4,  D5,  F5,   0,  D5,  A4,  C5                 	@ 19
	.word  B4F,   0,  F4, B4F,   0, B4F                           	@ 20
	.word   C5, B4F, E5F,  D5,  A4,  A4                           	@ 21
	.word  B4F, B4F, B4F,  F4,  C5, B4F, B4F                      	@ 22
	.word   C5, B4F, B4F, E5F,  D5,  D5,  C5, B4F, A4             	@ 23
	.word  B4F, B4F,  D5,  F5, B4F, B4F, B4F                      	@ 24
	.word   C5,  D5,  C5, B4F, B4F, B4F,  A4                      	@ 25
	.word  B4F, B4F, B4F,  F4,  C5, B4F, B4F                      	@ 26
	.word   C5, B4F, B4F, E5F,  D5,  D5,  C5, B4F, A4              	@ 27
	.word  B4F, B4F,  D5, E5F,  D5,  C5, B4F                      	@ 28
	.word   C5,   0,  F4,  F4,  F4,  D5,  C5                      	@ 29
	.word   C5, B4F,  A4,  A4,  D5, B4F                           	@ 30
	.word  B4F,  F4,  F4,  C5, B4F, B4F,  D5,  F5, F5,  G5, D5, C5	@ 31
	.word  B4F,  D5,  D5,  C5, B4F, B4F,  C5,  D5, F5,  D5        	@ 32
	.word  B4F,  F4,  C5, B4F,  C5,  D5,  F5,  D5, C5, B4F        	@ 33
	.word  B4F,  D5,  C5,  D5, B4F,   0,  G4,  A4                 	@ 34
	.word  B4F,  F4,  F4,  C5, B4F,  C5,  D5,  F5, F5,  G5, D5, C5	@ 35
	.word  B4F, B4F,  D5,  D5,  C5, B4F, B4F,  C5, D5,  F5, D5    	@ 36
	.word  B4F,  F4,  C5, B4F, B4F,  D5,  F5,  D5, C5             	@ 37
	.word  B4F,  D5,  C5,  D5, B4F,   0                           	@ 38

	@ 音ゲーの譜面を格納するバッファ
	@ ここからの読み出しは、soundLen_buffer での 1 の長さ分単位で行われる
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@2
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@3
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@4
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@5ぼくはぼくは
	.byte 2, 0, 0, 0            	@ぼくは
	.byte	1, 0, 0, 0             	@9
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@10
	.byte 2, 0, 0, 0, 1, 0, 0, 0	@
	.byte 4, 0, 0, 0, 1, 0, 0, 0	@11
	.byte 2, 0, 0, 0, 8, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@12
	.byte 2, 0, 0, 0, 1, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@13			/30
	.byte 0, 0, 0, 0, 3, 0, 0, 0	@いま
	.byte 0, 0, 8, 0, 4, 0, 1, 0	@はいに
	.byte 2, 0, 8, 0, 4, 0, 1, 0	@まみれて
	.byte 2, 0, 0, 0, 0, 0, 4, 0	@くう
	.byte 8, 0, 4, 0, 8, 0, 4, 0	@みのそこ
	.byte 0, 0, 1, 0, 4, 0, 8, 0	@いきを
	.byte 2, 0, 1, 0, 4, 0, 8, 0	@のみほす
	.byte 2, 0, 1, 0, 4, 0, 8, 0	@ゆめをみ
	.byte 2, 0, 0, 0, 5, 0, 0, 0	@た ただ
	.byte 0, 0, 1, 0, 2, 0, 8, 0	@ゆらぎ
	.byte 0, 0, 1, 0, 4, 0, 8, 0	@のなか
	.byte 0, 0, 2, 0, 1, 0, 4, 0	@そらを
	.byte 0, 0, 2, 0, 8, 0, 4, 0	@ながめ					/39+2
	.byte 1, 0, 0, 0, 0, 0, 8, 0	@る　ぼ
	.byte 2, 0, 0, 0, 0, 0, 1, 0	@く　の
	.byte 4, 0, 8, 0, 2, 0, 0, 0	@てをさえ
	.byte 4, 0, 0, 0, 1, 0, 2, 0	@ぎったゆ
	.byte 1, 0, 2, 0, 1, 0, 2, 0	@めのあと
	.byte 1, 0, 0, 0, 4, 0, 8, 0	@がきみ
	.byte 4, 0, 8, 0, 4, 0, 8, 0	@のおえつ
	.byte 4, 0, 0, 0, 0, 0, 0, 0	@がはきだせ
	.byte 0, 0, 0, 0, 8, 0, 2, 0	@ないうた
	.byte 1, 0, 4, 0, 8, 0, 2, 0	@かたのに
	.byte 1, 0, 4, 0, 8, 0, 2, 0	@わのすみ
	.byte 1, 0, 0, 0, 4, 0, 1, 0	@をひか
	.byte 4, 0, 1, 0, 4, 0, 1, 0	@りのおよ
	.byte 4, 0, 0, 0, 2, 0, 8, 0	@ぐそら
	.byte 2, 0, 8, 0, 2, 0, 8, 0	@にさざめ
	.byte 2, 0, 0, 0, 0, 0, 0, 0	@くもじのお				/47
	.byte 0, 0, 0, 0, 4, 0, 1, 0	@くなみ
	.byte 2, 0, 8, 0, 4, 0, 1, 0	@のはざま
	.byte 2, 0, 0, 0, 0, 0, 8, 0	@で　き
	.byte 2, 0, 1, 0, 4, 0, 8, 0	@みがてを
	.byte 2, 0, 0, 0, 4, 0, 8, 0	@ふっただ
	.byte 2, 0, 0, 0, 0, 0, 0, 0	@けなんて
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@31
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@32
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@33
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@34
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@35
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 12, 0, 0, 0, 3, 0, 0, 0	@36
	.byte 4, 0, 0, 0, 8, 0, 0, 0	@
	.byte 3, 0, 0, 0, 12, 0, 0, 0	@37
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 4, 0, 0, 0, 1, 0, 0, 0	@38
	.byte 10, 0, 0, 0, 0, 0, 0, 0	@								/47+5
	.byte	0, 0, 0, 0, 0, 0, 0, 0



