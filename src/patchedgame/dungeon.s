

player_xpos		= $10
player_ypos		= $11
dungeon_level		= $1c
dng_direction		= $20
light_duration		= $21
tile_under_player	= $48
tile_forward_1		= $49
tile_forward_2		= $4a
tile_forward_3		= $4b
tile_behind		= $4c
ptr2			= $7c
ptr1			= $7e
screen			= $0400
bitmap			= $2000
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198
tilecolors0		= $e1b0
tilecolors1		= $a800
tilecolors2		= $a900
tilecolors3		= $f300

DIST0_ITEM_YPOS	= $88
DIST1_ITEM_YPOS	= $70
DIST2_ITEM_YPOS	= $60
DIST3_ITEM_YPOS	= $60


	.segment "DUNGEON"

dungeon:
	jmp dungeon_check_update

	jmp draw_items_monsters

	jsr get_tiles_behind_under_infront
	jmp dungeon_render

dungeon_check_update:
	jsr get_tiles_behind_under_infront
	lda dungeon_level
	cmp last_drawn_dungeon_level
	bne dungeon_render
	lda player_xpos
	cmp last_drawn_player_xpos
	bne dungeon_render
	lda player_ypos
	cmp last_drawn_player_ypos
	bne dungeon_render
	lda dng_direction
	cmp last_drawn_dng_direction
	bne dungeon_render
	lda tile_under_player
	cmp last_drawn_tile_under_player
	bne dungeon_render
	and #$f0
	cmp #$a0
	beq update_items_monsters
	cmp #$d0
	bcs update_items_monsters
	lda tile_forward_1
	cmp last_drawn_tile_north
	bne dungeon_render
	and #$f0
	cmp #$a0
	beq update_items_monsters
	cmp #$c0
	bcs update_items_monsters
	lda tile_forward_2
	cmp last_drawn_tile_south
	bne dungeon_render
	and #$f0
	cmp #$a0
	beq update_items_monsters
	cmp #$c0
	bcs update_items_monsters
	lda tile_forward_3
	cmp last_drawn_tile_east
	bne dungeon_render
	beq update_items_monsters
dungeon_render:
	lda dungeon_level
	sta last_drawn_dungeon_level
	lda player_xpos
	sta last_drawn_player_xpos
	lda player_ypos
	sta last_drawn_player_ypos
	lda dng_direction
	sta last_drawn_dng_direction
	lda tile_behind
	sta last_drawn_tile_west
	lda tile_under_player
	sta last_drawn_tile_under_player
	lda tile_forward_1
	sta last_drawn_tile_north
	lda tile_forward_2
	sta last_drawn_tile_south
	lda tile_forward_3
	sta last_drawn_tile_east
	jsr clear_and_render
update_items_monsters:
	jsr draw_items_monsters
	rts

clear_and_render:
	jsr clear_view
	lda light_duration
	bne @light
	rts

@light:
	lda #$00
	sta render_distance
render_forward:
	jsr get_coords_in_front
	jsr get_dungeon_tile_type
	bne @ladder_up
	jmp render_left

@ladder_up:
	tax
	dex
	bne @ladder_down
	jsr render_ladder_up
	jmp render_left

@ladder_down:
	dex
	bne @ladder_up_down
	jsr render_ladder_down
	jmp render_left

@ladder_up_down:
	dex
	bne @chest
	jsr render_ladder_up
	jsr render_ladder_down
	jmp render_left

@chest:
	dex
	bne @ceiling_hole
	jmp render_left

@ceiling_hole:
	dex
	bne @floor_hole
	jsr render_ceiling_hole
	jmp render_left

@floor_hole:
	dex
	bne @check_field
	jsr render_floor_hole
	jmp render_left

@check_field:
	dex
	dex
	dex
	dex
	bmi render_left
	bne @door
	jsr get_dungeon_tile
	jsr render_field
	jmp render_done

@door:
	dex
	beq render_left
	dex
	bne @dungeon_room
	jsr render_front_wall
	jsr render_front_door
	lda render_distance
	beq render_next_step
	jmp render_done

@dungeon_room:
	dex
	bne @wall
	jsr render_front_wall
	jsr render_front_door
	jmp render_done

@wall:
	jsr render_front_wall
	jmp render_done

render_left:
	jsr get_coords_front_left
	jsr get_dungeon_tile_type
	cmp #$0c
	bcs @door_or_wall
	jsr render_left_corridor
	jmp render_right

@door_or_wall:
	cmp #$0e
	bcs @wall
	jsr render_left_wall
	jsr render_left_door
	jmp render_right

@wall:
	jsr render_left_wall
	jmp render_right

render_right:
	jsr get_coords_front_right
	jsr get_dungeon_tile_type
	cmp #$0c
	bcs @door_or_wall
	jsr render_right_corridor
	jmp render_next_step

@door_or_wall:
	cmp #$0e
	bcs @wall
	jsr render_right_wall
	jsr render_right_door
	jmp render_next_step

@wall:
	jsr render_right_wall
	jmp render_next_step

render_next_step:
	inc render_distance
	lda render_distance
	cmp #$04
	bcs render_done
	jmp render_forward

render_done:
	rts

get_tiles_behind_under_infront:
	ldx dng_direction
	sec
	lda player_xpos
	sbc dir_delta_x,x
	and #$07
	sta gdt_x
	sec
	lda player_ypos
	sbc dir_delta_y,x
	and #$07
	sta gdt_y
	jsr get_dungeon_tile
	sta tile_behind
	lda player_xpos
	sta gdt_x
	lda player_ypos
	sta gdt_y
	jsr get_dungeon_tile
	sta tile_under_player
	ldx dng_direction
	clc
	lda gdt_x
	adc dir_delta_x,x
	and #$07
	sta gdt_x
	clc
	lda gdt_y
	adc dir_delta_y,x
	and #$07
	sta gdt_y
	jsr get_dungeon_tile
	sta tile_forward_1
	ldx dng_direction
	clc
	lda gdt_x
	adc dir_delta_x,x
	and #$07
	sta gdt_x
	clc
	lda gdt_y
	adc dir_delta_y,x
	and #$07
	sta gdt_y
	jsr get_dungeon_tile
	sta tile_forward_2
	ldx dng_direction
	clc
	lda gdt_x
	adc dir_delta_x,x
	and #$07
	sta gdt_x
	clc
	lda gdt_y
	adc dir_delta_y,x
	and #$07
	sta gdt_y
	jsr get_dungeon_tile
	sta tile_forward_3
	rts

