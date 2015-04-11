; drive detection
; based on DreamLoad sources by Ninja & DocBacardi


	.include "macro.i"
	.include "kernal.i"
	.include "drivetype.i"


	.export loader_detect


sendsecond	= $f3d5		; send secondary address
closecurr	= $f642		; close


	.bss

mlo:	.res 1
mhi:	.res 2


	.rodata

magic_family:
	.byte $43, $0d, $ff

magic_addr:
	.addr $fea4, $e5c6, $a6e9

magic_lo:
        .byte "4778fh"
magic_hi:
        .byte $b1, $b0, $b1, $b1, "dd"

str_mr:
        .byte "m-r"
str_mr_addr:
        .addr $fea0
str_mr_nbytes:
	.byte $01
str_mr_len = * - str_mr


	.code

loader_detect:
	ldax #$fea0		; read $fea0 to get drive family
	stax str_mr_addr
	lda #1
	sta str_mr_nbytes

	jsr sendcommand		; send M-R command
	bcs fail

	jsr getbyte		; get the byte
	;sta $0428
	pha
	jsr closecommand
	pla

	ldx #2			; compare magic bytes
:	cmp magic_family,x
	beq foundfamily
	dex
	bpl :-
	sec

fail:
	rts


foundfamily:
	;stx $0429

	txa
	asl
	tax

	lda magic_addr,x	; read family address to get model
	sta str_mr_addr
	lda magic_addr + 1,x
	sta str_mr_addr + 1
	lda #2
	sta str_mr_nbytes

	jsr sendcommand		; send M-R command
	bcs fail

	jsr getbyte		; get magic bytes
	sta mlo
	;sta $042a
	jsr getbyte
	;sta $042b
	sta mhi

	jsr closecommand

	ldx #6			; compare magic bytes
@compare:
	lda magic_lo - 1,x
	cmp mlo
	bne :+
	lda magic_hi - 1,x
	cmp mhi
	beq @found
:	dex
	bne @compare
@found:
	;stx $042c

	txa			; return model in A
	clc
	rts


sendcommand:
	lda #str_mr_len		; set name to M-R command string
	ldx #<str_mr
	ldy #>str_mr
	jsr SETNAM

	lda #$6f		; set secondary address
	sta $b9

	jsr sendsecond		; send command, carry set on fail
	rts


closecommand:
	jsr UNTLK
	jmp closecurr


getbyte:
	lda #0
	sta $90

	lda $ba
	jsr TALK
	lda #$6f
	jsr TKSA
	jmp ACPTR
