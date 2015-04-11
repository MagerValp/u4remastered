	.include "easyflash.i"


	.export _starteditor


	.import __COPYEDITOR_LOAD__
	.import __COPYEDITOR_RUN__
	.import __COPYEDITOR_SIZE__
	.import __EDITOR_LOAD__

	.importzp editor_pages


	.code

_starteditor:
	sei
	.assert __COPYEDITOR_SIZE__ <= 128, error, "copyeditor too big"
	ldx #<__COPYEDITOR_SIZE__ - 1
:	lda __COPYEDITOR_LOAD__,x
	sta __COPYEDITOR_RUN__,x
	dex
	bpl :-
	jmp copyeditor


	.segment "COPYEDITOR"

copyeditor:
	lda #1
	sta ef_bank
	ldx #0
	ldy #editor_pages
@copy:
@src_ptr = * + 1
	lda __EDITOR_LOAD__,x
@dest_ptr = * + 1
	sta $0800,x
	inx
	bne @copy

	dey
	beq @done

	inc @dest_ptr + 1

	inc @src_ptr + 1
	bne @copy
@done:
;	lda #EF_KILL
;	sta ef_control
	cli
	jmp $080d