init_dy_with_distance:
	sec
	lda #$00
	sbc render_distance
	sta draw_height
	rts

get_coords_in_front:
	jsr init_dy_with_distance
	lda #$00
	sta draw_width
	jsr rotate_coords
	rts

get_coords_front_left:
	jsr init_dy_with_distance
	lda #$ff
	sta draw_width
	jsr rotate_coords
	rts

get_coords_front_right:
	jsr init_dy_with_distance
	lda #$01
	sta draw_width
	jsr rotate_coords
	rts

rotate_coords:
	ldy dng_direction
	beq @done
@rotate:
	ldx draw_width
	lda draw_height
	eor #$ff
	sta draw_width
	inc draw_width
	stx draw_height
	dey
	bne @rotate
@done:
	clc
	lda player_xpos
	adc draw_width
	and #$07
	sta gdt_x
	clc
	lda player_ypos
	adc draw_height
	and #$07
	sta gdt_y
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
	lda light_duration
	lsr
	lsr
	lsr
	tay
	lda light_color,y
	ldy #$01
@clear_char:
	sta (ptr1),y
	iny
	cpy #$17
	bne @clear_char
	inx
	cpx #$17
	bne @next_char_row
	rts

light_color:
	.byte $b0, $c0, $f0, $f0
	.byte $10, $10, $10, $10
	.byte $10, $10, $10, $10
	.byte $10, $10, $10, $10

get_dungeon_tile_type:
	jsr get_dungeon_tile
	lsr a
	lsr a
	lsr a
	lsr a
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
	ora gdt_y
	asl a
	asl a
	asl a
	ora gdt_x
	sta ptr2
	ldy #$00
	lda (ptr2),y
	rts

render_left_wall:
	ldx render_distance
	lda left_wall_x,x
	sta draw_x1
	lda left_wall_x+1,x
	sta draw_x2
	lda wall_top_y,x
	sta draw_top_y1
	lda wall_top_y+1,x
	sta draw_top_y2
	lda wall_bottom_y,x
	sta draw_bottom_y1
	lda wall_bottom_y+1,x
	sta draw_bottom_y2
	jsr set_wall_pattern_a
	jmp draw_wall

render_right_wall:
	ldx render_distance
	lda right_wall_x,x
	sta draw_x1
	lda right_wall_x+1,x
	sta draw_x2
	lda wall_top_y,x
	sta draw_top_y1
	lda wall_top_y+1,x
	sta draw_top_y2
	lda wall_bottom_y,x
	sta draw_bottom_y1
	lda wall_bottom_y+1,x
	sta draw_bottom_y2
	jsr set_wall_pattern_a
	jmp draw_wall

render_front_wall:
	ldx render_distance
	cpx #4
	bcs @dist4plus

	lda front_wall_bitmap_addr_lo,x
	sta ptr1
	lda front_wall_bitmap_addr_hi,x
	sta ptr1 + 1

	lda dng_direction
	lsr
	lda #$55
	bcs :+
	asl
:	sta @fill_byte

	ldy render_distance
	lda front_wall_width,y
	sta @end
	ldx front_wall_height,y
@next:
	ldy #0
@fill_byte = * + 1
:	lda #$5e
	ora (ptr1),y
	sta (ptr1),y
	iny
@end = * + 1
	cpy #$5e
	bne :-
	dex
	beq @done

	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1 + 1
	adc #1
	sta ptr1 + 1
	jmp @next
@done:
	rts

@dist4plus:
	lda left_wall_x,x
	sta draw_x1
	lda right_wall_x,x
	sta draw_x2
	lda wall_top_y,x
	sta draw_top_y1
	sta draw_top_y2
	lda wall_bottom_y,x
	sta draw_bottom_y1
	sta draw_bottom_y2
	jsr set_wall_pattern_b
	jmp draw_wall

render_left_door:
	jsr @set_coords
	lda #$ff
	sta column_draw_mode
	jmp draw_wall

@set_coords:
	ldx render_distance
	lda left_door_start_x,x
	sta draw_x1
	lda left_door_end_x,x
	sta draw_x2
	lda door_top_start_y,x
	sta draw_top_y1
	lda door_top_end_y,x
	sta draw_top_y2
	lda door_bottom_start_y,x
	sta draw_bottom_y1
	lda door_bottom_end_y,x
	sta draw_bottom_y2
	rts

render_right_door:
	jsr @set_coords
	lda #$ff
	sta column_draw_mode
	jmp draw_wall

@set_coords:
	ldx render_distance
	lda right_door_start_x,x
	sta draw_x1
	lda right_door_end_x,x
	sta draw_x2
	lda door_top_start_y,x
	sta draw_top_y1
	lda door_top_end_y,x
	sta draw_top_y2
	lda door_bottom_start_y,x
	sta draw_bottom_y1
	lda door_bottom_end_y,x
	sta draw_bottom_y2
	rts

render_front_door:
	ldy #$ff
	ldx render_distance
	bne :+
	iny
:	sty @byte
	cpx #3
	bcs @dist3plus

	lda @bitmap_addr_lo,x
	sta ptr1
	lda @bitmap_addr_hi,x
	sta ptr1 + 1

	lda @width,x
	sta @end
	lda @height,x
	tax
@next:
	ldy #0
@byte = * + 1
	lda #$5e
:	sta (ptr1),y
	iny
