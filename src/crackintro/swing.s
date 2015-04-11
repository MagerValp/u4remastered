	.include "macro.i"


	.export swing_init
	.export swing


	.import irq_logo_xpos_lo
	.import irq_logo_xpos_hi

	.import testsinus
	.import testsinus_end


	.zeropage

sinusptr:	.res 2


	.data

swingctr:	.byte 0

	.code


swing_init:
	ldax #(testsinus_end + testsinus) / 2
	stax sinusptr
	;jsr swing

swing:
	ldy #0
	lda (sinusptr),y
	sta div48inout
	iny
	lda (sinusptr),y
	sta div48inout + 1
	jsr div48

	lda #47
	sec
	sbc div48mod
	sta irq_logo_xpos_lo
	
	lda div48inout
	sta irq_logo_xpos_hi

	lda sinusptr
	clc
	adc #2
	sta sinusptr
	bcc :+
	inc sinusptr + 1
:
	cmp #<testsinus_end
	bne @done
	lda sinusptr + 1
	cmp #>testsinus_end
	bne @done
	ldax #testsinus
	stax sinusptr
@done:
	rts


div48:
	lda #0
	sta div48mod
	sta div48mod + 1
	ldx #16
@loop:
	asl div48inout
	rol div48inout + 1	
	rol div48mod
	rol div48mod + 1
	lda div48mod
	sec
	sbc #48
	tay
	lda div48mod + 1
	sbc #0
	bcc :+
	sta div48mod + 1
	sty div48mod
	inc div48inout
:
	dex
	bne @loop
	rts


	.bss

div48inout:	.res 2
div48mod:	.res 2
