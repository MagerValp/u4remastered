	.include "macro.i"
	.include "easyflash.i"


	.export cartridge_start

	.import startmenu


	.segment "STARTUP"

cartridge_start:
	lda #$37
	sta $01
	lda #$2f
	sta $00

	ldx #0
	stx $d016
	jsr $ff84		; Init I/O Devices, Ports & Timers.

	ldx #0
	txa
:	sta a:$0002,x
	sta $0200,x
	sta $0300,x
	inx
	bne :-

	ldy #$a0
	;ldx #$00
	jsr $fd8c

	jsr $ff8a		; Restore Vectors.
	jsr $ff81		; Init Editor & Video Chips.
	cli

	jmp startmenu
