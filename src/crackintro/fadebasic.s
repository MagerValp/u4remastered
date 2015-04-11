	.include "macro.i"


	.export fadebasic


	.import is_pal

	.import music_init
	.import main

	.import screen


pal_cycles	= 19655
ntsc_cycles	= 20403


	.code

fadebasic:	
	lda #0
	tax
	tay
	jsr music_init

	lda #$ff
:	cmp $d012
	bne :-

	ldx #>pal_cycles
	ldy #<pal_cycles
	lda is_pal
	beq :+
	ldx #>ntsc_cycles
	ldy #>ntsc_cycles
:
	sty $dd04
	stx $dd05

	lda #$ff
	sta $dd06
	sta $dd07

	lda #%01000001
	sta $dd0f

	lda #$80
	ldx is_pal
	beq :+
	lda #$00
:
	ora #%00000001
	sta $dd0e

	lda #%01000001
	sta $dd0f


:	bit $d011
	bpl :-
	lda #$1b
	sta $d011
	
	ldx #0
	stx $d010
	stx $d015
	stx $d017
	stx $d01a
	stx $d01b
	stx $d01c
	stx $d01d
	;stx $bfff
	stx $d020
	stx $d021

	.assert * = main, error, "main must be linked immediately after fadebasic"
	;jmp main
