	.include "macro.i"


	.export irq_wait_vbl
	.export irq_delay
	.export irq_vbl_ctr

	.export irq_top
	.exportzp irq_top_line
	.export irq_logo_xpos_lo
	.export irq_logo_xpos_hi

	.export irq_swing_ctr


	.import screen
	.import sprptr
	.import screen2
	.import sprptr2

	.import genesis0
	.import genesis1
	.import genesis2
	.import genesis3
	.import genesis4

	.import is_pal


;	.import kbd_scan


screen_d018	= $a6
screen2_d018	= $b6


	.bss

irq_vbl_ctr:		.res 1
irq_swing_ctr:		.res 1
irq_logo_xpos_lo:	.res 1
irq_logo_xpos_hi:	.res 1


	.data

	.align 64

spr0xpos:
  .repeat 48, I
    .if I < 23
	.byte $e1 + I 
    .else
	.byte I - 23
    .endif
  .endrepeat

sprmsbtab:
	.res 23, %11000001
	.res 16, %11000000
	.res  9, %11100000


spryoffset = 44


	.data

logoflash:
	.res 27, 11
	.byte 8, 10, 7, 10, 8
	.res 27, 11
	.byte 5, 3, 13, 3, 5
	.res 27, 11
	.byte 4, 10, 7, 10, 4
	.res 27, 11
	.byte 6, 3, 14, 3, 6

	.code

 IRQ_DEFINE "irq_top", 30

	;inc $d020

	lda irq_logo_xpos_lo
	cmp #23
	bcs @nowrap
	ldx is_pal
	beq @pal
@ntsc:
	clc
	adc #$e9
	jmp @wrapped
@pal:
	clc
	adc #$e1
	jmp @wrapped
@nowrap:
	sec
	sbc #23
@wrapped:
	sta $d000

	ldx irq_logo_xpos_lo
;	lda spr0xpos,x
;	sta $d000
	lda sprmsbtab,x
	sta $d010
	txa
	clc
	adc #25
	sta $d002
	;clc
	adc #48
	sta $d004
	;clc
	adc #48
	sta $d006
	;clc
	adc #48
	sta $d008
	;clc
	adc #48
	sta $d00a
	clc
	adc #48
	sta $d00c
	clc
	adc #48
	sta $d00e

	ldx irq_logo_xpos_hi
	ldy #0
:	lda genesis0,x
	sta sprptr,y
	lda genesis1,x
	sta sprptr2,y
	inx
	iny
	cpy #8
	bne :-

	lda #spryoffset
	jsr setspry

	lda #$ff
	sta $d015

	lda irq_vbl_ctr
	and #$7f
	tax
	lda logoflash,x
	sta $d025

	lda #screen_d018
	sta $d018

	;dec $d020

 IRQ_NEXT "irq_spr1"


 IRQ_DEFINE "irq_spr1", spryoffset - 2 + 42

	lda #spryoffset + 42
	jsr setspry

	;inc $d021
	lda is_pal
	bne :+
:	bne :+
:
	lda #screen2_d018
	sta $d018
	
	ldy #7
:	lda sprptr2,y
	sta sprptr,y
	dey
	bpl :-
	
	lda #screen_d018
	sta $d018

	;dec $d021

	ldx irq_logo_xpos_hi
	ldy #0
:	lda genesis2,x
	sta sprptr2,y
	inx
	iny
	cpy #8
	bne :-

 IRQ_NEXT "irq_spr2"


 IRQ_DEFINE "irq_spr2", spryoffset - 2 + 42 * 2

	lda #spryoffset + 42 * 2
	jsr setspry

	;inc $d021
	lda is_pal
	bne :+
:	bne :+
:
	lda #screen2_d018
	sta $d018
	
	ldy #7
:	lda sprptr2,y
	sta sprptr,y
	dey
	bpl :-
	
	lda #screen_d018
	sta $d018

	;dec $d021

	ldx irq_logo_xpos_hi
	ldy #0
:	lda genesis3,x
	sta sprptr2,y
	inx
	iny
	cpy #8
	bne :-

 IRQ_NEXT "irq_fixchars"


 IRQ_DEFINE "irq_fixchars", spryoffset - 2 + 42 * 3 - 19

	;inc $d020

	ldx #39
:	lda screen + 15 * 40,x
	sta screen2 + 15 * 40,x
	dex
	bpl :-

	;dec $d020

 IRQ_NEXT "irq_spr3"


 IRQ_DEFINE "irq_spr3", spryoffset - 2 + 42 * 3

	lda #spryoffset + 42 * 3
	jsr setspry

	;inc $d021
	lda is_pal
	bne :+
:	bne :+
:
	lda #screen2_d018
	sta $d018
	
	ldy #7
:	lda sprptr2,y
	sta sprptr,y
	dey
	bpl :-
	
	lda #screen_d018
	sta $d018

	;dec $d021

	ldx irq_logo_xpos_hi
	ldy #0
:	lda genesis4,x
	sta sprptr2,y
	inx
	iny
	cpy #8
	bne :-

 IRQ_NEXT "irq_spr4"


 IRQ_DEFINE "irq_spr4", spryoffset - 2 + 42 * 4

	lda #spryoffset + 42 * 4
	jsr setspry

	;inc $d021
	lda is_pal
	bne :+
:	bne :+
:
	lda #screen2_d018
	sta $d018
	
	ldy #7
:	lda sprptr2,y
	sta sprptr,y
	dey
	bpl :-
	
	lda #screen_d018
	sta $d018

	inc irq_swing_ctr
	;dec $d021

 IRQ_NEXT "irq_border"


 IRQ_DEFINE "irq_border", 250

	lda #$13
	sta $d011

 IRQ_NEXT "irq_bottom"


 IRQ_DEFINE "irq_bottom", 255
	
	lda #0
	sta $d015
	lda #$1b
	sta $d011
	
	inc irq_vbl_ctr
	
;	jsr kbd_scan
	
 IRQ_NEXT "irq_top"


setspry:
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
	rts


irq_wait_vbl:
	pha
	lda irq_vbl_ctr
:	cmp irq_vbl_ctr
	beq :-
	pla
	rts


irq_delay:
	jsr irq_wait_vbl
	dex
	bne irq_delay
	rts
