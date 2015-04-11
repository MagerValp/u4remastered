	.include "kernal.i"
	.include "trainer.i"


	.export trainer


screen		= $e800
colors		= $d800
cursor		= colors + $ca


	.bss

line:	.res 1


	.code

trainer:
	lda #$0b
	sta $d011

	ldx #0
	stx $d020
	stx $d021
:	lda trainercolors,x
	sta $d800,x
	lda trainercolors + $100,x
	sta $d900,x
	lda trainercolors + $200,x
	sta $da00,x
	lda trainercolors + $300,x
	sta $db00,x
	inx
	bne :-

	lda #0
	sta $dd00
	lda #$a7
	sta $d018

	lda #255
:	cmp $d012
	bne :-

	lda #$1b
	sta $d011

	lda #0
	sta line
	sta $c6

	ldx #7
	lda #0
:	sta select,x
	dex
	bpl :-

	bmi waitkey

all:
	ldx #7
	lda #$ff
:	sta select,x
	dex
	bpl :-
done:
	lda #255
:	cmp $d012
	bne :-
	lda #3
	sta $dd00
	lda #$15
	sta $d018
	rts

waitkey:
	jsr GETIN
	beq waitkey

	cmp #$41
	beq all

	cmp #$11
	beq @down
	cmp #$91
	beq @up

	cmp #$0d
	beq @return
	cmp #$20
	beq @return

	cmp #$4e
	beq @no
	cmp #$59
	beq @yes

	cmp #$13
	beq @home

	bne waitkey


@return:
	ldx line
	beq done
@toggle:
	dex
	lda select,x
	eor #$ff
	bne @yes

@no:
	ldx line
	dex
	bmi waitkey
	lda #0
	sta select,x
	jsr noline
	jmp waitkey

@yes:
	ldx line
	dex
	bmi waitkey
	lda #$ff
	sta select,x
	jsr yesline
	jmp waitkey

@up:
	lda line
	beq waitkey

	jsr deselectline

	jsr deccolorptr
	dec line
	bne :+
	jsr deccolorptr
:
	jsr selectline

	jmp waitkey

@down:
	lda line
	cmp #ntrainers
	bcc :+
	jmp waitkey
:
	jsr deselectline

	lda line
	bne :+
	jsr inccolorptr
:
	inc line
	jsr inccolorptr

	jsr selectline

	jmp waitkey


@home:
	lda line
	beq @homedone

	jsr deselectline
	inc line
:	jsr deccolorptr
	dec line
	bne :-

	jsr selectline
@homedone:
	jmp waitkey


yesline:
	ldx #21
	lda #15
:	jsr setcolor
	inx
	cpx #24
	bne :-
	lda #11
:	jsr setcolor
	inx
	cpx #28
	bne :-
	rts

noline:
	ldx #21
	lda #11
:	jsr setcolor
	inx
	cpx #24
	bne :-
	lda #15
:	jsr setcolor
	inx
	cpx #28
	bne :-
	rts


selectline:
	ldx #18
	lda #1
:	jsr setcolor
	dex
	bpl :-
	rts

deselectline:
	ldx #18
	lda #15
:	jsr setcolor
	dex
	bne :-
	lda #11
	jmp setcolor


inccolorptr:
	lda colorptr
	clc
	adc #40
	sta colorptr
	bcc :+
	inc colorptr + 1
:	rts

deccolorptr:
	lda colorptr
	sec
	sbc #40
	sta colorptr
	bcs :+
	dec colorptr + 1
:	rts

setcolor:
colorptr = * + 1
	sta cursor,x
	rts


	.macro trainerrow
	.res 4, 11
	.res 19, 15
	.res 4, 11
	.res 2, 15
	.res 11, 1
	.endmacro

trainercolors:
;	.incbin "trainercolors.bin"

	.res 120, 3
	.res 80, 2
	.res 80, 1
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	trainerrow
	.res 120, 3
	.res 80, 2
	.res 120, 15

	.segment "TRAINERFONT"
	.incbin "u4font.prg", 2
	
	.segment "TRAINERSCREEN"
	.incbin "trainerscreen.prg", 2
