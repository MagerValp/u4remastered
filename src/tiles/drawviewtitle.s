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


gettileaddr	= $6c9c


	.segment "DRAWVIEWTITLE"

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

	lda #<(screen + 13 * 40 + 1)
	sta charptr
	lda #>(screen + 13 * 40 + 1)
	sta charptr + 1

	lda #$48
	sta upperbmptr
	lda #$30
	sta upperbmptr + 1
	lda #$88
	sta lowerbmptr
	lda #$31
	sta lowerbmptr + 1
	
	lda #5
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
	cmp #19
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
	adc #$60
	sta upperbmptr
	lda upperbmptr + 1
	adc #$01
	sta upperbmptr + 1

	lda lowerbmptr
	clc
	adc #$60
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