@end = * + 1
	cpy #$5e
	bne :-
	dex
	beq @done

	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1 + 1
	adc #1
	sta ptr1 + 1
	jmp @next
@done:
	rts

@dist3plus:
	cpx #4
	beq @done

	ldx #7
:	lda bitmap + 12 * 320 + 11 * 8,x
	ora #3
	sta bitmap + 12 * 320 + 11 * 8,x
	lda bitmap + 12 * 320 + 12 * 8,x
	ora #$c0
	sta bitmap + 12 * 320 + 12 * 8,x
	dex
	bpl :-
	rts

@width:
	.byte 14 * 8
	.byte  6 * 8
	.byte  2 * 8
@height:
	.byte 18
	.byte 10
	.byte  4

@bitmap_addr_lo:
	.byte <(bitmap +  5 * 320 +  5 * 8)
	.byte <(bitmap +  9 * 320 +  9 * 8)
	.byte <(bitmap + 11 * 320 + 11 * 8)
@bitmap_addr_hi:
	.byte >(bitmap +  5 * 320 +  5 * 8)
	.byte >(bitmap +  9 * 320 +  9 * 8)
	.byte >(bitmap + 11 * 320 + 11 * 8)

render_left_corridor:
	ldx render_distance
	lda left_wall_x,x
	sta draw_x1
	lda left_wall_x+1,x
	sta draw_x2
	lda wall_top_y+1,x
	sta draw_top_y1
	sta draw_top_y2
	lda wall_bottom_y+1,x
	sta draw_bottom_y1
	sta draw_bottom_y2
	jsr set_wall_pattern_b
	jmp draw_wall

render_right_corridor:
	ldx render_distance
	lda right_wall_x,x
	sta draw_x1
	lda right_wall_x+1,x
	sta draw_x2
	lda wall_top_y+1,x
	sta draw_top_y1
	sta draw_top_y2
	lda wall_bottom_y+1,x
	sta draw_bottom_y1
	sta draw_bottom_y2
	jsr set_wall_pattern_b
	jmp draw_wall

render_ladder_up:
	jsr render_ceiling_hole
	lda dng_direction
	lsr a
	bcs @head_on
	jmp @from_side

@head_on:
	ldx render_distance
	lda ladder_left_x,x
	sta pixel_x
	lda ceiling_hole_top_y,x
	sta pixel_column_start_y
	lda #$5f
	sta pixel_column_end_y
	jsr set_pixel_column
	inc pixel_x
	jsr set_pixel_column
	ldx render_distance
	lda ladder_right_x,x
	sta pixel_x
	lda ceiling_hole_top_y,x
	sta pixel_column_start_y
	lda #$5f
	sta pixel_column_end_y
	jsr set_pixel_column
	dec pixel_x
	jsr set_pixel_column
	ldx render_distance
	lda ladder_left_x,x
	sta draw_x1
	lda ladder_right_x,x
	sta draw_x2
	lda ladder_up_top_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	ldx render_distance
	lda ladder_up_middle_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	ldx render_distance
	lda ladder_up_bottom_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	rts

@from_side:
	ldx render_distance
	lda #$53 + 4
	sta pixel_x
	lda ceiling_hole_top_y,x
	sta pixel_column_start_y
	lda #$5f
	sta pixel_column_end_y
	jsr set_pixel_column
	inc pixel_x
	jsr set_pixel_column
	rts

render_ladder_down:
	jsr render_floor_hole
	lda dng_direction
	lsr a
	bcs @head_on
	jmp @from_side

@head_on:
	ldx render_distance
	lda ladder_left_x,x
	sta pixel_x
	lda floor_hole_bottom_y,x
	sta pixel_column_end_y
	lda #$60
	sta pixel_column_start_y
	jsr set_pixel_column
	inc pixel_x
	jsr set_pixel_column
	ldx render_distance
	lda ladder_right_x,x
	sta pixel_x
	lda floor_hole_bottom_y,x
	sta pixel_column_end_y
	lda #$60
	sta pixel_column_start_y
	jsr set_pixel_column
	dec pixel_x
	jsr set_pixel_column
	ldx render_distance
	lda ladder_left_x,x
	sta draw_x1
	lda ladder_right_x,x
	sta draw_x2
	lda ladder_down_top_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	ldx render_distance
	lda ladder_down_middle_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	ldx render_distance
	lda ladder_down_bottom_rung_y,x
	sta draw_y1
	sta draw_y2
	jsr draw_line
	rts

@from_side:
	ldx render_distance
	lda #$53 + 4
	sta pixel_x
	lda #$60
	sta pixel_column_start_y
	lda floor_hole_bottom_y,x
	sta pixel_column_end_y
	jsr set_pixel_column
	inc pixel_x
	jsr set_pixel_column
	rts

render_ceiling_hole:
	ldx render_distance
	lda hole_bottom_left_x,x
	sta draw_x1
	lda ceiling_hole_top_y,x
	sta draw_y1
	lda hole_top_left_x,x
	sta draw_x2
	lda ceiling_hole_bottom_y,x
	sta draw_y2
	jsr draw_line
	inc draw_x1
	inc draw_x2
	jsr draw_line
	ldx render_distance
	lda hole_top_right_x,x
	sta draw_x1
	lda ceiling_hole_bottom_y,x
	sta draw_y1
	jsr draw_line
	ldx render_distance
	lda hole_bottom_right_x,x
	sta draw_x2
	lda ceiling_hole_top_y,x
	sta draw_y2
	jsr draw_line
	dec draw_x1
	dec draw_x2
	jsr draw_line
	ldx render_distance
	lda hole_bottom_left_x,x
	sta draw_x1
	lda ceiling_hole_top_y,x
	sta draw_y1
	jsr draw_line
	rts

