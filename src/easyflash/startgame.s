	.include "easyflash.i"


	.export _startgame


	.import game_run
	.importzp game_pages

	.import __COPYGAME_LOAD__
	.import __COPYGAME_RUN__
	.import __COPYGAME_SIZE__


	.code

_startgame:
	lda #6
	ldx #0
:	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne :-


	sei
	.assert __COPYGAME_SIZE__ <= 128, error, "copygame too big"
	ldx #<__COPYGAME_SIZE__ - 1
:	lda __COPYGAME_LOAD__,x
	sta __COPYGAME_RUN__,x
	dex
	bpl :-
	jmp copygame


	.segment "COPYGAME"

copygame:
	lda #2
	sta ef_bank
	ldx #0
	ldy #game_pages
@copy:
@src_ptr = * + 1
	lda $8000,x
	inc $01
@dest_ptr = * + 1
	sta game_run,x
	dec $01
	inx
	bne @copy

	dey
	beq @done

	inc @dest_ptr + 1

	inc @src_ptr + 1
	lda @src_ptr + 1
	cmp #$c0
	bne @copy

	lda #$80
	sta @src_ptr + 1
	inc bank_counter
	lda bank_counter
	sta ef_bank
	bne @copy
@done:
	lda #EF_KILL
	sta ef_control
	cli
	jmp $2000

bank_counter:
	.byte 2
