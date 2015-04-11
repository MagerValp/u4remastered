	.include "uscii.i"


player_xpos		= $0010
player_ypos		= $0011
tile_xpos		= $0012
tile_ypos		= $0013
current_location	= $001a
game_mode		= $001b
temp2_x 		= $0076
temp2_y 		= $0077
delta_x 		= $0078
delta_y 		= $0079
temp_x			= $007a
temp_y			= $007b
ptr2			= $007c
ptr1			= $007e

j_waitkey		= $0800
j_clearkbd		= $a112
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198


	.segment "PEER"

peer_surface:
	jsr init_view
	lda #$00
	sta temp_x
	sta temp_y
next_tile:
	jsr get_map_ptr
	bpl @pattern_00
	jsr pattern_05
	jmp next_row

@pattern_00:
	tax
	ldy tilemap,x
	bne @pattern_01
	jsr pattern_00
	jmp next_row

@pattern_01:
	dey
	bne @pattern_02
	jsr pattern_01
	jmp next_row

@pattern_02:
	dey
	bne @pattern_03
	jsr pattern_02
	jmp next_row

@pattern_03:
	dey
	bne @pattern_04
	jsr pattern_03
	jmp next_row

@pattern_04:
	dey
	bne @pattern_05
	jsr pattern_04
	jmp next_row

@pattern_05:
	dey
	bne @pattern_06
	jsr pattern_05
	jmp next_row

@pattern_06:
	dey
	bne @pattern_07
	jsr pattern_06
	jmp next_row

@pattern_07:
	dey
	bne @pattern_08
	jsr pattern_07
	jmp next_row

@pattern_08:
	dey
	bne @pattern_09
	jsr pattern_08
	jmp next_row

@pattern_09:
	dey
	bne @pattern_0a
	jsr pattern_09
	jmp next_row

@pattern_0a:
	dey
	bne @pattern_0b
	jsr pattern_0a
	jmp next_row

@pattern_0b:
	dey
	bne @pattern_0c
	jsr pattern_0b
	jmp next_row

@pattern_0c:
	dey
	bne next_row
	jsr pattern_0c
	jmp next_row

next_row:
	inc temp_y
	lda temp_y
	cmp #$20
	bcs @column_done
	jmp next_tile

@column_done:
	lda #$00
	sta temp_y
	inc temp_x
	lda temp_x
	cmp #$20
	bcs @done
	jmp next_tile

@done:
	lda current_location
	beq @britannia
	lda player_xpos
	sta temp_x
	lda player_ypos
	sta temp_y
	jmp @waitkey

@britannia:
	lda tile_xpos
	sta temp_x
	lda tile_ypos
	sta temp_y
@waitkey:
	jsr flash_location
	lda $c6
	beq @waitkey
	lda $0277
	jsr exit_view
	rts

clear_view:
	lda #$40
	sta ptr1
	lda #$21
	sta ptr1+1
	ldx #$01
@next_bitmap_row:
	lda #$00
	ldy #$08
@clear_bitmap:
	sta (ptr1),y
	iny
	cpy #$b8
	bne @clear_bitmap
	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1+1
	adc #$01
	sta ptr1+1
	inx
	cpx #$17
	bne @next_bitmap_row
	ldx #$01
@next_char_row:
	lda chrlineaddr_lo,x
	sta ptr1
	lda chrlineaddr_hi,x
	sta ptr1+1
	ldy #$01
	lda clear_color
@clear_char:
	sta (ptr1),y
	iny
	cpy #$17
	bne @clear_char
	inx
	cpx #$17
	bne @next_char_row
	rts

get_map_ptr:
	lda current_location
	beq @britannia
	lda temp_y
	sta ptr2+1
	lda #$00
	lsr ptr2+1
	ror a
	lsr ptr2+1
	ror a
	lsr ptr2+1
	ror a
	adc temp_x
	sta ptr2
	clc
	lda ptr2+1
	adc #$e8
	sta ptr2+1
	ldy #$00
	lda (ptr2),y
	rts

@britannia:
	lda temp_y
	asl a
	asl a
	asl a
	asl a
	sta ptr2
	lda temp_x
	and #$0f
	ora ptr2
	sta ptr2
	lda temp_y
	and #$10
	asl a
	ora temp_x
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc #$e8
	sta ptr2+1
	ldy #$00
	lda (ptr2),y
	rts

pattern_00:
	rts

pattern_01:
	lda #$10
	jsr set_bit
	lda #$31
	jsr set_bit
	lda #$12
	jsr set_bit
	lda #$33
	jsr set_bit
	rts

pattern_02:
	jsr pattern_01
	lda #$30
	jsr set_bit
	lda #$11
	jsr set_bit
	lda #$32
	jsr set_bit
	lda #$13
	jsr set_bit
	rts

pattern_03:
	lda #$00
	jsr set_bit
	lda #$01
	jsr set_bit
	lda #$02
	jsr set_bit
	lda #$03
	jsr set_bit
	lda #$20
	jsr set_bit
	lda #$21
	jsr set_bit
	lda #$22
	jsr set_bit
	lda #$23
	jsr set_bit
	rts

pattern_04:
	lda #$00
	jsr set_bit
	lda #$10
	jsr set_bit
	lda #$20
	jsr set_bit
	lda #$30
	jsr set_bit
	lda #$03
	jsr set_bit
	lda #$13
	jsr set_bit
	lda #$23
	jsr set_bit
	lda #$33
	jsr set_bit
	rts

pattern_05:
	lda #$11
	jsr set_bit
	lda #$12
	jsr set_bit
	lda #$21
	jsr set_bit
	lda #$22
	jsr set_bit
	rts

