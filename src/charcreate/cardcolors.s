	.include "macro.i"


	.export drawcard_d800


	.segment "CARDCOLORS"

card_colors = * + $480

	.incbin "files/patched/19f.prg", 2


card_x		= $40
card_y		= $41
color_ptr	= $42

card_num	= $6bce


drawcard_d800:
	lda card_x
	clc
	adc #80
	sta color_ptr
	lda #$d8
	sta color_ptr + 1

	lda #14
	sta card_y

	lda card_num
	asl
	asl
	asl
	asl
	clc
	adc #<card_colors
	sta @card_ptr
	lda #>card_colors
	adc #0
	sta @card_ptr + 1
@nextline:
@card_ptr = * + 1
	lda $5e1f
	ldy #9
@setcolor:
	sta (color_ptr),y
	dey
	bpl @setcolor

	dec card_y
	beq @done

	inc @card_ptr

	lda color_ptr
	clc
	adc #40
	sta color_ptr
	bcc @nextline
	inc color_ptr + 1
	bne @nextline
@done:
	lda #$10
	sta card_y
	lda card_num
	rts
