	.equ    GPIO_BASE,  0x3f200000 @ GPIOベースアドレス
	.equ    GPFSEL0,    0x00       @ GPIOポートの機能を選択する番地のオフセット
	.equ    GPSET0,     0x1C       @ GPIOポートの出力値を1にするための番地のオフセット
	.equ    GPCLR0,     0x28       @ GPIOボートの出力値を0にするための番地のオフセット
	.equ	GPLEV0,     0x34       @ GPIOポートのピンの値を返すためのオフセット
	.equ	LED_PORT,   10	       @ LEDが接続されたGPIOのポート番号
	.equ	SW1_PORT,   13         @ SW1が接続されたGPIOのポート番号
	.equ	SW2_PORT,   26	       @ SW2が接続されたGPIOのポート番号
	.equ	SW3_PORT,   5	       @ SW3が接続されたGPIOのポート番号
	.equ   	SW4_PORT,   6	       @ SW4が接続されたGPIOのポート番号

	.equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 に設定する値 (GPIO #4, #7, #8 を出力用に設定)
	.equ    GPFSEL_VEC1, 0x11249041 @ GPFSEL1 に設定する値 (GPIO #10, #12, #14, #15, #16, #17, #18 を出力用, #19を PWM1(ALT5)に設定)
	.equ    GPFSEL_VEC2, 0x00209249 @ GPFSEL2 に設定する値 (GPIO #20, #21, #22, #23, #24, #25, #27 を出力用に設定)
	.equ 	TIMER_BASE, 0x3f003000	@ システムタイマの制御レジスタのベースアドレス
	.equ 	CLO,	    0x4		@ システムタイマの下位32ビットのオフセット
	.equ	STACK,      0x8000	@ スタックポインタの初期値
	.equ	PWM_HZ, 9600 * 1000
	.equ	A1, PWM_HZ / 55			@ ラ
	.equ	B1, PWM_HZ / 62			@ シ
	.equ	C2, PWM_HZ / 65			@ ド
	.equ	D2, PWM_HZ / 73			@ レ
	.equ	E2, PWM_HZ / 82			@ ミ
	.equ	F2, PWM_HZ / 87			@ ファ
	.equ	G2, PWM_HZ / 98			@ ソ
	.equ	A2, PWM_HZ / 110		@ ラ
	.equ	B2, PWM_HZ / 123		@ シ
	.equ	C3, PWM_HZ / 131		@ ド
	.equ	D3, PWM_HZ / 147		@ レ
	.equ	E3, PWM_HZ / 165		@ ミ
	.equ	F3, PWM_HZ / 175		@ ファ
	.equ	G3, PWM_HZ / 196		@ ソ
	.equ	A3, PWM_HZ / 220		@ ラ
	.equ	B3, PWM_HZ / 247		@ シ
	.equ	C4, PWM_HZ / 262		@ ド
	.equ	D4, PWM_HZ / 294		@ レ
	.equ	E4, PWM_HZ / 330		@ ミ
	.equ	F4, PWM_HZ / 349		@ ファ
	.equ	G4, PWM_HZ / 392		@ ソ	
	.equ	A4, PWM_HZ / 440		@ ラ 440Hzのときの1周期クロック数
	.equ	B4, PWM_HZ / 494		@ シ
	.equ	C5, PWM_HZ / 523		@ ド
	.equ	D5, PWM_HZ / 587		@ レ
	.equ	E5, PWM_HZ / 659		@ ミ
	.equ	F5, PWM_HZ / 698		@ ファ
	.equ	G5, PWM_HZ / 784		@ ソ
	.equ	A5, PWM_HZ / 880		@ ラ
	.equ	B5, PWM_HZ / 988		@ シ
	.equ	C6, PWM_HZ / 1047		@ ド
	.equ	D6, PWM_HZ / 1175		@ レ
	.equ	E6, PWM_HZ / 1319		@ ミ
	.equ	F6, PWM_HZ / 1397		@ ファ
	.equ	G6, PWM_HZ / 1568		@ ソ	
	.equ	A6, PWM_HZ / 1760		@ ラ
	
	.equ	A1S, PWM_HZ / 58		@ ラ#   シ♭
	.equ	C2S, PWM_HZ / 69		@ ド#   レ♭
	.equ	D2S, PWM_HZ / 78		@ レ#   ミ♭
	.equ	F2S, PWM_HZ / 92		@ ファ# ソ♭
	.equ	G2S, PWM_HZ / 104		@ ソ#   ラ♭

	.equ	A2S, PWM_HZ / 117		@ ラ#   シ♭
	.equ	C3S, PWM_HZ / 139		@ ド#   レ♭
	.equ	D3S, PWM_HZ / 156		@ レ#   ミ♭
	.equ	F3S, PWM_HZ / 185		@ ファ# ソ♭
	.equ	G3S, PWM_HZ / 208		@ ソ#   ラ♭
	
	.equ	A3S, PWM_HZ / 233		@ ラ#   シ♭
	.equ	C4S, PWM_HZ / 277		@ ド#   レ♭
	.equ	D4S, PWM_HZ / 311		@ レ#   ミ♭
	.equ	F4S, PWM_HZ / 370		@ ファ# ソ♭
	.equ	G4S, PWM_HZ / 415		@ ソ#   ラ♭
	
	.equ	A4S, PWM_HZ / 466		@ ラ#   シ♭
	.equ	C5S, PWM_HZ / 554		@ ド#   レ♭
	.equ	D5S, PWM_HZ / 622		@ レ#   ミ♭
	.equ	F5S, PWM_HZ / 740		@ ファ# ソ♭
	.equ	G5S, PWM_HZ / 831		@ ソ#   ラ♭

	.equ	A5S, PWM_HZ / 932		@ ラ#   シ♭
	.equ	C6S, PWM_HZ / 1109		@ ド#   レ♭
	.equ	D6S, PWM_HZ / 1245		@ レ#   ミ♭
	.equ	F6S, PWM_HZ / 1480		@ ファ# ソ♭
	.equ	G6S, PWM_HZ / 1661		@ ソ#   ラ♭

	.equ	B1F, PWM_HZ / 58		@ ラ#   シ♭
	.equ	D2F, PWM_HZ / 69		@ ド#   レ♭
	.equ	E2F, PWM_HZ / 78		@ レ#   ミ♭
	.equ	G2F, PWM_HZ / 92		@ ファ# ソ♭
	.equ	A2F, PWM_HZ / 104		@ ソ#   ラ♭

	.equ	B2F, PWM_HZ / 117		@ ラ#   シ♭
	.equ	D3F, PWM_HZ / 139		@ ド#   レ♭
	.equ	E3F, PWM_HZ / 156		@ レ#   ミ♭
	.equ	G3F, PWM_HZ / 185		@ ファ# ソ♭
	.equ	A3F, PWM_HZ / 208		@ ソ#   ラ♭
	
	.equ	B3F, PWM_HZ / 233		@ ラ#   シ♭
	.equ	D4F, PWM_HZ / 277		@ ド#   レ♭
	.equ	E4F, PWM_HZ / 311		@ レ#   ミ♭
	.equ	G4F, PWM_HZ / 370		@ ファ# ソ♭
	.equ	A4F, PWM_HZ / 415		@ ソ#   ラ♭
	
	.equ	B4F, PWM_HZ / 466		@ ラ#   シ♭
	.equ	D5F, PWM_HZ / 554		@ ド#   レ♭
	.equ	E5F, PWM_HZ / 622		@ レ#   ミ♭
	.equ	G5F, PWM_HZ / 740		@ ファ# ソ♭
	.equ	A5F, PWM_HZ / 831		@ ソ#   ラ♭

	.equ	B5F, PWM_HZ / 932		@ ラ#   シ♭
	.equ	D6F, PWM_HZ / 1109		@ ド#   レ♭
	.equ	E6F, PWM_HZ / 1245		@ レ#   ミ♭
	.equ	G6F, PWM_HZ / 1480		@ ファ# ソ♭
	.equ	A6F, PWM_HZ / 1661		@ ソ#   ラ♭
	
	.equ	D7F, PWM_HZ / 2217	@ レ♭


	.equ	CM_BASE, 0x3f101000
	.equ	CM_PWMCTL, 0xa0
	.equ	CM_PWMDIV, 0xa4

	.equ	PWM_BASE, 0x3f20c000
	.equ	PWM_CTL, 0x0

	.equ	PWM_DAT2, 0x24
	.equ	PWM_RNG2, 0x20
	@ 0x8100 = 1000 0001 0000 0000  -> PWEN2, MSEN2 を1 に
	.equ	PWM_SET, 0x8100
	.equ	PWM_CLR, 0x0

	.equ    MINUTE_HZ, 100 * 1000
	   
	.equ 	COL1_PORT, 27
	.equ 	COL2_PORT, 8
	.equ	COL3_PORT, 25
	.equ	COL4_PORT, 23
	.equ	COL5_PORT, 24
	.equ	COL6_PORT, 22
	.equ	COL7_PORT, 17
	.equ 	COL8_PORT, 4
	.equ 	ROW1_PORT, 14
	.equ 	ROW2_PORT, 15
	.equ 	ROW3_PORT, 21
	.equ 	ROW4_PORT, 18
	.equ 	ROW5_PORT, 12
	.equ 	ROW6_PORT, 20
	.equ 	ROW7_PORT, 7
	.equ 	ROW8_PORT, 16

	.equ	LIGHT1110, 0xe
	.equ 	LIGHT0100, 0x4
	.equ	LIGHT1100, 0xc
	.equ	LIGHT1000, 0x8
	.equ	LIGHT1010, 0xa
	.equ	LIGHT0010, 0x2

