	@ 音ゲーを実行するサブルーチン (ver.アイネクライネ)
	
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
	.include "einekleine.h"
	@ SOUND_LENGTHは音符の数(タイ等、繋がっている音符は一つと数えること）
	.equ	SOUND_LENGTH,	269
	.equ	NOTES_COUNT, 	956		@ ノーツ更新用のnotes_bufferの個数
	.equ	NOTES_SPEED,	TIMER_HZ*4/5		@ ノーツの渦を巻く早さ
	@ ノーツの合計　スコアを割合で算出するための定義
	.equ	NOTES_SUM, 	153		@ これは仮の数！　書き換え必須
	
	.section .text
	@ このラベルの名前は [music_曲名] で統一
	.global music_einekleine
music_einekleine:	
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
	.byte 2, 2, 2, 2, 2, 2, 2, 2		      	@ kankan
	.byte	26, 2, 2, 2	                     	@ 1
	.byte	6, 2, 6, 2, 4, 2, 2, 4, 2, 2 	  	@ 2
	.byte	6, 2, 6, 2, 4, 2, 2, 2, 2, 2, 2		@ 3
	.byte	6, 2, 6, 2, 2, 2, 2, 2, 4, 4 	   	@ 4
	.byte	6, 2, 6, 2, 4, 2, 6, 2, 2	      	@ 5
	.byte	4, 2, 4, 2, 8, 2, 4, 2, 8	      	@ 6,(7)   /61
	.byte	2, 4, 2, 12, 2, 4, 6             	@ 7,(8)
	.byte	2, 2, 6, 2, 2, 2, 4, 4, 4        	@ 8
	.byte	4, 2, 4, 2, 2, 10               	@ 9, 10
	.byte	8, 6, 2, 8, 4, 4, 4, 4			      @ arrange 
	.byte	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2	@ 21
	.byte	4, 4, 4, 4, 6, 1, 1, 8                         	@ 22
	.byte	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2	@ 23
	.byte	4, 4, 4, 4, 6, 1, 1, 8                        	@ 24
	.byte	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4      	@ 25
	.byte	2, 2, 2, 2, 4, 4, 6, 1, 1, 6, 2               	@ 26
	.byte	8, 6, 10, 6, 10, 6, 34, 16, 8                  	@ 27,28,29,(30)	/170(21-)
	.byte	2, 2, 2, 6, 2, 4, 2, 2, 6, 2, 4, 2, 2, 2      	@ 30,31
	.byte	1, 4, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 6         	@ 32,(33)      @休符短縮
	.byte	2, 4, 2, 2, 6, 2, 2, 2, 2, 2, 6 	              @ 33,(34)
	.byte	4, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 6	            @ 34,(35) 
	.byte	2, 4, 2, 2, 6, 2, 4, 2, 2, 6	                  @ 35,(36)
	.byte	4, 2, 2, 2, 2, 4, 2, 2, 4, 4	                  @ 36
	.byte	4, 4, 4, 8, 4, 2, 6                           	@ 37
	.byte	4, 2, 4, 2, 16, 4, 4, 4, 4, 8, 4, 2, 6        	@ 38,39
	.byte	4, 2, 4, 2, 4, 5      													@ 40           	/96(30-)
	.byte	0,0,0		@4の倍数にする

	@ sound_buffer
	@ 音程を示すバッファ
	@ http://pianobooks.jp/score.php?id=86 より
	@ 右側の@の後の数字は、そのサイトでの何小節目にあるかを示す
	@ 音程に違和感があれば別サイトで音程を照合して書き換えよろしく
sound_buffer:
	.word F5S,   0, F5S,   0, F5S,   0, F5S,   0                 	@ kankan
	.word	  0,  F5,  F5,  F5                                     	@ 1
	.word	B5F, B5F,  C6,  C6, D6F, D6F, A5F,   0,  F5, G5F      	@ 2
	.word	A5F, B5F, A5F, G5F,  F5, E5F,  F5,   0,  F5,  F5, F5  	@ 3
	.word	B5F, B5F,  C6,  C6, D6F, B5F, B5F,  C6, D6F,  F6      	@ 4
	.word	E6F,  F6, G6F,  C6, E6F, D6F, D6F, D6F,  C6           	@ 5
	.word	B5F, B5F, A5F, G5F, A5F, G5F,  F5, E5F, G5F           	@ 6,(7)
	.word	 F5, E5F, D5F,  F5,   0, B5F, A5F                      	@ 7,(8)
	.word	 F5, G5F, A5F, B5F, A5F, G5F,  F5, E5F,  F5           	@ 8
	.word	G5F,  F5, E5F, D5F, D5F, D5F           	              	@ 9, 10
	.word	  0, G3F, G3F,   0, A3F, A3F, D4F, D6F                 	@ 繋がりアレンジ
	.word	E5F, E5F, D5F, D5F, B4F, B4F, D5F, D5F,  C5,  C5, A4F, A4F,  F4,  F4, A4F, A4F	@ 21
	.word	G4F,  F4, G4F, A4F,  F4, G4F,  F4, E4F                                        	@ 22
	.word	E5F, E5F, D5F, D5F, B4F, B4F, D5F, D5F,  C5,  C5, A4F, A4F,  F4,  F4, A4F, A4F	@ 23
	.word	G4F,  F4, E4F,  F4, E4F,  F4, E4F, D4F                                        	@ 24
	.word	E5F, E5F, D5F, D5F, B4F, B4F, D5F, D5F,  C5,  C5, A4F, A4F,  F4, A4F          	@ 25
	.word	G4F, G4F,  F4,  F4, G4F, A4F,  F4, G4F,  F4, E4F, D4F                          	@ 26
	.word	D4F, B4F, A4F, D5F,  C5, E5F, D5F, D5F,   0                                    	@ 27-(30)
	.word	  0, D5F, E5F,  F5, G5F, A5F, G5F,  F5, E5F,  F5, G5F,  F5, E5F, D5F          	@ 30,31
	.word	  0, D5F,  C5, D5F,  C5, B4F, A4F,  F4,  F4,   0, D5F, E5F,  F5               	@ 32,(33)
	.word	G5F, A5F, G5F,  F5, E5F,  F5,  F5, G5F,  F5, E5F, D5F                         	@ 33,(34)
	.word	 F5, E5F, D5F,  C5, A4F, E5F, D5F, D5F,   0, D5F, E5F,  F5                    	@ 34,(35)
	.word	G5F, A5F, G5F,  F5, E5F,  F5, G5F,  F5, E5F, D5F                              	@ 35,(36)
	.word	D5F,  C5, D5F,  C5, B4F, A4F,  F4,  F4,   0,  F4                              	@ 36
	.word	 F5, E5F,  F5, G5F,  F5, E5F, D5F                                             	@ 37
	.word	B4F, D5F, E5F, D5F, D5F, A4F,  F5, E5F,  F5, G5F,  F5, E5F, D5F               	@ 38,39
	.word	B4F, D5F, E5F, D5F, D5F,   0                                                   	@ 40
	.word	0,0,0

	@ 音ゲーの譜面を格納するバッファ
	@ 二進数にて 右上 左上 右下 左下 を表現 (0: 無点灯, 1: 点灯)
	@ 例) 0x4 | -> 0100(2) -> 左上のみ点灯
