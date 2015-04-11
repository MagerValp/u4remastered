	.include "macro.i"


	.export main


	.import irq_top
	.importzp irq_top_line
	.import irq_vbl_ctr
	.import irq_swing_ctr

	.import screen
	.import sprptr

	.import swing_init
	.import swing

	.import text_init
	.import text_update

	.import music_play


	.bss

last_vbl:	.res 1
last_swing:	.res 1
last_music:	.res 1

cia_music_ctr	= $dd06


	.code

main:
	jsr swing_init
	jsr text_init

	lda #1
	sta $dd00

	ldx #$ff
	stx $d017
	stx $d01b
	stx $d01c
	stx $d01d

	lda #11
	sta $d025
	lda #10
	sta $d026

	ldx #7
	txa
:	sta $d027,x
	dex
	bpl :-

	lda irq_vbl_ctr
	sta last_vbl
	lda irq_swing_ctr
	sta last_swing
	lda cia_music_ctr
	sta last_music

	lda #irq_top_line
	sta $d012
	lda #$1b
	sta $d011
	ldax #irq_top
	stax $fffe

	lda #1
	sta $d019
	sta $d01a

@main:
@xpos = * + 1
	lda last_vbl
	cmp irq_vbl_ctr
	beq :+
	inc last_vbl
	jsr vbl
:
	lda last_swing
	cmp irq_swing_ctr
	beq :+
	inc last_swing
	jsr swing
:
	lda last_swing
	cmp irq_swing_ctr
	beq :+
	inc last_swing
	jsr swing
:
	lda last_music
	cmp cia_music_ctr
	beq :+
	lda cia_music_ctr
	sta last_music
	jsr music_play
:
	jmp @main


vbl:
	jsr text_update

	lda $dc01
	and #$10
	beq @exit
	rts
@exit:
	lda #0
	sta $d01a
	sta $d015
	sta $d418
	tax
:	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne :-
	lda #3
	sta $dd00
	lda #$15
	sta $d018
	lda #$1b
	sta $d011

	lda #$37
	sta $01
	jsr $fda3
	jmp $080d
