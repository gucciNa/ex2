
	.include "common.h"
	.section .init
	.global _start
_start:
	mov	sp, #STACK	@ スタックポインタの初期化
	
	@ LEDとディスレイ用のIOポートを出力に設定する
	ldr     r0, =GPIO_BASE
	ldr     r1, =GPFSEL_VEC0
	str     r1, [r0, #GPFSEL0 + 0]
	ldr     r1, =GPFSEL_VEC1
	str     r1, [r0, #GPFSEL0 + 4]
	ldr     r1, =GPFSEL_VEC2
	str     r1, [r0, #GPFSEL0 + 8]
	
	@ クロックソースの設定
	ldr 	r0, =CM_BASE
	ldr 	r1, =0x5a000021
	str 	r1, [r0, #CM_PWMCTL]
1:
	ldr 	r1, [r0, #CM_PWMCTL]
	tst 	r1, #0x80
	bne 	1b
	ldr 	r1, =(0x5a000000 | (2 << 12))
	str 	r1, [r0, #CM_PWMDIV]
	ldr 	r1, =0x5a000211
	str 	r1, [r0, #CM_PWMCTL]

	@ 全ての行を消灯
	mov     r1, #(1 << ROW1_PORT)
	add	r1, r1, #(1 << ROW2_PORT)
	add	r1, r1, #(1 << ROW3_PORT)
	add	r1, r1, #(1 << ROW4_PORT)
	add	r1, r1, #(1 << ROW5_PORT)
	add	r1, r1, #(1 << ROW6_PORT)
	add	r1, r1, #(1 << ROW7_PORT)
	add	r1, r1, #(1 << ROW8_PORT)
	str     r1, [r0, #GPSET0]		@ 消灯

	mov	r11, #1
	mov	r12, #0
chooseMusic:
	cmp	r11, #0
	moveq	r11, #7
	cmp	r11, #1
	bleq	choose_zenzenzense
	cmp	r11, #2
	bleq	choose_melissa
	cmp	r11, #3
	bleq	choose_umiyuri
	cmp	r11, #4
	bleq	choose_karakuri
	cmp	r11, #5
	bleq	choose_einekleine
	cmp	r11, #6
	bleq	choose_rinsaku
	cmp	r11, #7
	bleq	choose_hungry
	cmp	r11, #8
	moveq	r11, #1

	b	chooseMusic

loop:	b	loop