notes_buffer:
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0

	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0	
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@あたし

	.byte	1, 0, 0, 0, 0, 0, 0, 0	@あな
	.byte	2, 0, 0, 0, 0, 0, 0, 0	@たに
	.byte	8, 0, 0, 0, 0, 0, 0, 0	@あえて
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ほん

	.byte	1, 0, 0, 0, 0, 0, 0, 0	@とうに
	.byte	2, 0, 0, 0, 0, 0, 0, 0	@うれ
	.byte	8, 0, 0, 0, 2, 0, 1, 0	@しいのに 
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@あたり

	.byte	2, 0, 0, 0, 0, 0, 0, 0	@まえの
	.byte	4, 0, 0, 0, 0, 0, 0, 0	@ように
	.byte	8, 0, 0, 0, 2, 0, 1, 0 	@そーれら
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@すべ

	.byte	8, 0, 0, 0, 0, 0, 0, 0	@てが
	.byte	4, 0, 0, 0, 0, 0, 0, 0	@かな
	.byte	8, 0, 0, 0, 2, 0, 1, 0	@しいんだ
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@いま				/(18)

	.byte	4, 0, 0, 0, 0, 0, 0, 0	@あいたい
	.byte	0, 0, 8, 0, 0, 0, 0, 0	@ーくらい
	.byte	0, 0, 0, 0, 2, 0, 0, 0	@ーしあ
	.byte	0, 0, 1, 0, 0, 0, 0, 0	@ーわせ

	.byte	0, 0, 0, 0, 8, 0, 0, 0	@ーなおもい
	.byte	0, 0, 4, 0, 0, 0, 0, 0	@ーでが
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	0, 0, 1, 0, 0, 0, 0, 0	@いつか

	.byte	0, 0, 0, 0, 2, 0, 0, 0	@ーくる
	.byte	4, 0, 0, 0, 0, 0, 8, 0	@おわ
	.byte	2, 0, 1, 0, 0, 0, 0, 0	@かれを
	.byte	4, 0, 0, 0, 8, 0, 0, 0	@そだ

	.byte	1, 0, 0, 0, 2, 0, 8, 0	@ててあ
	.byte	0, 0, 0, 0, 1, 0, 4, 0	@ーるく
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー				/37*8  /(37)

	.byte	0, 0, 0, 0, 0, 0, 0, 0	@arrange
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0						/42*8

	.byte	1, 0, 0, 0, 2, 0, 0, 0	@あなたに
	.byte	8, 0, 0, 0, 4, 0, 0, 0	@あたしの
	.byte	1, 0, 0, 0, 2, 0, 0, 0	@おもいが
	.byte	8, 0, 0, 0, 4, 0, 0, 0	@ぜんぶつ

	.byte	1, 0, 0, 0, 0, 0, 0, 0	@たわっ
	.byte	2, 0, 0, 0, 0, 0, 0, 0	@てほ
	.byte	8, 0, 0, 0, 0, 0, 4, 0	@しいのー
	.byte	1, 0, 0, 0, 0, 0, 0, 0	@に

	.byte	8, 0, 0, 0, 2, 0, 0, 0	@だれにも
	.byte	1, 0, 0, 0, 4, 0, 0, 0	@いえない
	.byte	8, 0, 0, 0, 2, 0, 0, 0	@ひみつが
	.byte	1, 0, 0, 0, 4, 0, 0, 0	@あってう

	.byte	8, 0, 0, 0, 0, 0, 0, 0	@そをつい
	.byte	2, 0, 0, 0, 0, 0, 0, 0	@てしまう
	.byte	1, 0, 0, 0, 0, 4, 0, 0	@のーー
	.byte	8, 0, 0, 0, 0, 0, 0, 0	@だ

	.byte	1, 0, 0, 0, 2, 0, 0, 0	@あなたが
	.byte	8, 0, 0, 0, 4, 0, 0, 0	@おもえば
	.byte	1, 0, 0, 0, 2, 0, 0, 0	@おもうよ
	.byte	8, 0, 0, 0, 4, 0, 0, 0	@りい

	.byte	1, 0, 0, 0, 0, 0, 0, 0	@くつもあ
	.byte	2, 0, 0, 0, 0, 0, 0, 0	@たしはい
	.byte	8, 0, 0, 0, 0, 0, 0, 0	@くじー
	.byte	4, 0, 0, 0, 2, 0, 0, 0	@ないの

	.byte	8, 0, 0, 0, 0, 0, 0, 0	@に
	.byte	4, 0, 0, 0, 0, 8, 0, 0	@どうして
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	1, 0, 0, 0, 0, 2, 0, 0	@どうして			/70*8

	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	4, 0, 0, 0, 0, 8, 0, 0	@どうして		/72*8   /(37+46=83)

	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー	低音にあわせて置く
	.byte	1, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	8, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	3, 0, 0, 0, 0, 0, 0, 0	@ー					/同時押し個数？

	.byte	12, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	15, 0, 0, 0, 0, 0, 0, 0	@
	.byte	15, 0, 0, 0, 0, 0, 0, 0	@休
	.byte	0, 0, 2, 0, 8, 0, 4, 0	@きえない				/(83+9=92)

	.byte	0, 0, 0, 0, 2, 0, 0, 0	@ーかな
	.byte	0, 0, 1, 0, 8, 0, 2, 0	@ーしみも
	.byte	0, 0, 0, 0, 8, 0, 0, 0	@ーほこ
	.byte	0, 0, 1, 0, 8, 0, 2, 0	@ーろびも

	.byte	0, 4, 0, 0, 0         	@あ							/-3
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@なたとい
	.byte	2, 0, 0, 0, 0, 0, 4, 0	@れーば
	.byte	0, 0, 2, 0, 8, 0, 4, 0	@それで

	.byte	0, 0, 0, 0, 2, 0, 0, 0	@ーよか
	.byte	0, 0, 4, 0, 1, 0, 2, 0	@ーったねと
	.byte	0, 0, 0, 0, 1, 0, 0, 0	@ーわら
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@えるのが

	.byte	0, 0, 0, 0, 8, 0, 0, 0	@ーどん
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@なにうれ
	.byte	1, 0, 0, 0, 8, 0, 4, 0	@しいか	
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@めのまえ

	.byte	0, 0, 0, 0, 0, 0, 1, 0	@ーのす
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ーべてが
	.byte	0, 0, 0, 0, 2, 0, 0, 0	@ーぼや
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ーけては

	.byte	0, 0, 0, 0, 4, 0, 0, 0	@ーと
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@けてゆく
	.byte	1, 0, 0, 0, 8, 0, 2, 0	@ような
	.byte	0, 0, 0, 0, 1, 0, 0, 0	@き

	.byte	2, 0, 0, 0, 1, 0, 0, 0	@せき
	.byte	2, 0, 0, 0, 1, 0, 0, 0	@であ
	.byte	0, 0, 0, 0, 4, 0, 0, 0	@ーふ
	.byte	2, 0, 1, 0, 0, 0, 0, 0	@れて

	.byte	4, 0, 0, 0, 1, 0, 2, 0	@たりな
	.byte	0, 0, 4, 0, 8, 0, 0, 0	@ーいや
	.byte	0, 0, 0, 0, 0, 0, 0, 0	@ー
	.byte	0, 0, 0, 0, 4, 0, 0, 0	@ーあ				/112*8-3	/(92+43=135)

	.byte	8, 0, 0, 0, 4, 0, 0, 0	@たし
	.byte	8, 0, 0, 0, 4, 0, 0, 0	@のな
	.byte	0, 0, 0, 0, 1, 0, 0, 0	@ーま
	.byte	8, 0, 4, 0, 0, 0, 0, 0	@えを

	.byte	1, 0, 0, 0, 4, 0, 8, 0	@よんでく
	.byte	0, 0, 1, 0, 2, 0, 0, 0	@ーれた
	.byte	0, 0, 0, 0, 0, 0, 0, 0 	@
	.byte	0, 0, 0, 0, 0, 0, 0	  	@			/119*8-3 = 952 -3 + 3		/(135+12=147) +6(同時押し分)
