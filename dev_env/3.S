;;
;; H8 beginer's guide p.35 fig.3.4
;; Feb 19, 2002
;;
#define	LED1	#0,@P5DR:8
#define	LED2	#1,@P5DR:8

	.h8300h
	.text
	.equ	P4DR,0xffffc7
	.equ	P5DR,0xffffca	
	.global _start

;; initialize rutine
_start:	mov.l	#0xfff10,er7	; スタックポインタ設定
	mov.b	#0x00,r0l
	mov.b	r0l,@0xffffc5
	mov.b	#0xff,r0l
	mov.b	r0l,@0xffffda
	mov.b	#0xff,r0l
	mov.b	r0l,@0xffffc8

;; main routine
sw1led:	mov.b	@P4DR,r0l
	btst	#4,r0l
	beq	botan1		; if (btst) goto botan1
	bclr	LED1
	jmp	@sw2led
botan1:	bset	LED1
sw2led:	btst	#5,r0l		; bit test
	beq	botan2
	bclr	LED2		; bit clear
	jmp	@sw1led		; jump
botan2:	bset	LED2
	jmp	@sw1led
	.end