render_floor_hole:
	ldx render_distance
	lda hole_bottom_left_x,x
	sta draw_x1
	lda floor_hole_bottom_y,x
	sta draw_y1
	lda hole_top_left_x,x
	sta draw_x2
	lda floor_hole_top_y,x
	sta draw_y2
	jsr draw_line
	inc draw_x1
	inc draw_x2
	jsr draw_line
	ldx render_distance
	lda hole_top_right_x,x
	sta draw_x1
	lda floor_hole_top_y,x
	sta draw_y1
	jsr draw_line
	ldx render_distance
	lda hole_bottom_right_x,x
	sta draw_x2
	lda floor_hole_bottom_y,x
	sta draw_y2
	jsr draw_line
	dec draw_x1
	dec draw_x2
	jsr draw_line
	ldx render_distance
	lda hole_bottom_left_x,x
	sta draw_x1
	lda floor_hole_bottom_y,x
	sta draw_y1
	jsr draw_line
	rts

set_wall_pattern_a:
	lda dng_direction
	and #$01
	sta column_draw_mode
	inc column_draw_mode
	rts

set_wall_pattern_b:
	lda dng_direction
	and #$01
	eor #$01
	sta column_draw_mode
	inc column_draw_mode
	rts

draw_wall:
	lda draw_top_y1
	sta pixel_column_start_y
	lda draw_bottom_y1
	sta pixel_column_end_y
	lda draw_x1
	sta pixel_x
	lda draw_x1
	cmp draw_x2
	bcs @step_left
	lda #$01
	sta step_x
	sec
	lda draw_x2
	sbc draw_x1
	sta draw_width
	jmp @top

@step_left:
	lda #$ff
	sta step_x
	sec
	lda draw_x1
	sbc draw_x2
	sta draw_width
@top:
	lda #$ff
	sta draw_top_step_y
	sec
	lda draw_top_y1
	sbc draw_top_y2
	sta draw_top_height
	bcs @bottom
	eor #$ff
	sta draw_top_height
	inc draw_top_height
	lda #$01
	sta draw_top_step_y
@bottom:
	lda #$ff
	sta draw_bottom_step_y
	sec
	lda draw_bottom_y1
	sbc draw_bottom_y2
	sta draw_bottom_height
	bcs @draw_column
	eor #$ff
	sta draw_bottom_height
	inc draw_bottom_height
	lda #$01
	sta draw_bottom_step_y
	lda draw_top_height
	lsr a
	sta top_error_delta
	lda draw_bottom_height
	lsr a
	sta bottom_error_delta
@draw_column:
	jsr set_or_clear_column
	sec
	lda top_error_delta
	sbc draw_top_height
	sta top_error_delta
	bcs @top_step_y_done
@step_top_y:
	clc
	lda pixel_column_start_y
	adc draw_top_step_y
	sta pixel_column_start_y
	clc
	lda top_error_delta
	adc draw_width
	sta top_error_delta
	bmi @step_top_y
@top_step_y_done:
	sec
	lda bottom_error_delta
	sbc draw_bottom_height
	sta bottom_error_delta
	bcs @bottom_step_y_done
@step_bottom_y:
	clc
	lda pixel_column_end_y
	adc draw_bottom_step_y
	sta pixel_column_end_y
	clc
	lda bottom_error_delta
	adc draw_width
	sta bottom_error_delta
	bmi @step_bottom_y
@bottom_step_y_done:
	clc
	lda pixel_x
	adc step_x
	sta pixel_x
	cmp draw_x2
	bne @draw_column
	jsr set_or_clear_column
	rts

set_or_clear_column:
	lda column_draw_mode
	bmi set_pixel_column
	eor pixel_x
	and #$01
	bne set_pixel_column_done
set_pixel_column:
	lda pixel_x
	;clc
	;adc #$08
	and #$07
	tax
	lda bitmask,x
	sta @bit

	lda pixel_x
	clc
	adc #$08
	and #$f8
	pha
	lda pixel_column_start_y
	and #$f8
	tax
	pla
	clc
	adc bmplineaddr_lo,x
	sta ptr1
	lda bmplineaddr_hi,x
	adc #0
	sta ptr1 + 1
	
	lda pixel_column_start_y
	and #7
	tay

	lda pixel_column_end_y
	sec
	sbc pixel_column_start_y
	tax
	inx
@draw:
@bit = * + 1
	lda #$5e
	ora (ptr1),y
	sta (ptr1),y
	dex
	beq set_pixel_column_done
	iny
	cpy #8
	bne @draw

	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1 + 1
	adc #1
	sta ptr1 + 1
	ldy #0
	beq @draw

set_pixel_column_done:
	rts

bitmask:
	.byte $80, $40, $20, $10, $08, $04, $02, $01

draw_line:
	sec
	lda draw_x2
	sbc draw_x1
	sta draw_width
	bcs @right
	eor #$ff
	sta draw_width
	inc draw_width
	lda #$ff
	sta step_x
	jmp @get_dy

@right:
	lda #$01
	sta step_x
@get_dy:
	sec
	lda draw_y2
	sbc draw_y1
	sta draw_height
	bcs @down
	eor #$ff
	sta draw_height
	inc draw_height
	lda #$ff
	sta step_y
	jmp @start_draw

@down:
	lda #$01
	sta step_y
@start_draw:
	lda draw_x1
	sta pixel_x
	lda draw_y1
	sta pixel_y
	jsr set_pixel
	lda draw_width
	cmp draw_height
	bcs draw_line_horizontal
	jmp draw_line_vertical

draw_line_horizontal:
	lda draw_width
	sta temp2
	lsr a
	sta line_error_delta
@next:
	clc
	lda line_error_delta
	adc draw_height
	sta line_error_delta
	sec
	sbc draw_width
	bcc @skipy
	sta line_error_delta
	clc
	lda pixel_y
	adc step_y
	sta pixel_y
@skipy:
	clc
	lda pixel_x
	adc step_x
	sta pixel_x
	jsr set_pixel
	dec temp2
	bne @next
	rts

draw_line_vertical:
	lda draw_height
	sta temp2
	lsr a
	sta line_error_delta
