	.include "macro.i"
	.include "easyflash.i"


	.export startmenu
	.exportzp aptr
	.export get_crunched_byte

	.import __LOADER_LOAD__
	.import __LOADER_RUN__
	.import __LOADER_SIZE__

	.import lzmv_unpack


src	= $fb
aptr	= $2d

	.code

startmenu:
	lda #0
	sta $d020
	sta $d021

	.assert __LOADER_SIZE__ <= 255, error, "LOADER segment too big"
	ldx #<(__LOADER_SIZE__ - 1)
:	lda __LOADER_LOAD__,x
	sta __LOADER_RUN__,x
	dex
	cpx #$ff
	bne :-

	jmp unpack


	.segment "LOADER"

unpack:
	sei
	lda #$38
	sta $01

	ldax #cartmenu
	stax src
	ldax #$0801
	stax aptr
	jsr lzmv_unpack

	lda #$37
	sta $01
	lda #EF_KILL
	sta ef_control
	cli

	; RUN
	jsr $e453
	jsr $e3bf
	jsr $a533
	jsr $a659
	jmp $a7b1

get_crunched_byte:
	dec $01
	ldx #0
	lda (src,x)
	inc src
	bne :+
	inc src + 1
:	inc $01
	rts


	.rodata

cartmenu:
	.incbin "files/compressed/cartmenu_intro", 2
;cartmenu_pages = (>*) - (>cartmenu) + 1
