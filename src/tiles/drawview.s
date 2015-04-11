	.import tilecolors0
	.import tilecolors1
	.import tilecolors2
	.import tilecolors3


charptr		= $58
column		= $72
upperbmptr	= $7c
uppertileptr	= $7e
lowerbmptr	= $80
lowertileptr	= $82

fastrand	= $15f5

bmplineaddr_lo	= $e000
bmplineaddr_hi	= $e0c0

currmap		= $ae00

screen		= $0400


	.segment "DRAWVIEW"

drawview:
	lda uppertileptr
	pha
	lda uppertileptr + 1
	pha
	lda upperbmptr
	pha
	lda upperbmptr + 1
	pha
	lda charptr
	pha
	lda charptr + 1
	pha

	lda #$00
	sta @mapptr

	lda #<(screen + 41)
	sta charptr
	lda #>(screen + 41)
	sta charptr + 1

	lda #$48
	sta upperbmptr
	lda #$21
	sta upperbmptr + 1
	lda #$88
	sta lowerbmptr
	lda #$22
	sta lowerbmptr + 1
	
	lda #11
	sta row
@nextline:
	lda #0
	sta column
@nexttile:
@mapptr = * + 1
	ldy currmap
	jsr gettileaddr
	eor #$70
	sta lowertileptr + 1
	lda uppertileptr
	sta lowertileptr

	tya
	tax

	lda column
	asl
	tay
	lda tilecolors0,x
	sta (charptr),y

	iny
	lda tilecolors1,x
	sta (charptr),y

	tya
	clc
	adc #$27
	tay
	lda tilecolors2,x
	sta (charptr),y

	iny
	lda tilecolors3,x
	sta (charptr),y

	ldy #15
@draw:
	lda (uppertileptr),y
	sta (upperbmptr),y
	lda (lowertileptr),y
	sta (lowerbmptr),y
	dey
	lda (uppertileptr),y
	sta (upperbmptr),y
	lda (lowertileptr),y
	sta (lowerbmptr),y
	dey
	bpl @draw

	inc @mapptr

	inc column
	lda column
	cmp #11
	beq @eol

	lda upperbmptr
	clc
	adc #$10
	sta upperbmptr
	bcc :+
	inc upperbmptr + 1
:
	lda lowerbmptr
	clc
	adc #$10
	sta lowerbmptr
	bcc :+
	inc lowerbmptr + 1
:
	jmp @nexttile
@eol:
	lda charptr
	clc
	adc #$50
	sta charptr
	bcc :+
	inc charptr + 1
:
	lda upperbmptr
	clc
	adc #$e0
	sta upperbmptr
	lda upperbmptr + 1
	adc #$01
	sta upperbmptr + 1

	lda lowerbmptr
	clc
	adc #$e0
	sta lowerbmptr
	lda lowerbmptr + 1
	adc #$01
	sta lowerbmptr + 1

	dec row
	beq @done
	jmp @nextline

@done:
	pla
	sta charptr + 1
	pla
	sta charptr
	pla
	sta upperbmptr + 1
	pla
	sta upperbmptr
	pla
	sta uppertileptr + 1
	pla
	sta uppertileptr
	rts
	rts

row:
	.res 1


	.segment "GETTILEADDR"

gettileaddr:
	lda #0
	sta uppertileptr + 1
	tya
	asl
	rol uppertileptr + 1
	asl
	rol uppertileptr + 1
	asl
	rol uppertileptr + 1
	asl
	rol uppertileptr + 1
	sta uppertileptr
	lda #$b0
	clc
	adc uppertileptr + 1
	sta uppertileptr + 1
	rts


	.segment "FILLRAND"

fillrand:
	ldy #$3f
@fill:
	jsr fastrand
	and #$55
	sta (uppertileptr),y
	dey
	bpl @fill
	rts


	.segment "ANIMATEFLAGS"

animate_flags:
	jsr fastrand
	bmi @castle
	ldx $c0a0
	ldy $c0a1
	sty $c0a0
	stx $c0a1
@castle:
	jsr fastrand
	bmi @lbcastle
	ldx $b0b2
	ldy $b0b3
	sty $b0b2
	stx $b0b3
@lbcastle:
	jsr fastrand
	bmi @shipwest
	ldx $b0e2
	ldy $b0e3
	sty $b0e2
	stx $b0e3
@shipwest:
	jsr fastrand
	bmi @shipeast
	ldx $b101
	ldy $b102
	sty $b101
	stx $b102
	ldx $b109
	ldy $b10a
	sty $b109
	stx $b10a
@shipeast:
	jsr fastrand
	bmi @flagsdone
	ldx $b121
	ldy $b122
	sty $b121
	stx $b122
	ldx $b129
	ldy $b12a
	sty $b129
	stx $b12a
@flagsdone:
	rts