@next:
	clc
	lda line_error_delta
	adc draw_width
	sta line_error_delta
	sec
	sbc draw_height
	bcc @skipx
	sta line_error_delta
	clc
	lda pixel_x
	adc step_x
	sta pixel_x
@skipx:
	clc
	lda pixel_y
	adc step_y
	sta pixel_y
	jsr set_pixel
	dec temp2
	bne @next
	rts

set_pixel:
	ldy pixel_y
	lda bmplineaddr_lo,y
	sta ptr1
	lda bmplineaddr_hi,y
	sta ptr1+1
	lda pixel_x
	clc
	adc #$08
	pha
	and #$07
	tax
	lda bitmask,x
	tax
	pla
	and #$f8
	tay
	txa
	ora (ptr1),y
	sta (ptr1),y
	rts

draw_items_monsters:
	lda light_duration
	bne @light
	jsr clear_view
	rts

@light:
	ldx #0
	stx masked_field_row
	stx render_distance
	lda #$ff
	sta max_item_draw_height
@check:
	ldx render_distance
	cpx #4
	beq @done

	lda tile_under_player,x
	beq @empty
	jsr get_monster
	beq @item
	jsr get_monster_tile_num
	jsr @draw_tile
	jmp @next

@item:
	ldx render_distance
	lda tile_under_player,x
	jsr get_item_tile_num
	beq @empty
	bmi @check_door
	jsr @draw_tile
	jmp @next

@check_door:
	ldx render_distance
	bne @done
	lda tile_under_player,x
	cmp #$d0
	bcs @done

@empty:
	lda #0
	sta masked_field_row
@next:
	inc render_distance
	bne @check

@done:
	rts

@draw_tile:
	ldy @draw_tile_func_lo,x
	sty @j_draw_tile
	ldy @draw_tile_func_hi,x
	sty @j_draw_tile + 1
@j_draw_tile = * + 1
	jsr $5e1f
	ldx render_distance
	ldy @max_height,x
	sty max_item_draw_height
	ldy @mask_row,x
	sty masked_field_row
	ldy @mask_left,x
	sty masked_field_left
	ldy @mask_right,x
	sty masked_field_right
	ldy @mask_color_left,x
	sty masked_color_left
	ldy @mask_color_right,x
	sty masked_color_right
	rts

@draw_tile_func_lo:
	.byte <draw_tile_3x
	.byte <draw_tile_2x
	.byte <draw_tile_1x
	.byte <draw_tile_half

@draw_tile_func_hi:
	.byte >draw_tile_3x
	.byte >draw_tile_2x
	.byte >draw_tile_1x
	.byte >draw_tile_half

@max_height:
	.byte DIST0_ITEM_YPOS
	.byte DIST1_ITEM_YPOS
	.byte DIST2_ITEM_YPOS
	.byte DIST3_ITEM_YPOS

@mask_row:
	.byte 3
	.byte 2
	.byte 2
	.byte 0
@mask_left:
	.byte $20
	.byte $8
	.byte 0
	.byte 0
@mask_right:
	.byte $50
	.byte $28
	.byte $10
	.byte 0
@mask_color_left:
	.byte 4
	.byte 1
	.byte 0
	.byte 0
@mask_color_right:
	.byte 10
	.byte 5
	.byte 2
	.byte 0


get_monster_tile_num:
	asl a
	asl a
	clc
	adc #$8c
	sta temp1
	jsr getrand
	and #$03
	ora temp1
	rts

get_item_tile_num:
	sta temp2
	and #$f0
	cmp #$40
	beq @chest
	cmp #$70
	beq @orb
	cmp #$80
	beq @its_a_trap
	cmp #$90
	beq @fountain
	cmp #$a0
	beq @field
	cmp #$b0
	beq @altar
	cmp #$c0
	bcc @empty
	lda #$ff
	rts

@empty:
	lda #$00
	rts

@chest:
	lda #$3c
	rts

@orb:
	lda #$4e
	rts

@its_a_trap:
	jsr rand_1_in_64
	bmi @empty
	lda temp2
	and #$0f
	beq @empty
	cmp #$08
	bcs @pit
	jsr render_ceiling_hole
	jmp @empty

@field:
	lda temp2
	jsr render_field
	pla
	pla
	rts

@pit:
	jsr render_floor_hole
	jmp @empty

@fountain:
	lda #$02
	rts

@altar:
	lda #$4a
	rts

rand_1_in_64:
	jsr getrand
	and #$3f
	beq @zero
	lda #$ff
@zero:
	rts

get_monster:
	sta temp2
	and #$f0
	cmp #$80
	beq @empty
	cmp #$90
	beq @empty
	cmp #$a0
	beq @empty
	cmp #$d0
	bcs @empty
	lda temp2
	and #$0f
	rts

@empty:
	lda #$00
	rts

render_field:
	eor #$e4
	tax
	lda tilecolors0,x
	sta @color

	ldx render_distance
	lda @screen_addr_lo,x
	sta ptr1
	lda @screen_addr_hi,x
	sta ptr1 + 1

	lda front_wall_height,x
	tax
	sta @scrend
@scrnext:
	cpx masked_field_row
	bcc @maybe_draw_masked_color
	ldy #0
@color = * + 1
	lda #$5e
:	sta (ptr1),y
	iny
@scrend = * + 1
	cpy #$5e
	bne :-
	dex
	beq @draw_bitmap

	jsr @next_color_row
	jmp @scrnext

@maybe_draw_masked_color:
	lda render_distance
	cmp #3
	bcs @draw_bitmap

@next_masked_color_row:
	ldy #0
	lda @color
@draw_masked_color:
	sta (ptr1),y
	iny
	cpy masked_color_left
	bne :+
	ldy masked_color_right
:	cpy @scrend
	bcc @draw_masked_color

	dex
	beq @draw_bitmap

	jsr @next_color_row
	jmp @next_masked_color_row

