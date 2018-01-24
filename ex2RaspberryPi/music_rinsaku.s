	@ 音ゲーを実行するサブルーチン (ver.凛と咲く花の如く)
	
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
	.include "rinsaku.h"
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,   65
	.equ	NOTES_COUNT, 	188		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ / 2	@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	43		@ これは仮の数！　書き換え必須
	
	.section .text
	@ このラベルの名前は [music_曲名] で統一
	.global music_rinsaku
music_rinsaku:	
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
	.byte 2, 2, 2, 2, 2, 2, 2, 2		@ kankan
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
	@ 音程を示すバッファ
	@ http://guitarlist.net/bandscore/beniirolitmus/rintoshite/rintoshite2.php
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
sound_buffer:	
	.word F5S,   0, F5S,   0, F5S,   0, F5S,   0	@ kankan
	.word   0, C4S,  E4, F4S, F4S,  A4, C5S,  B4, C5S @ さいてさいてつき
	.word  B4, C5S,  B4,  A4, F4S,   0,  E4, C4S	@ におねがい おだ
	.word  B3,  B3, C4S,  E4, F4S,  E4, C4S,  E4	@ やかなかげにう
	.word F4S,  F4, F4S, G4S,   0, C4S,  E4		@ すげしょう しら
	.word F4S, F4S,  A4, C5S,  B4, C5S		@ ず しらず えい
	.word  B4, C5S,  E5, F5S, C5S,  B4,  A4		@ やとなげたつぼ
	.word F4S, F4S, G4S,  E4, C4S,  E4		@ みはゆくえし
	.word F4S, F4S, C4S,  E4, F4S,   0		@ れずーのまま
	
	@ 音ゲーの譜面を格納するバッファ
	@ ここからの読み出しは、soundLen_buffer での 1 の長さ分単位で行われる
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0

	.byte	0, 0, 0, 0
	.byte 1, 0, 0, 0, 4, 0, 0, 0	@
	.byte 8, 0, 0, 0, 1, 0, 4, 0	@
	.byte 8, 0, 0, 0, 1, 0, 2, 0	@

	.byte 8, 0, 4, 0, 1, 0, 2, 0	@
	.byte 8, 0, 0, 0, 4, 0, 0, 0	@

	.byte 1, 0, 0, 0, 4, 0, 0, 0	@42
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 8, 0, 0, 0, 2, 0, 1, 0	@43
	.byte 4, 0, 0, 0, 2, 0, 0, 0	@
	.byte 8, 0, 0, 0, 4, 0, 0, 0	@44
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 8, 0, 0, 0, 4, 0, 0, 0	@45
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 8, 0, 0, 0, 4, 0, 0, 0	@46
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@

	.byte 8, 0, 0, 0, 4, 0, 0, 0	@47
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@
	.byte 8, 0, 0, 0, 0, 0, 0, 0	@
	.byte 0, 0, 0, 0, 1, 0, 2, 0	@
	.byte 4, 0, 0, 0, 0, 0, 0, 0	@
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@

