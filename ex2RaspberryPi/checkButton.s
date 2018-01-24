	.include "common.h"
	.section .text
	.global checkButton
	@ r12: �����λ���Υ����å�����
checkButton:
	str	r14, [sp, #-4]!		@ push r14
	str	r3, [sp, #-4]!		@ push r3
	str	r2, [sp, #-4]!		@ push r2
	str	r1, [sp, #-4]!		@ push r1

	ldr	r0, =GPIO_BASE		@ GPIO �����Ѥ�����
	@ GPIO #5 (SW3) �ؤ����Ϥ򸡾� (�֤Υܥ���)
	ldr 	r2, [r0, #(GPLEV0 + SW3_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW3_PORT % 32)
	ands	r1, r2, #0x1
	mov	r3, r1, lsl #1	
	@ GPIO #6 (SW4) �ؤ����Ϥ򸡾� (�ĤΥܥ���)
	ldr 	r2, [r0, #(GPLEV0 + SW4_PORT / 32 * 4)]
	mov	r2, r2, lsr #(SW4_PORT % 32)
	ands	r1, r2, #0x1
	add	r3, r3, r1
	
	mvn	r0, r12			@ not��Ȥ�
	and	r0, r0, r3		@ ɬ�פʥ����å����ּ���
	mov	r12, r3			@ �����å����֤ι���
	
	ldr	r1, [sp], #4		@ pop r1
	ldr	r2, [sp], #4		@ pop r2
	ldr	r3, [sp], #4		@ pop r3
	ldr	r14, [sp], #4		@ pop r14
	bx	r14