@draw_bitmap:
	ldx render_distance
	lda front_wall_bitmap_addr_lo,x
	sta ptr1
	lda front_wall_bitmap_addr_hi,x
	sta ptr1 + 1

	ldy render_distance
	lda front_wall_width,y
	sta @end
	ldx front_wall_height,y
@next:
	cpx masked_field_row
	bcc @draw_masked_field

	ldy #0
:	jsr getrand
	and #$55
	eor (ptr1),y
	sta (ptr1),y
	iny
@end = * + 1
	cpy #$5e
	bne :-
	dex
	beq @done

	jsr @next_bitmap_row
	jmp @next
@done:
	lda #0
	sta masked_field_row
	rts

@next_color_row:
	lda ptr1
	clc
	adc #40
	sta ptr1
	bcc :+
	inc ptr1 + 1
:	rts

@next_bitmap_row:
	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1 + 1
	adc #1
	sta ptr1 + 1
	rts

@draw_masked_field:
	lda render_distance
	cmp #3
	bcs @done
	ldy #0
@draw_masked:
	jsr getrand
	and #$55
	eor (ptr1),y
	sta (ptr1),y
	iny
	cpy masked_field_left
	bne :+
	ldy masked_field_right
:	cpy @end
	bcc @draw_masked

	dex
	beq @done

	jsr @next_bitmap_row
	jmp @draw_masked_field

@screen_addr_lo:
	.byte <(screen +  1 * 41)
	.byte <(screen +  5 * 41)
	.byte <(screen +  9 * 41)
	.byte <(screen + 11 * 41)
@screen_addr_hi:
	.byte >(screen +  1 * 41)
	.byte >(screen +  5 * 41)
	.byte >(screen +  9 * 41)
	.byte >(screen + 11 * 41)

masked_field_row:
	.byte 0
masked_field_left:
	.byte $20
masked_field_right:
	.byte $50
masked_color_left:
	.byte $20
masked_color_right:
	.byte $50

getrand:
	lda rand_data
	adc rand_data+2
	sta rand_data+2
	eor rand_data+1
	sta rand_data+1
	adc rand_data
	sta rand_data
	rts

rand_data:
	.byte 73, 47, 21

draw_tile_half:
	ldy #DIST3_ITEM_YPOS
	cpy max_item_draw_height
	bcs @done

	jsr draw_tile_colors_half
	sty @tile_ptr1
	sty @tile_ptr2
	sta @tile_ptr1+1
	eor #$70
	sta @tile_ptr2+1
	ldy #DIST3_ITEM_YPOS
	lda #$58
	jsr get_bitmap_ptr_offset
	stx @bitmap_ptr1
	sta @bitmap_ptr1+1
	ldy #DIST3_ITEM_YPOS + 4
	lda #$58
	jsr get_bitmap_ptr_offset
	stx @bitmap_ptr2
	sta @bitmap_ptr2+1
	ldx #$00
	ldy #$00
@draw:
@tile_ptr1 = * + 1
	lda $ffff,x
	jsr @get_halfbyte
@bitmap_ptr1 = * + 1
	sta $ffff,y
@tile_ptr2 = * + 1
	lda $ffff,x
	jsr @get_halfbyte
@bitmap_ptr2 = * + 1
	sta $ffff,y
	iny
	cpy #$04
	bne :+
	ldy #$08
:	inx
	inx
	cpx #$10
	bne @draw
@done:
	rts

@get_halfbyte:
	cpx #8
	bcs @right
	asl
	asl
	rol @halfbyte
	asl
	asl
	rol @halfbyte
	asl
	asl
	rol @halfbyte
	asl
	asl
	rol @halfbyte
	lda @halfbyte
	and #$0f
	rts
@right:
	lsr
	ror @halfbyte
	lsr
	lsr
	ror @halfbyte
	lsr
	lsr
	ror @halfbyte
	lsr
	lsr
	ror @halfbyte
	lda @halfbyte
	and #$f0
	rts

@halfbyte:
	.byte 0

draw_tile_1x:
	jsr draw_tile_colors_1x
	sty @tile_ptr1
	sty @tile_ptr2
	sta @tile_ptr1+1
	eor #$70
	sta @tile_ptr2+1
	ldy #DIST2_ITEM_YPOS
	lda #$58
	jsr get_bitmap_ptr_offset
	stx @bitmap_ptr1
	sta @bitmap_ptr1+1
	ldy #DIST2_ITEM_YPOS + 8
	lda #$58
	jsr get_bitmap_ptr_offset
	stx @bitmap_ptr2
	sta @bitmap_ptr2+1
	ldx #$00
	ldy #$00
@draw:
@tile_ptr1 = * + 1
	lda $ffff,x
@bitmap_ptr1 = * + 1
	sta $ffff,x
@tile_ptr2 = * + 1
	lda $ffff,x
@bitmap_ptr2 = * + 1
	sta $ffff,x
	inx
	cpx #$10
	bne @draw
	rts

draw_tile_2x:
	ldx #$02
	ldy #DIST1_ITEM_YPOS
	stx tile_expansion_factor
	sty tile_draw_ypos
	jsr draw_tile_colors_2x
	sty @tile_ptr
	sta @tile_ptr+1
	lda #$00
	sta tile_row_counter
@next_row:
	ldx #$00
	ldy #$00
@copy_tile_data:
@tile_ptr = * + 1
	lda $ffff,x
	sta tile_data,y
	txa
	clc
	adc #$08
	tax
	iny
	cpy #$02
	bne @copy_tile_data
	jsr expand_tile_data_2x
	lda tile_expansion_factor
	sta tile_line_counter
@repeat_line:
	ldx tile_draw_ypos
	cpx max_item_draw_height
	bcs @clamp
	lda bmplineaddr_lo,x
	sta @bitmap_ptr
	lda bmplineaddr_hi,x
	sta @bitmap_ptr+1
	ldx #$00
	ldy #$50
@draw:
	lda tile_data_expanded,x
