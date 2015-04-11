	.export lzmv_unpack


	.importzp aptr
	.import get_crunched_byte


dest	= aptr


	.segment "LOADER"

; unpack backpacked data
lzmv_unpack:
	jsr get_crunched_byte	; read command byte
	cmp #$00		; update flags
	bpl @literal_or_rle	; 1-7f means literal run

; back reference, length - 3 in bits 6..4, high nybble of offset in 3..0
	tax

	ora #$f0		; sign extend 2s complement offset
	sta @offset_msb

	txa
	and #$70
	lsr 			; save length + 3
	lsr
	lsr
	lsr
	adc #3
	sta @back_len

	jsr get_crunched_byte	; read offset low byte

	; add 2s complement offset to dest

	clc
	adc dest
	sta @backptr
	lda dest + 1
@offset_msb = * + 1
	adc #$5e
	sta @backptr + 1

@back_len = * + 1
	ldx #$5e
	ldy #0			; copy forwards to handle overlaps
@backptr = * + 1
:	lda $5e1f,y
	sta (dest),y
	iny
	dex
	bne :-
	sta @last_byte

	tya
	bne @incdest

; literal run, length - 1 in A with msb set
@literal_or_rle:
	beq @done		; 0 means eof
	cmp #$40
	bcs @rle

	sta @count

	ldy #0
@copy:
	jsr get_crunched_byte
	sta (dest),y
	iny
@count = * + 1
	cpy #$5e
	bne @copy
	sta @last_byte
	lda @count		; add length to dest pointer
@incdest:
	clc
	adc dest
	sta dest
	bcc lzmv_unpack
	inc dest + 1
	bne lzmv_unpack		; back to main loop

@rle:
	and #$3f
	tax
	inx
	inx
	tay
	iny
@last_byte = * + 1
	lda #$5e
:	sta (dest),y
	dey
	bpl :-
	txa
	bne @incdest

@done:
	rts
