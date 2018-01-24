	.equ    GPIO_BASE,  0x3f200000 @ GPIO�١������ɥ쥹
	.equ    GPFSEL0,    0x00       @ GPIO�ݡ��Ȥε�ǽ�����򤹤����ϤΥ��ե��å�
	.equ    GPSET0,     0x1C       @ GPIO�ݡ��Ȥν����ͤ�1�ˤ��뤿������ϤΥ��ե��å�
	.equ    GPCLR0,     0x28       @ GPIO�ܡ��Ȥν����ͤ�0�ˤ��뤿������ϤΥ��ե��å�
	.equ	GPLEV0,     0x34       @ GPIO�ݡ��ȤΥԥ���ͤ��֤�����Υ��ե��å�
	.equ	LED_PORT,   10	       @ LED����³���줿GPIO�Υݡ����ֹ�
	.equ	SW1_PORT,   13         @ SW1����³���줿GPIO�Υݡ����ֹ�
	.equ	SW2_PORT,   26	       @ SW2����³���줿GPIO�Υݡ����ֹ�
	.equ	SW3_PORT,   5	       @ SW3����³���줿GPIO�Υݡ����ֹ�
	.equ   	SW4_PORT,   6	       @ SW4����³���줿GPIO�Υݡ����ֹ�

	.equ    GPFSEL_VEC0, 0x01201000 @ GPFSEL0 �����ꤹ���� (GPIO #4, #7, #8 ������Ѥ�����)
	.equ    GPFSEL_VEC1, 0x11249041 @ GPFSEL1 �����ꤹ���� (GPIO #10, #12, #14, #15, #16, #17, #18 �������, #19�� PWM1(ALT5)������)
	.equ    GPFSEL_VEC2, 0x00209249 @ GPFSEL2 �����ꤹ���� (GPIO #20, #21, #22, #23, #24, #25, #27 ������Ѥ�����)
	.equ 	TIMER_BASE, 0x3f003000	@ �����ƥॿ���ޤ�����쥸�����Υ١������ɥ쥹
	.equ 	CLO,	    0x4		@ �����ƥॿ���ޤβ���32�ӥåȤΥ��ե��å�
	.equ	STACK,      0x8000	@ �����å��ݥ��󥿤ν����
	.equ	PWM_HZ, 9600 * 1000
	.equ	A1, PWM_HZ / 55			@ ��
	.equ	B1, PWM_HZ / 62			@ ��
	.equ	C2, PWM_HZ / 65			@ ��
	.equ	D2, PWM_HZ / 73			@ ��
	.equ	E2, PWM_HZ / 82			@ ��
	.equ	F2, PWM_HZ / 87			@ �ե�
	.equ	G2, PWM_HZ / 98			@ ��
	.equ	A2, PWM_HZ / 110		@ ��
	.equ	B2, PWM_HZ / 123		@ ��
	.equ	C3, PWM_HZ / 131		@ ��
	.equ	D3, PWM_HZ / 147		@ ��
	.equ	E3, PWM_HZ / 165		@ ��
	.equ	F3, PWM_HZ / 175		@ �ե�
	.equ	G3, PWM_HZ / 196		@ ��
	.equ	A3, PWM_HZ / 220		@ ��
	.equ	B3, PWM_HZ / 247		@ ��
	.equ	C4, PWM_HZ / 262		@ ��
	.equ	D4, PWM_HZ / 294		@ ��
	.equ	E4, PWM_HZ / 330		@ ��
	.equ	F4, PWM_HZ / 349		@ �ե�
	.equ	G4, PWM_HZ / 392		@ ��	
	.equ	A4, PWM_HZ / 440		@ �� 440Hz�ΤȤ���1��������å���
	.equ	B4, PWM_HZ / 494		@ ��
	.equ	C5, PWM_HZ / 523		@ ��
	.equ	D5, PWM_HZ / 587		@ ��
	.equ	E5, PWM_HZ / 659		@ ��
	.equ	F5, PWM_HZ / 698		@ �ե�
	.equ	G5, PWM_HZ / 784		@ ��
	.equ	A5, PWM_HZ / 880		@ ��
	.equ	B5, PWM_HZ / 988		@ ��
	.equ	C6, PWM_HZ / 1047		@ ��
	.equ	D6, PWM_HZ / 1175		@ ��
	.equ	E6, PWM_HZ / 1319		@ ��
	.equ	F6, PWM_HZ / 1397		@ �ե�
	.equ	G6, PWM_HZ / 1568		@ ��	
	.equ	A6, PWM_HZ / 1760		@ ��
	
	.equ	A1S, PWM_HZ / 58		@ ��#   ����
	.equ	C2S, PWM_HZ / 69		@ ��#   ���
	.equ	D2S, PWM_HZ / 78		@ ��#   �ߢ�
	.equ	F2S, PWM_HZ / 92		@ �ե�# ����
	.equ	G2S, PWM_HZ / 104		@ ��#   ���

	.equ	A2S, PWM_HZ / 117		@ ��#   ����
	.equ	C3S, PWM_HZ / 139		@ ��#   ���
	.equ	D3S, PWM_HZ / 156		@ ��#   �ߢ�
	.equ	F3S, PWM_HZ / 185		@ �ե�# ����
	.equ	G3S, PWM_HZ / 208		@ ��#   ���
	
	.equ	A3S, PWM_HZ / 233		@ ��#   ����
	.equ	C4S, PWM_HZ / 277		@ ��#   ���
	.equ	D4S, PWM_HZ / 311		@ ��#   �ߢ�
	.equ	F4S, PWM_HZ / 370		@ �ե�# ����
	.equ	G4S, PWM_HZ / 415		@ ��#   ���
	
	.equ	A4S, PWM_HZ / 466		@ ��#   ����
	.equ	C5S, PWM_HZ / 554		@ ��#   ���
	.equ	D5S, PWM_HZ / 622		@ ��#   �ߢ�
	.equ	F5S, PWM_HZ / 740		@ �ե�# ����
	.equ	G5S, PWM_HZ / 831		@ ��#   ���

	.equ	A5S, PWM_HZ / 932		@ ��#   ����
	.equ	C6S, PWM_HZ / 1109		@ ��#   ���
	.equ	D6S, PWM_HZ / 1245		@ ��#   �ߢ�
	.equ	F6S, PWM_HZ / 1480		@ �ե�# ����
	.equ	G6S, PWM_HZ / 1661		@ ��#   ���

	.equ	B1F, PWM_HZ / 58		@ ��#   ����
	.equ	D2F, PWM_HZ / 69		@ ��#   ���
	.equ	E2F, PWM_HZ / 78		@ ��#   �ߢ�
	.equ	G2F, PWM_HZ / 92		@ �ե�# ����
	.equ	A2F, PWM_HZ / 104		@ ��#   ���

	.equ	B2F, PWM_HZ / 117		@ ��#   ����
	.equ	D3F, PWM_HZ / 139		@ ��#   ���
	.equ	E3F, PWM_HZ / 156		@ ��#   �ߢ�
	.equ	G3F, PWM_HZ / 185		@ �ե�# ����
	.equ	A3F, PWM_HZ / 208		@ ��#   ���
	
	.equ	B3F, PWM_HZ / 233		@ ��#   ����
	.equ	D4F, PWM_HZ / 277		@ ��#   ���
	.equ	E4F, PWM_HZ / 311		@ ��#   �ߢ�
	.equ	G4F, PWM_HZ / 370		@ �ե�# ����
	.equ	A4F, PWM_HZ / 415		@ ��#   ���
	
	.equ	B4F, PWM_HZ / 466		@ ��#   ����
	.equ	D5F, PWM_HZ / 554		@ ��#   ���
	.equ	E5F, PWM_HZ / 622		@ ��#   �ߢ�
	.equ	G5F, PWM_HZ / 740		@ �ե�# ����
	.equ	A5F, PWM_HZ / 831		@ ��#   ���

	.equ	B5F, PWM_HZ / 932		@ ��#   ����
	.equ	D6F, PWM_HZ / 1109		@ ��#   ���
	.equ	E6F, PWM_HZ / 1245		@ ��#   �ߢ�
	.equ	G6F, PWM_HZ / 1480		@ �ե�# ����
	.equ	A6F, PWM_HZ / 1661		@ ��#   ���
	
	.equ	D7F, PWM_HZ / 2217	@ ���


	.equ	CM_BASE, 0x3f101000
	.equ	CM_PWMCTL, 0xa0
	.equ	CM_PWMDIV, 0xa4

	.equ	PWM_BASE, 0x3f20c000
	.equ	PWM_CTL, 0x0

	.equ	PWM_DAT2, 0x24
	.equ	PWM_RNG2, 0x20
	@ 0x8100 = 1000 0001 0000 0000  -> PWEN2, MSEN2 ��1 ��
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

