; load A/X
 .macro ldax arg
	.if (.match (.left (1, {arg}), #))	; immediate mode
	lda #<(.right (.tcount ({arg})-1, {arg}))
	ldx #>(.right (.tcount ({arg})-1, {arg}))
	.else					; assume absolute or zero page
	lda arg
	ldx 1+(arg)
	.endif
 .endmacro

; store A/X
 .macro stax arg
	sta arg
	stx 1+(arg)
 .endmacro	

; convert ascii to screencodes
 .macro screencode str
	.repeat .strlen(str), I
		.if ((.strat(str, I) & $e0) = $20)
			.byte .strat(str, I) & $3f
		.endif
		.if ((.strat(str, I) & $e0) = $40)
			.byte .strat(str, I) & $1f
		.endif
		.if ((.strat(str, I) & $e0) = $c0)
			.byte .strat(str, I) & $7f
		.endif
	.endrepeat
 .endmacro


; define chained raster IRQ handlers
 .macro IRQ_DEFINE name, line
	
	.ident(.concat(name, "_line")) = line
	.ident(name):
	
	sta @savea
	stx @savex
	sty @savey

	lda $01		; 3
	pha		; 3
	lda #$35	; 2
	sta $01		; 3
	
 .endmacro
	
 .macro IRQ_EXIT
	
	inc $d019

	pla
	sta $01
	
@savey = * + 1
	ldy #$5e
@savex = * + 1
	ldx #$5e
@savea = * + 1
	lda #$5e
	rti
	
 .endmacro

 .macro IRQ_NEXT next
	
	ldax #.ident(next)
	stax $fffe
	lda #(.ident(.concat(next, "_line")))
	sta $d012
	;lda $d011
	;and #$7f
	;sta $d011
	
	IRQ_EXIT
	
 .endmacro

 .macro IRQ_STABILIZE
	
	lda #8			; 2
	sec			; 2
	sbc $dc04		; 4
	;lda $dc04		; 4
	;; A contains 1-7
	;eor #7			; 2
	sta * + 4		; 4
	bpl *			; 2
	cmp #$c9		; 2
        cmp #$c9		; 2
        bit $ea24		; 3

 .endmacro