@bitmap_ptr = * + 1
	sta $ffff,y
	tya
	clc
	adc #$08
	tay
	inx
	cpx #$04
	bne @draw
	inc tile_draw_ypos
	dec tile_line_counter
	bne @repeat_line
	inc @tile_ptr
	bne :+
	inc @tile_ptr+1
:	inc tile_row_counter
	lda tile_row_counter
	tax
	and #$07
	bne :+
	lda @tile_ptr
	clc
	adc #$f8
	sta @tile_ptr
	lda @tile_ptr+1
	adc #$0f
	sta @tile_ptr+1
:	txa
	cmp #$10
	bne @next_row
@clamp:
	rts

tile_expansion_factor:
	.byte 141
tile_row_counter:
	.byte 103
tile_line_counter:
	.byte 151

draw_tile_3x:
;	ldx #$04
	ldy #DIST0_ITEM_YPOS
;	stx tile_expansion_factor
	sty tile_draw_ypos
	jsr draw_tile_colors_3x
	sty @tile_ptr
	sta @tile_ptr+1
	lda #0
	sta tile_row_counter
@next_row:
	ldx #8
	ldy #1
@copy_tile_data:
@tile_ptr = * + 1
	lda $5e1f,x
	sta tile_data,y
	dey
	bmi :+
	ldx #0
	beq @copy_tile_data
:
	jsr expand_tile_data_3x
	lda #3
	sta tile_line_counter
@repeat_line:
	ldx tile_draw_ypos
	lda bmplineaddr_lo,x
	sta @bitmap_ptr
	lda bmplineaddr_hi,x
	sta @bitmap_ptr + 1
	ldx #5
	ldy #$70
@draw:
	lda tile_data_expanded,x
@bitmap_ptr = * + 1
	sta $5e1f,y
	dex
	bmi :+
	tya
	sec
	sbc #8
	tay
	bne @draw
:
	inc tile_draw_ypos
	dec tile_line_counter
	bne @repeat_line

	inc tile_row_counter
	lda tile_row_counter
	cmp #8
	beq @lowerhalf
	cmp #16
	beq @done

	inc @tile_ptr
;	bne :+
;	inc @tile_ptr + 1
;:
	jmp @next_row
@lowerhalf:
	lda @tile_ptr
	clc
	adc #$f9
	sta @tile_ptr
	lda @tile_ptr + 1
	adc #$0f
	sta @tile_ptr + 1
	jmp @next_row

@done:
	rts


get_tile_addr:
	sta @temp
	lda #$00
	ldx #$04
@shift:
	asl @temp
	rol a
	dex
	bne @shift
	clc
	adc #$b0
	ldy @temp
	rts

@temp:
	.byte 0

get_bitmap_ptr_offset:
	clc
	adc bmplineaddr_lo,y
	tax
	lda #$00
	adc bmplineaddr_hi,y
	rts

expand_tile_data_2x:
	ldx #8
@next:
	asl tile_data
	php
	rol tile_data_expanded + 1
	rol tile_data_expanded
	plp
	rol tile_data_expanded + 1
	rol tile_data_expanded

	asl tile_data + 1
	php
	rol tile_data_expanded + 3
	rol tile_data_expanded + 2
	plp
	rol tile_data_expanded + 3
	rol tile_data_expanded + 2

	dex
	bne @next
	rts


expand_tile_data_3x:
	lda tile_data
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	lda expand_3x_left,x
	sta tile_data_expanded
	lda tile_data
	lsr
	lsr
	and #$0f
	tax
	lda expand_3x_middle,x
	sta tile_data_expanded + 1
	lda tile_data
	and #7
	tax
	lda expand_3x_right,x
	sta tile_data_expanded + 2

	lda tile_data + 1
	lsr
	lsr
	lsr
	lsr
	lsr
	tax
	lda expand_3x_left,x
	sta tile_data_expanded + 3
	lda tile_data + 1
	lsr
	lsr
	and #$0f
	tax
	lda expand_3x_middle,x
	sta tile_data_expanded + 4
	lda tile_data + 1
	and #7
	tax
	lda expand_3x_right,x
	sta tile_data_expanded + 5

	rts


expand_3x_left:
	.byte %00000000
	.byte %00000011
	.byte %00011100
	.byte %00011111
	.byte %11100000
	.byte %11100011
	.byte %11111100
	.byte %11111111

expand_3x_middle:
	.byte %00000000
	.byte %00000001
	.byte %00001110
	.byte %00001111
	.byte %01110000
	.byte %01110001
	.byte %01111110
	.byte %01111111
	.byte %10000000
	.byte %10000001
	.byte %10001110
	.byte %10001111
	.byte %11110000
	.byte %11110001
	.byte %11111110
	.byte %11111111

expand_3x_right:
	.byte %00000000
	.byte %00000111
	.byte %00111000
	.byte %00111111
	.byte %11000000
	.byte %11000111
	.byte %11111000
	.byte %11111111

tile_data:
	.byte 0, 0
tile_data_expanded:
	.byte 0, 0, 0, 0, 0, 0
tile_draw_ypos:
	.byte 0
max_item_draw_height:
	.byte 0
render_distance:
	.byte 0
temp1:
	.byte 0
column_draw_mode:
	.byte 0
pixel_x:
	.byte 0
pixel_y:
	.byte 0
gdt_x:
	.byte 0
gdt_y:
	.byte 0
step_x:
	.byte 0
step_y:
	.byte 0
temp2:
	.byte 0
line_error_delta:
	.byte 0
draw_x1:
	.byte 0
draw_x2:
	.byte 0
draw_y1:
	.byte 0
draw_y2:
	.byte 0
draw_width:
	.byte 0
draw_height:
	.byte 0
top_error_delta:
	.byte 0
bottom_error_delta:
	.byte 0
draw_top_y1:
	.byte 0
draw_top_y2:
	.byte 0
draw_top_step_y:
	.byte 0
pixel_column_start_y:
	.byte 0
