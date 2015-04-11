	.include "uscii.i"


	.ifdef DEBUG

DEBUGREADSECTOR = 1
DEBUGFILE = 1


;	.pushseg
;	.segment "DEBUGA800"


j_primm_xy	= $081e
j_primm		= $0821
j_console_out	= $0824

	.ifdef DEBUGREADSECTOR

	.warning "DEBUGREADSECTOR enabled"

debugreadsector:
	jsr j_primm
	.byte "T:", 0
	lda track
	jsr printhex
	jsr j_primm
	.byte " S:", 0
	lda sector
	jsr printhex
	jsr j_primm
	.byte " D:", 0
	lda currdisk
	jsr printdigit

	; fall through

	.endif


	.ifdef DEBUGFILE

	.warning "DEBUGFILE enabled"

	jmp dbgdoneprint

debugfile:
	lda currdisk
	cmp #1
	bne :+
	lda jobcode
	rts
:
	lda jobcode
	cmp #$cc
	beq @printload
	cmp #$d2
	beq @printexec

@printsave:
	jsr j_primm
	.byte "SAVE ", 0
	jmp @fnum
@printload:
	jsr j_primm
	.byte "LOAD ", 0
	jmp @fnum
@printexec:
	jsr j_primm
	.byte "EXEC ", 0

@fnum:
	lda currdisk
	jsr printdigit
	lda filenum
	jsr printhex

	.if 0

	jsr j_primm
	.byte " ADDR ", 0

	lda filenum
	cmp #$40
	bcs @long
@short:
	tay

	lda t_fileaddr_hi,y
	jsr printhex
	lda t_fileaddr_lo,y
	jsr printhex

	lda #'-'
	jsr putc

	lda t_filelen_short,y
	sec
	sbc #1
	clc
	adc t_fileaddr_lo,y
	pha
	lda t_fileaddr_hi,y
	adc #0
	jsr printhex
	pla
	jsr printhex

	jmp dbgdoneprint
@long:
	sec
	sbc #$40
	tay

	lda t_fileaddr_long,y
	pha
	jsr printhex
	lda #$00
	jsr printhex

	lda #'-'
	jsr putc

	pla
	sec
	sbc #1
	clc
	adc t_filelen_long,y
	jsr printhex
	lda #$ff
	jsr printhex

	.endif

	.endif

	.warning "DEBUG enabled"

dbgdoneprint:
	lda #$8d
	jsr putc

;	lda #0
;	sta $c6
;
;@waitspace:
;	lda $c6
;	beq @waitspace
;
;	lda #0
;	sta $c6

	.ifdef DEBUGFILE
	ldy ysave
	ldx filenum
	lda jobcode
	.endif

	rts


printhex:
	pha
	lsr
	lsr
	lsr
	lsr
	jsr printdigit
	pla
	and #$0f
printdigit:
	ora #$30
	cmp #$3a
	bcc :+
	adc #6
:	jmp putc


putc = j_console_out

;	.popseg

	.endif
