	@ 音ゲーを実行するサブルーチン (ver.前前前世)
	
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
	
	@ TEMPOは楽譜の左上にあるテンポに変更すること
	@ MIN_LENは、楽譜内で最短の音の長さに合わせて設定すること
	@	四分音符: 1, 八分音符: 2, 十六分音符: 4, 三十六分音符: 8
	.equ	TEMPO,		190
	.equ	MIN_LEN,	2
	.equ	TIMER_HZ,	1000*1000*60 / TEMPO / MIN_LEN
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,	267
	.equ	NOTES_COUNT, 	32		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ / 2	@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	100		@ これは仮の数！　書き換え必須
	
	.section .text
	@ このラベルの名前は [music_曲名] で統一
	.global music
music:	
	str	r14, [sp, #-4]!		@ push r14
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
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
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
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ kankan
	.byte 6, 2, 3, 1, 6, 1, 1, 2, 1, 1	@ 16-18
	.byte 4, 8, 2, 2			@ 19-20
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 21
	.byte 1, 1, 1, 1, 1, 2, 5, 4, 7, 1	@ 22-24
	.byte 3, 1, 4, 3, 1, 2, 1, 1		@ 25-26
	.byte 4, 8, 2, 2			@ 27-28
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 29
	.byte 2, 1, 1, 2, 1, 5, 8, 2, 2		@ 30-32
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 33
	.byte 2, 1, 1, 2, 1, 3, 6, 8		@ 34-36
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 37
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 38 101
	.byte 6, 1, 5, 4			@ 39-40
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 41
	.byte 1, 1, 1, 1, 1, 1, 1, 1		@ 42
	.byte 6, 1, 5, 2, 1, 1			@ 43-44
	.byte 2, 1, 2, 1, 4, 2, 2, 1, 1		@ 45-46
	.byte 2, 1, 2, 1, 2, 4, 3, 1		@ 47-48
	.byte 2, 1, 2, 1, 4, 2, 2, 2		@ 49-50
	.byte 7, 1, 7, 1, 7, 1, 4, 1, 1, 1, 1	@ 51-54
	.byte 2, 2, 2, 1, 1, 1, 2, 2, 1, 1, 1	@ 55-56
	.byte 1, 2, 1, 1, 1, 1			@ 57(
	.byte 3, 1, 1, 1, 1, 1, 2		@ (57-59)
	.byte 1, 1, 1, 1, 1, 1, 2		@ )59-60)
	.byte 1, 1, 1, 1, 1, 2			@ )60
	.byte 2, 1, 2, 2, 5, 1, 1, 1, 1		@ 61-62 209
	.byte 2, 2, 2, 1, 2, 2, 2, 1, 1, 1	@ 63-64
	.byte 2, 1, 2, 2, 3, 1, 2, 1, 1, 2	@ 65-67)
	.byte 1, 1, 1, 1, 1, 1, 2		@ )67-68)
	.byte 1, 1, 1, 1, 1, 1, 2, 1, 4, 4	@ )68-70)
	.byte 1, 1, 2, 1, 2, 1, 1, 1, 2, 1	@ )70-71(
	.byte 2, 1, 1, 1, 1, 1, 1, 2, 1, 6, 8	@ (71-74 267
	.byte 0

	@ sound_buffer
	@ 音程を示すバッファ
	@ http://pianobooks.jp/score.php?id=86 より
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
	@ 音程に違和感があれば別サイトで音程を照合して書き換えよろしく
sound_buffer:	@ 5: ド 7: ミ
	.word F5S,   0, F5S,   0, F5S,   0, F5S,   0	@ kankan
	.word   0, F3					@ 6 やっ
	.word  B3, C4S,  B3				@ 7 とめを
	.word   0,  F3,  E4, D4S, C4S			@ 18 さました
	.word  B3,   0					@ 19 かい
	.word  B3, C4S					@ 20 それ
	.word D4S, C4S, D4S,  E4, D4S,  B3,  B3, C4S	@ 21 なのになぜめもあ
	.word D4S, C4S, D4S,  E4, D4S, C4S,  B3		@ 22 わせやしないんだい?
	.word   0					@ 23 -
	.word   0, F4S					@ 24 「お
	.word  B4, F4S, F4S				@ 25 そいよ」と
	.word   0, F4S,  E5, D5S, C5S			@ 26 おこるき
	.word  B4,   0					@ 27 み
	.word  B4, C5S					@ 28 これ
	.word D5S, C5S, D5S,  E5, D5S, C5S,  B4, C5S	@ 29 でもやれるだけと
	.word D5S, D5S,  E5, D5S, C5S,  B4		@ 30 ばしてきたんだよ
	.word   0					@ 31 -
	.word  B4, C5S					@ 32 ここ
	.word D5S, C5S, D5S, C5S, D5S, C5S,  B4, C5S	@ 33 ろがからだをおい
	.word D5S, D5S,  E5, D5S, C5S,  B4		@ 34 こしてきたんだよ
	.word   0					@ 35 -
	.word   0					@ 36
	.word  B4, C5S, D5S,  B4, C5S, D5S,  B4, C5S	@ 37 きみのかみやひと
	.word D5S,  B4, C5S, D5S,  B4, C5S, D5S, D5S	@ 38 みだけでむねがい
	.word F5S, C5S, C5S				@ 39 たいよ
	.word   0					@ 40 -
	.word  B4, C5S, D5S,  B4, C5S, D5S,  B4, C5S	@ 41 おなじときをすい
	.word D5S,  B4, C5S, D5S,  B4, C5S, D5S,  B4	@ 42 こんではなしたく
	.word F5S, C5S, C5S				@ 43 ないよ
	.word   0, A4S, G4S				@ 44 - はる
	.word A4S, G4S, A4S, G4S,  B4			@ 45 かむかーしか
	.word G4S, G4S,   0, F4S			@ 46 ーーらし
	.word C5S, C5S, C5S, D5S,  E5			@ 47 るそのーこえ
	.word D5S,   0, G4S				@ 48 に　う
	.word A4S, G4S, A4S, G4S, A4S			@ 49 まれてーはじ
	.word G4S, F4S,   0				@ 50 ーめて
	.word D5S, C5S					@ 51 なーに
	.word C5S,  B4					@ 52 をーい
	.word  B4, C5S					@ 53 えーば
	.word C5S,   0,  B4,  B4,  B4			@ 54 いい？　きみの
	.word F5S, F5S, F5S, D5S, C5S			@ 55 ぜんぜんぜんぜんせいか
	.word C5S, C5S,  B4,  B4,  B4,  B4		@ 56 らぼくはーきみを
	.word F5S, F5S, F5S, F5S, D5S, D5S, C5S		@ 57 さがしはじめたよ
	.word   0,  B4,  B4, C5S, D5S, C5S		@ 58 ー　そのぶきっ
	.word  B4,  B4,  B4,  B4, C5S, D5S, C5S		@ 59 ーちょなわらいかた
	.word  B4,  B4, G4S,  B4, G4S,  B4		@ 60 ーをめがけてやっ
	.word F5S, D5S, F5S, D5S, C5S			@ 61 てきたんーだよ
	.word   0,  B4,  B4,  B4			@ 62 ー　きみが
	.word F5S, F5S, F5S, D5S, C5S			@ 63 ぜんぜんぜんぶなく
	.word C5S,  B4,  B4,  B4,  B4			@ 64 ーなってーチリヂ
	.word F5S, F5S, F5S, D5S, C5S			@ 65 リになっーたって
	.word   0,  B4, C5S, D5S, C5S			@ 66 ー　もうーまよわ
	.word  B4,  B4,  B4,  B4, C5S, D5S, C5S		@ 67 ーないまたいちか
	.word  B4,  B4, G4S,  B4, C5S, D5S, C5S		@ 68 ーらさがしはじめ
	.word  B4,  B4,   0				@ 69 ーるさ
	.word  B4, G4S,  B4, D5S, C5S			@ 70 むしろゼロ
	.word  B4,  B4, G4S,  B4, D5S, C5S		@ 71 ーからまたうちゅう
	.word  B4,  B4, G4S,  B4, C5S, D5S, C5S		@ 72 ーをはじめてみよ
	.word  B4,  B4					@ 73 ーうか
	.word   0					@ 74
	.word   0

	@ 音ゲーの譜面を格納するバッファ
	@ ここからの読み出しは、soundLen_buffer での 1 の長さ分単位で行われる
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 8, 0
	.byte 1, 0, 0, 2, 4, 0, 0, 0
	.byte 0, 0, 0, 8, 1, 0, 2, 4