pattern_06:
	jsr pattern_04
	lda #$01
	jsr set_bit
	lda #$02
	jsr set_bit
	lda #$31
	jsr set_bit
	lda #$32
	jsr set_bit
	rts

pattern_07:
	jsr pattern_05
	jsr pattern_06
	rts

pattern_08:
	lda #$00
	jsr set_bit
	lda #$01
	jsr set_bit
	lda #$10
	jsr set_bit
	lda #$11
	jsr set_bit
	lda #$22
	jsr set_bit
	lda #$23
	jsr set_bit
	lda #$32
	jsr set_bit
	lda #$33
	jsr set_bit
	rts

pattern_09:
	lda #$10
	jsr set_bit
	lda #$11
	jsr set_bit
	lda #$12
	jsr set_bit
	lda #$30
	jsr set_bit
	lda #$32
	jsr set_bit
	lda #$33
	jsr set_bit
	rts

pattern_0a:
	lda #$00
	jsr set_bit
	lda #$02
	jsr set_bit
	lda #$21
	jsr set_bit
	lda #$23
	jsr set_bit
	rts

pattern_0b:
	lda #$00
	jsr set_bit
	lda #$22
	jsr set_bit
	rts

pattern_0c:
	lda temp_x
	lsr a
	bcc @alternate
	lda #$22
	jsr set_bit
	rts

@alternate:
	lda #$20
	jsr set_bit
	rts

set_bit:
	pha
	and #$0f
	sta delta_y
	pla
	lsr a
	lsr a
	lsr a
	lsr a
	sta delta_x
	lda temp_x
	asl a
	asl a
	adc delta_x
	sta temp2_x
	lda temp_y
	asl a
	asl a
	adc delta_y
	sta temp2_y
	ldy temp2_y
	lda bmplineaddr_lo+30,y
	sta ptr1
	lda bmplineaddr_hi+30,y
	sta ptr1+1
	lda temp2_x
	clc
	adc #$1f
	and #$f8
	tay
	lda temp2_x
	clc
	adc #$1f
	and #$07
	tax
	lda bitmask,x
	ora (ptr1),y
	sta (ptr1),y
	rts

bitmask:
	.byte $80, $40, $20, $10, $08, $04, $02, $01

flash_location:
	lda game_mode
	bne @flash
	rts

@flash:
	lda #$00
	jsr @invert_bit
	lda #$01
	jsr @invert_bit
	lda #$02
	jsr @invert_bit
	lda #$03
	jsr @invert_bit
	lda #$10
	jsr @invert_bit
	lda #$11
	jsr @invert_bit
	lda #$12
	jsr @invert_bit
	lda #$13
	jsr @invert_bit
	lda #$20
	jsr @invert_bit
	lda #$21
	jsr @invert_bit
	lda #$22
	jsr @invert_bit
	lda #$23
	jsr @invert_bit
	lda #$30
	jsr @invert_bit
	lda #$31
	jsr @invert_bit
	lda #$32
	jsr @invert_bit
	lda #$33
	jsr @invert_bit
	rts

@invert_bit:
	pha
	and #$0f
	sta delta_y
	pla
	lsr a
	lsr a
	lsr a
	lsr a
	sta delta_x
	lda temp_x
	asl a
	asl a
	adc delta_x
	sta temp2_x
	lda temp_y
	asl a
	asl a
	adc delta_y
	sta temp2_y
	ldy temp2_y
	lda bmplineaddr_lo+30,y
	sta ptr1
	lda bmplineaddr_hi+30,y
	sta ptr1+1
	lda temp2_x
	clc
	adc #$1f
	and #$f8
	tay
	lda temp2_x
	clc
	adc #$1f
	and #$07
	tax
	lda bitmask,x
	eor (ptr1),y
	sta (ptr1),y
	rts


tilemap:
	.byte $c, $b, $a, $1, $1, $9, $2, $8
	.byte $7, $5, $5, $5, $5, $4, $4, $4
	.byte $5, $5, $5, $5, $5, $5, $5, $4
	.byte $5, $4, $4, $5, $5, $6, $6, $5
	.byte $6, $6, $6, $6, $6, $6, $6, $6
	.byte $6, $6, $6, $6, $6, $6, $6, $6
	.byte $7, $7, $7, $7, $7, $7, $7, $5
	.byte $5, $7, $6, $6, $5,  0, $3, $4
	.byte $3, $3, $3, $3, $3, $3, $3, $3
	.byte $3, $7, $3, $3, $3, $3, $3, $3
	.byte $5, $5, $5, $5, $5, $5, $5, $5
	.byte $5, $5, $5, $5, $5, $5, $5, $5
	.byte $4, $4, $4, $4, $4, $4, $4, $4
	.byte $4, $4, $4, $4, $4, $4, $4, $4
	.byte $4, $4, $4, $4, $4, $4, $4, $4
	.byte $4, $4, $4, $4, $4, $6,  0, $7


init_view:
	ldx #0
	lda #6
@clear:
	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne @clear

	lda #<$d828
	sta ptr1
	lda #>$d828
	sta ptr1 + 1
	ldx #22
@nextrow:
	ldy #22
	lda #1
:	sta (ptr1),y
	dey
	bne :-
	dex
	beq @done
	lda ptr1
	clc
	adc #40
	sta ptr1
	bcc @nextrow
	inc ptr1 + 1
	bne @nextrow

@done:
	lda #$d8
	sta $d016
	lda #$e5
	sta clear_color
	jmp clear_view


exit_view:
	lda #$10
	sta clear_color
	jsr clear_view
	lda #$c8
	sta $d016
	jmp j_clearkbd


clear_color:	.byte 0
