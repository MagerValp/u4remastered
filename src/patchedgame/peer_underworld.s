	.include "uscii.i"


player_xpos		= $0010
player_ypos		= $0011
dungeon_level		= $001c
console_xpos		= $004e
console_ypos		= $004f
ptr2			= $007c
ptr1			= $007e

kbd_buf_count		= $00c6
kbd_buffer		= $0277

j_console_out		= $0824
j_clearview		= $0875

j_clearkbd		= $a112

draw_stack 		= $ae00

chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198


	.segment "PEER"

peer_dungeon:
	lda console_xpos
	sta saved_console_xpos
	lda console_ypos
	sta saved_console_ypos
	jsr j_clearview
	jsr clear_color
	ldx #$00
	txa
@clear_buffer:
	sta buffer,x
	sta buffer+256,x
	inx
	bne @clear_buffer
	lda #$00
	sta stack_ctr
	lda player_xpos
	sta current_x
	lda player_ypos
	sta current_y
	lda #$0b
	sta console_xpos
	sta console_ypos
	lda #$2a
	jsr j_console_out
	dec console_xpos
@draw:
	lda #$ff
	sta dx
	sta dy
@next:
	lda dx
	bne @print
	lda dy
	beq @skip
@print:
	clc
	lda current_x
	adc dx
	and #$07
	sta dungeon_x
	clc
	lda current_y
	adc dy
	and #$07
	sta dungeon_y
	jsr get_dungeon_tile
	jsr draw_tile_and_neighbors
@skip:
	inc dx
	lda dx
	cmp #$02
	bcc @next
	lda #$ff
	sta dx
	inc dy
	lda dy
	cmp #$02
	bcc @next
	lda stack_ctr
	beq @done
	jsr pop_stack
	jmp @draw

@done:
	lda #$0b
	sta console_xpos
	sta console_ypos
	lda #$2a
	jsr j_console_out
	lda saved_console_xpos
	sta console_xpos
	lda saved_console_ypos
	sta console_ypos
@waitkey:
	lda kbd_buf_count
	beq @waitkey
	lda kbd_buffer
	jsr j_clearkbd
	rts

clear_color:
	ldx #$01
@next_row:
	lda chrlineaddr_lo,x
	sta ptr1
	lda chrlineaddr_hi,x
	sta ptr1+1
	ldy #$01
	lda #$10
@clear:
	sta (ptr1),y
	iny
	cpy #$17
	bne @clear
	inx
	cpx #$17
	bne @next_row
	rts

get_dungeon_tile:
	lda dungeon_level
	lsr a
	lsr a
	clc
	adc #$e8
	sta ptr2+1
	lda dungeon_level
	and #$03
	asl a
	asl a
	asl a
	ora dungeon_y
	asl a
	asl a
	asl a
	ora dungeon_x
	sta ptr2
	ldy #$00
	lda (ptr2),y
	rts

push_stack:
	ldx stack_ctr
	lda dungeon_x
	sta draw_stack,x
	inx
	lda dungeon_y
	sta draw_stack,x
	inx
	lda console_xpos
	sta draw_stack,x
	inx
	lda console_ypos
	sta draw_stack,x
	inx
	stx stack_ctr
	rts

pop_stack:
	ldx stack_ctr
	dex
	lda draw_stack,x
	sta console_ypos
	dex
	lda draw_stack,x
	sta console_xpos
	dex
	lda draw_stack,x
	sta current_y
	dex
	lda draw_stack,x
	sta current_x
	stx stack_ctr
	rts

draw_tile_and_neighbors:
	sta temp_tile
	clc
	lda console_xpos
	adc dx
	sta console_xpos
	clc
	lda console_ypos
	adc dy
	sta console_ypos
	lda console_xpos
	beq @skip_next
	cmp #$17
	bcs @skip_next
	lda console_ypos
	beq @skip_next
	cmp #$17
	bcs @skip_next
	jsr get_buffer_ptr
	lda (ptr1),y
	bne @skip_next
	lda temp_tile
	jsr plot_char
	lda temp_tile
	cmp #$f0
	beq @dont_push
	jsr push_stack
@dont_push:
	jsr get_buffer_ptr
	lda #$ff
	sta (ptr1),y
@skip_next:
	sec
	lda console_xpos
	sbc dx
	sta console_xpos
	sec
	lda console_ypos
	sbc dy
	sta console_ypos
	rts

plot_char:
	lsr a
	lsr a
	lsr a
	lsr a
	tax
	lda tile_chars,x
	jmp plot_color

	dec console_xpos
	rts

tile_chars:
	.byte $20	; Empty.
	.byte $18	; Ladder up.
	.byte $19	; Ladder down.
	.byte $1a	; Ladder up & down.
	.byte $24	; Treasure chest.
	.byte $20	; Unused (ceiling hole).
	.byte $20	; Unused (floor hole).
	.byte $1b	; Orb.
	.byte $d4	; Trap.
	.byte $c6	; Fountain.
	.byte $de	; Field.
	.byte $60	; Altar.
	.byte $0e	; Door.
	.byte $0e	; Dungeon room.
	.byte $0f	; Secret door.
	.byte $40	; Wall.

get_buffer_ptr:
	ldx console_ypos
	dex
	lda buf_lo,x
	sta ptr1+1
	lda buf_hi,x
	sta ptr1
	sec
	lda console_xpos
	sbc #$01
	clc
	adc ptr1
	sta ptr1
	lda ptr1+1
	adc #$92
	sta ptr1+1
	ldy #$00
	rts

buf_lo:
  .repeat 22, line
	.byte >(line * 22)
  .endrepeat
buf_hi:
  .repeat 22, line
	.byte <(line * 22)
  .endrepeat

stack_ctr:	.byte 0

temp_tile:	.byte 0

current_x:	.byte 0
current_y:	.byte 0
dx:		.byte 0
dy:		.byte 0
dungeon_x:	.byte 0
dungeon_y:	.byte 0

saved_console_xpos:	.byte 0
saved_console_ypos:	.byte 0

tile_colors:
	;.byte $10	; Empty.
	.byte $80	; Ladder up.
	.byte $80	; Ladder down.
	.byte $80	; Ladder up & down.
	.byte $70	; Treasure chest.
	.byte $10	; Unused (ceiling hole).
	.byte $10	; Unused (floor hole).
	.byte $d0	; Orb.
	.byte $20	; Trap.
	.byte $e0	; Fountain.
	.byte $a0	; Field.
	.byte $10	; Altar.
	.byte $c0	; Door.
	.byte $10	; Dungeon room.
	.byte $c0	; Secret door.
	.byte $c0	; Wall.

	.align $100
buffer:
	.res $200


plot_color:
	stx @x
	jsr j_console_out
	dec console_xpos

	ldx console_ypos
	lda chrlineaddr_lo,x
	sta @color_ptr
	lda chrlineaddr_hi,x
	sta @color_ptr + 1
@x = * + 1
	ldx #$5e
	beq @done
	lda tile_colors - 1,x
	ldx console_xpos
@color_ptr = * + 1
	sta $5e1f,x
@done:
	rts