draw_top_height:
	.byte 0
draw_bottom_y1:
	.byte 0
draw_bottom_y2:
	.byte 0
draw_bottom_step_y:
	.byte 0
pixel_column_end_y:
	.byte 0
draw_bottom_height:
	.byte 0
dir_delta_x:
	.byte 0, 1, 0, 255
dir_delta_y:
	.byte 255, 0, 1, 0
left_wall_x:
	.byte 0, 32, 64, 80, 87
right_wall_x:
	.byte 175, 143, 111, 95, 88
wall_top_y:
	.byte 8, 40, 72, 88, 95
wall_bottom_y:
	.byte 183, 151, 119, 103, 96
left_door_start_x:
	.byte 0, 39, 67, 82
left_door_end_x:
	.byte 18, 57, 76, 84
right_door_start_x:
	.byte 175, 136, 108, 93
right_door_end_x:
	.byte 157, 118, 99, 91
door_top_start_y:
	.byte 52, 72, 86, 94
door_top_end_y:
	.byte 61, 81, 91, 95
door_bottom_start_y:
	.byte 183, 144, 116, 101
door_bottom_end_y:
	.byte 165, 126, 107, 99
ceiling_hole_top_y:
	.byte 8, 48, 76, 90
ceiling_hole_bottom_y:
	.byte 24, 64, 84, 93
floor_hole_bottom_y:
	.byte 183, 143, 115, 101
floor_hole_top_y:
	.byte 167, 127, 107, 98
hole_bottom_left_x:
	.byte 46 + 3, 63 + 3, 75 + 3, 81 + 3
hole_top_left_x:
	.byte 53 + 3, 70 + 3, 79 + 3, 82 + 3
hole_bottom_right_x:
	.byte 122 + 3, 105 + 3, 93 + 3, 86 + 3
hole_top_right_x:
	.byte 115 + 3, 98 + 3, 89 + 3, 85 + 3
ladder_left_x:
	.byte 63 + 3, 74 + 3, 81 + 3, 83 + 3
ladder_right_x:
	.byte 104 + 3, 94 + 3, 87 + 3, 84 + 3
ladder_up_top_rung_y:
	.byte 16, 56, 80, 93
ladder_up_middle_rung_y:
	.byte 48, 72, 86, 94
ladder_up_bottom_rung_y:
	.byte 80, 88, 92, 95
ladder_down_top_rung_y:
	.byte 175, 135, 111, 98
ladder_down_middle_rung_y:
	.byte 143, 119, 105, 97
ladder_down_bottom_rung_y:
	.byte 111, 103, 99, 96
last_drawn_dungeon_level:
	.byte 0
last_drawn_player_xpos:
	.byte 0
last_drawn_player_ypos:
	.byte 0
last_drawn_dng_direction:
	.byte 0
last_drawn_tile_west:
	.byte 0
last_drawn_tile_under_player:
	.byte 0
last_drawn_tile_north:
	.byte 0
last_drawn_tile_south:
	.byte 0
last_drawn_tile_east:
	.byte 0

front_wall_width:
	.byte 22 * 8
	.byte 14 * 8
	.byte  6 * 8
	.byte  2 * 8
front_wall_height:
	.byte 22
	.byte 14
	.byte  6
	.byte  2

front_wall_bitmap_addr_lo:
	.byte <(bitmap +  1 * 328)
	.byte <(bitmap +  5 * 328)
	.byte <(bitmap +  9 * 328)
	.byte <(bitmap + 11 * 328)
front_wall_bitmap_addr_hi:
	.byte >(bitmap +  1 * 328)
	.byte >(bitmap +  5 * 328)
	.byte >(bitmap +  9 * 328)
	.byte >(bitmap + 11 * 328)



draw_tile_colors_half:
	tax
	ldy tilecolors2,x
	sty screen + 12 * 40 + 11
	ldy tilecolors3,x
	sty screen + 12 * 40 + 12
	jmp get_tile_addr

draw_tile_colors_1x:
	tax
	ldy tilecolors0,x
	sty screen + 12 * 40 + 11
	ldy tilecolors1,x
	sty screen + 12 * 40 + 12
	ldy tilecolors2,x
	sty screen + 13 * 40 + 11
	ldy tilecolors3,x
	sty screen + 13 * 40 + 12
	jmp get_tile_addr

draw_tile_colors_2x:
	tax
	pha
	ldy #1
@draw:
	lda tilecolors0,x
	sta screen + 14 * 40 + 10,y
	sta screen + 15 * 40 + 10,y
	lda tilecolors1,x
	sta screen + 14 * 40 + 12,y
	sta screen + 15 * 40 + 12,y
	lda tilecolors2,x
	sta screen + 16 * 40 + 10,y
	lda tilecolors3,x
	sta screen + 16 * 40 + 12,y
	lda #DIST1_ITEM_YPOS + 24
	cmp max_item_draw_height
	bcs :+
	lda tilecolors2,x
	sta screen + 17 * 40 + 10,y
	lda tilecolors3,x
	sta screen + 17 * 40 + 12,y
:	dey
	bpl @draw
	pla
	jmp get_tile_addr

draw_tile_colors_3x:
	tax
	pha
	ldy #2
:	lda tilecolors0,x
	sta screen + 17 * 40 + 9,y
	sta screen + 18 * 40 + 9,y
	sta screen + 19 * 40 + 9,y
	lda tilecolors1,x
	sta screen + 17 * 40 + 12,y
	sta screen + 18 * 40 + 12,y
	sta screen + 19 * 40 + 12,y
	lda tilecolors2,x
	sta screen + 20 * 40 + 9,y
	sta screen + 21 * 40 + 9,y
	sta screen + 22 * 40 + 9,y
	lda tilecolors3,x
	sta screen + 20 * 40 + 12,y
	sta screen + 21 * 40 + 12,y
	sta screen + 22 * 40 + 12,y
	dey
	bpl :-
	pla
	jmp get_tile_addr
