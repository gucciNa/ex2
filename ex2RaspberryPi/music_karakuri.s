	@ 音ゲーを実行するサブルーチン (ver.からくりピエロ)
	
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
	.include "karakuri.h"
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,	253
	.equ	NOTES_COUNT, 	528		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ / 2	@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	110		@ これは仮の数！　書き換え必須
	
	.section .text
	@ このラベルの名前は [music_曲名] で統一
	.global music_karakuri
music_karakuri:	
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
	.byte 2, 2, 2, 2, 2, 2, 2, 2                   	@ kankan
	.byte 4, 4, 1, 1, 3, 2, 2                     	@ 11
	.byte 2, 1, 2, 2, 3, 2, 2, 2			
	.byte 4, 3, 1, 1, 3, 2, 2
	.byte 2, 2, 2, 2, 5, 2, 1, 1
	.byte 2, 3, 1, 1, 3, 2, 2                     	@ 15
	.byte 2, 1, 2, 2, 3, 2, 2, 2	
	.byte 4, 3, 1, 1, 3, 2, 2
	.byte 2, 1, 2, 2, 5, 4
	.byte 3, 1, 1, 2, 2, 2, 5                      	@ 19 
	.byte 3, 1, 1, 2, 2, 2, 5
	.byte 3, 1, 1, 2, 2, 2, 3, 2
	.byte 2, 1, 3, 1, 2, 1, 6 
	.byte 3, 1, 1, 2, 2, 2, 5                     	@ 23
	.byte 3, 1, 1, 2, 2, 2, 5
	.byte 3, 1, 1, 2, 2, 2, 3, 2
	.byte 2, 1, 3, 1, 5, 1, 1, 1, 1
	.byte 2, 1, 2, 1, 6, 1, 1, 1, 1               	@ 27
	.byte 2, 1, 2, 1, 6, 1, 1, 1, 1
	.byte 2, 1, 2, 2, 3, 2, 2, 2
	.byte 2, 1, 2, 2, 5, 1, 1, 1, 1
	.byte 2, 1, 2, 1, 6, 1, 1, 1, 1               	@ 31
	.byte 2, 1, 2, 1, 6, 1, 1, 1, 1
	.byte 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1
	.byte 2, 2, 1, 2, 5, 4
	.byte 4, 1, 2, 5, 1, 2, 5                     	@ 35
	.byte 1, 2, 3, 2, 1, 1, 2
	.byte 4, 1, 2, 5, 1, 2, 3
	.byte 2, 1, 2, 5, 4
	.byte 4, 1, 2, 5, 1, 2, 3                     	@ 39
	.byte 2, 1, 2, 3, 2, 2, 2
	.byte 2, 2, 1, 2, 3, 2, 2, 2
	.byte 2, 2, 1, 2, 5, 4                        	@ 42
	.byte	0, 0, 0	
	@ sound_buffer
	@ 音程を示すバッファ
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
sound_buffer:	
	.word F5S,   0, F5S,   0, F5S,   0, F5S,   0                      	@ kankan
	.word E4F, E4F, E4F,   0, B4F, A4F,  G4                           	@ 11 
	.word  F4, E4F,  F4, A4F,  G4, A4F,  G4,  F4	 
	.word E4F, E4F, E4F,   0, B4F, A4F,  G4	
	.word  F4, E4F,  F4,  G4, E4F,   0,  C4,  D4
	.word E4F, E4F, E4F,   0, B4F, A4F,  G4                           	@ 15
	.word  F4, E4F,  F4, A4F,  G4, A4F,  G4,  F4
	.word E4F, E4F, E4F,   0, B4F, A4F,  G4
	.word  F4, E4F,  F4,  G4, E4F,   0
	.word   0,  C4, E4F,  C4, E4F,  F4,  G4                            	@ 19
	.word   0,  C4, E4F,  C4, E4F, B4F,  G4
	.word   0,  C4, E4F,  C4, E4F,  F4,  G4, E4F
	.word  F4, E4F,  F4,  G4,  F4, E4F, E4F
	.word   0,  C4, E4F,  C4, E4F,  F4,  G4                           	@ 23
	.word   0,  C4, E4F,  C4, E4F, B4F,  G4
	.word   0,  C4, E4F,  C4, E4F,  F4,  G4, E4F
	.word A4F,  G4, E4F,  F4, E4F,   0,  C4, E4F, F4
	.word  G4,  F4,  F4, E4F, E4F,   0,  C4, E4F, F4                  	@ 27
	.word  G4,  F4,  F4, E4F, E4F,   0,  C4, E4F, F4
	.word  G4,  F4,  F4,  G4, A4F,  G4,  D4, E4F
	.word  F4, E4F, E4F,  D4, E4F,   0,  C4, E4F, F4
	.word  G4,  F4,  F4, E4F, E4F,   0,  C4, E4F, F4                  	@ 31
	.word  G4,  F4,  F4, B4F,  G4,   0,  C4, E4F, F4
	.word  G4,  F4,  F4,   0,  C4, E4F,  F4,  G4, F4, F4, 0, C4, E4F, F4
	.word  G4, A4F,  G4, A4F,  G4,   0
	.word  A4,  F4,  G4,  A4,  F4,  G4,  A4                           	@ 35
	.word  F4,  G4,  A4,  G4,  F4,  G4,  F4
	.word  A4,  F4,  G4,  A4,  F4,  G4,  A4
	.word  G4,  F4,  G4,  F4,   0
	.word  A4,  F4,  G4,  A4,  F4,  G4,  A4                           	@ 39
	.word  A4,  A4, B4F,  C5, B4F,  A4,  F4
	.word   0,  F4,  D5,  D5,  D5, E5F,  A4,  F4
	.word  G4,  F4,  E4,  F4,  F4,   0
	.word	  0,   0,   0

	@ 音ゲーの譜面を格納するバッファ
	@ ここからの読み出しは、soundLen_buffer での 1 の長さ分単位で行われる
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0

	.byte 1, 0, 0, 0, 0, 0, 0, 0	@11
	.byte 1, 0, 0, 0, 0, 0, 0, 0	@
	.byte 1, 0, 0, 0, 2, 0, 0, 0	@12
	.byte 1, 0, 0, 0, 0, 0, 0, 0	@
	.byte 8, 0, 0, 0, 0, 0, 0, 0	@13
	.byte 8, 0, 0, 0, 0, 0, 0, 0	@
	.byte 8, 0, 0, 0, 4, 0, 0, 0	@14
	.byte 8, 0, 0, 0, 0, 0, 0, 0	@
	.byte 1, 0, 0, 0, 0, 0, 0, 0	@15
	.byte 4, 0, 0, 0, 0, 0, 0, 0	@
	.byte 1, 0, 0, 0, 4, 0, 0, 0	@16
	.byte 1, 0, 0, 0, 0, 0, 0, 0	@
	.byte 2, 0, 0, 0, 0, 0, 0, 0	@17
	.byte 8, 0, 0, 0, 0, 0, 0, 0	@
	.byte 2, 0, 0, 0, 8, 0, 0, 0	@18
	.byte 2, 0, 0, 0, 0, 0, 0, 0	@

	.byte 0, 0, 0, 1, 0, 2, 0, 8	@まちあわ
	.byte 0, 4, 0, 1, 0, 0, 0, 0	@せはー
	.byte 0, 0, 0, 4, 0, 8, 0, 2	@にじかんま
	.byte 0, 1, 0, 4, 0, 0, 0, 0	@えでー

	.byte 0, 0, 0, 2, 0, 4, 0, 1	@ここに
	.byte 0, 8, 0, 2, 0, 0, 0, 0	@ひとり
	.byte 1, 0, 0, 0, 4, 0, 0, 0	@それがこたえ
	.byte 0, 0, 1, 0, 0, 0, 0, 0	@でしょ				/38

	.byte 0, 0, 0, 1, 0, 0, 0, 0	@23まちゆく
	.byte 0, 2, 0, 8, 0, 0, 0, 0	@ひとー
	.byte 0, 0, 0, 2, 0, 0, 0, 0	@ながれる
	.byte 0, 1, 0, 4, 0, 0, 0, 0	@くもー
	.byte 0, 0, 0, 2, 0, 0, 0, 8	@ぼくのこ
	.byte 0, 0, 0, 0, 0, 0, 4, 0	@とをーあ
	.byte 1, 0, 2, 0, 0, 0, 8, 4 	@ざわらってたー
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@それは

	.byte 4, 0, 0, 1, 0, 0, 2, 0	@かんたんで
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@とても
	.byte 2, 0, 0, 1, 0, 0, 4, 0	@こんなんで
	.byte 0, 0, 0, 0, 0, 8, 0, 0	@みとめ
	.byte 0, 0, 2, 0, 0, 0, 0, 1	@ることでま
	.byte 0, 0, 0, 0, 0, 0, 4, 0	@えにす
	.byte 1, 0, 0, 0, 0, 2, 0, 8	@30すめるのに
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@しんじ
	.byte 8, 0, 0, 2, 0, 0, 1, 0	@られなくて
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@しんじ
	.byte 1, 0, 0, 2, 0, 0, 8, 0	@たくなくて
	.byte 0, 0, 0, 0, 0, 1, 0, 0	@きみの
	.byte 4, 0, 0, 0, 0, 2, 0, 0	@なかできっと
	.byte 8, 0, 0, 0, 0, 2, 0, 0	@ぼくはどうけ
	.byte 0, 0, 0, 0, 0, 5, 0, 10	@しなんでしょ		@同時*2
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@休							/39

	.byte 1, 0, 0, 0, 4, 0, 0, 8	@35あーまわって
	.byte 0, 0, 0, 0, 4, 0, 0, 8	@まわって
	.byte 0, 0, 0, 0, 4, 0, 0, 8	@まわり
	.byte 0, 0, 1, 0, 2, 0, 0, 8	@つかれて
	.byte 4, 0, 0, 0, 1, 0, 0, 2	@あーいきが
	.byte 0, 0, 0, 0, 1, 0, 0, 2	@いきが
	.byte 0, 0, 4, 0, 1, 0, 0, 2	@きれたの
	.byte 0, 0, 0, 0, 0, 0, 0, 0	@休

	.byte 0, 0, 0, 0, 4, 0, 0, 8	@39そうそれが
	.byte 0, 0, 0, 0, 1, 0, 0, 2	@かなしい
	.byte 0, 0, 0, 0, 0, 0, 0, 8	@ぼくのま
	.byte 0, 0, 4, 0, 1, 0, 2, 0	@つろだ
	.byte 0, 0, 8, 0, 0, 0, 0, 4	@きみにた
	.byte 0, 0, 0, 0, 0, 0, 1, 0	@どりつ
	.byte	0, 0, 0, 0, 12, 0, 0, 3	@けないままで	@同時*2	/33
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@休
