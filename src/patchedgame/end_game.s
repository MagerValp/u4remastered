	.include "uscii.i"

;
; **** ZP ABSOLUTE ADRESSES ****
;
player_xpos = $10
player_ypos = $11
current_location = $1a
game_mode = $1b
party_size = $1f
move_counter = $2c
;move_counter + 1 = $2d
;move_counter + 2 = $2e
;move_counter + 3 = $2f
sfx_volume = $4d
console_xpos = $4e
zp_input_index = $6a
ptr2 = $7c
;ptr2 + 1 = $7d
ptr1 = $7e
;ptr1 + 1 = $7f
;
; **** ZP POINTERS ****
;
;ptr2 = $7c
;ptr1 = $7e
;
; **** USER LABELS ****
;
screen = $0400
;(screen + 40) = $0428

j_waitkey = $0800
j_player_teleport = $0803
j_primm = $0821
j_console_out = $0824
j_request_disk = $0842
j_update_status = $0845
j_rand = $084e
j_clearview = $0875

bitmap = $2000
;(bitmap + 8 * ((40*1)+1)) = $2148
;(bitmap + 8 * ((40*3)+3)) = $23d8

j_game_init = $4009
j_fileio = $a100
j_togglesnd = $a109

party_stats = $ab00
threepartkey = $ab0f

inbuffer = $af00
music_ctl = $af20

bmplineaddr_lo = $e000
;bmplineaddr_lo + 7 = $e007
;bmplineaddr_lo + 8 = $e008
;bmplineaddr_lo + 9 = $e009
;bmplineaddr_lo + 10 = $e00a
bmplineaddr_hi = $e0c0
;bmplineaddr_hi + 7 = $e0c7
;bmplineaddr_hi + 8 = $e0c8
;bmplineaddr_hi + 9 = $e0c9
;bmplineaddr_hi + 10 = $e0ca
chrlineaddr_lo = $e180
chrlineaddr_hi = $e198

TMP_ADDR = $ffff

end_graphics  = $4000
image_addr_00 = $4a20
image_addr_01 = $4b00
image_addr_02 = $4c00
image_addr_03 = $4ce0
image_addr_04 = $4dc0
image_addr_05 = $4ea0
image_addr_06 = $4fc0
image_addr_07 = $5000
image_addr_08 = $5270
image_addr_09 = $5300
image_addr_0a = $53a0
image_addr_0b = $5440
image_addr_0c = $56c0



char_enter = $8d
char_space = $a0
char_num_first = $b0
char_question = $bf

disk_program = $01
disk_britannia = $02

file_cmd_Load = $cc

key3_have_all = $07

loc_world = $00

mode_suspended = $00
mode_world = $01

music_British = $c2

repeat_marker = $ff

virtue_last = $08


	.segment "OVERLAY"

j_overlay:
	lda #file_cmd_Load
	ldx #$9b     ;end_graphics
	jsr j_fileio
	lda party_size
	sta save_party_size
	lda #$01
	sta party_size
	lda #mode_suspended
	sta game_mode
	jsr j_update_status
	jsr j_clearview
	jsr clear_colors
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte $8d
	.byte "There is a", $8d
	.byte "sudden darkness,", $8d
	.byte "and you find", $8d
	.byte "yourself alone", $8d
	.byte "in an empty", $8d
	.byte "chamber.", $8d
	.byte 0
	lda #$04
	jsr delay
	lda #$0c
	jsr draw_packed_image
	lda threepartkey
	and #key3_have_all
	cmp #key3_have_all
	beq @have_three_part_key
	jsr j_primm
	.byte $8d
	.byte "Thou dost not", $8d
	.byte "have the key of", $8d
	.byte "three parts.", $8d
	.byte 0
	lda #$0c     ;abyss
	jmp return_to_world

@have_three_part_key:
	jsr j_primm
	.byte $8d
	.byte "You use your", $8d
	.byte "key of three", $8d
	.byte "parts.", $8d
	.byte 0
	lda #$03
	jsr delay
	jsr j_primm
	.byte $8d
	.byte "A voice rings", $8d
	.byte "out, 'What is", $8d
	.byte "the Word of", $8d
	.byte "Passage?'", $8d
	.byte $8d
	.byte 0
	jsr get_input
	jsr match_input_inline
	.byte "VERAMOCOR", 0
	php
	lda #$03
	jsr delay
	plp
	bne @denied
	lda save_party_size
	cmp #$08
	beq @check_virtues
	jsr j_primm
	.byte $8d
	.byte "Thou hast not", $8d
	.byte "proved thy", $8d
	.byte "leadership in", $8d
	.byte "all eight", $8d
	.byte "virtues.", $8d
	.byte 0
	lda #$08
	jsr delay
	jmp @denied

@check_virtues:
	ldy #virtue_last - 1
:	lda party_stats,y
	bne @not_avatar
	dey
	bpl :-
	bmi @granted
@not_avatar:
	jsr j_primm
	.byte $8d
	.byte "Thou art not", $8d
	.byte "ready.", $8d
	.byte 0
@denied:
	jsr j_primm
	.byte $8d
	.byte "Passage is not", $8d
	.byte "granted.", $8d
	.byte 0
	lda #$0c     ;abyss
	jmp return_to_world

@granted:
	jsr j_primm
	.byte $8d
	.byte "Passage is", $8d
	.byte "granted.", $8d
	.byte 0
	lda #$05
	jsr delay
	jsr j_clearview
	jsr clear_colors
	lda #$01
	sta question_number
@ask_question:
	jsr voice_asks
	beq @correct
	jsr j_primm
	.byte $8d
	.byte "Thy quest is not", $8d
	.byte "yet complete.", $8d
	.byte 0
	dec question_number
	lda question_number
	jmp return_to_world

@correct:
	ldx question_number
	dex
	txa
	jsr draw_packed_image
	inc question_number
	lda question_number
	cmp #$09
	bne @next_question
	lda #$03
	jsr delay
	jsr j_primm
	.byte $8d
	.byte "The voice says:", $8d
	.byte 0
	lda #$03
	jsr delay
	jsr j_primm
	.byte $8d
	.byte "Thou art well", $8d
	.byte "versed in the", $8d
	.byte "virtues of the", $8d
	.byte "Avatar.", $8d
	.byte 0
	lda #$05
	jsr delay
	jmp @ask_question

@next_question:
	cmp #$0c
	bcs @ask_final_question
	jmp @ask_question

@ask_final_question:
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "The floor", $8d
	.byte "rumbles beneath", $8d
	.byte "your feet.", $8d
	.byte 0
	jsr shake_screen
	jsr shake_screen
	lda #$05
	jsr delay
	jsr j_primm
	.byte $8d
	.byte "Above the din,", $8d
	.byte "the voice asks:", $8d
	.byte 0
	lda question_number
	jsr print_string
	jsr waitkey
	inc question_number ;skip unused answer "SELF"
	jsr input_answer
	beq game_over_win
	jsr j_primm
	.byte $8d
	.byte "Thou dost not", $8d
	.byte "know the true", $8d
	.byte "nature of the", $8d
	.byte "Universe.", $8d
	.byte 0
	lda #$0b
	jmp return_to_world

game_over_win:
	lda #$02
	jsr delay
	jsr shake_screen
	jsr shake_screen
	jsr shake_screen
	jsr shake_screen
	lda #$03
	jsr delay
	jsr anim_open_door
	lda #$03
	jsr delay
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "The boundless", $8d
	.byte "knowledge of the", $8d
	.byte "Codex of", $8d
	.byte "Ultimate Wisdom", $8d
	.byte "is revealed unto", $8d
	.byte "thee.", 0
	lda #music_British
	jsr music_ctl
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "The voice says:", $8d
	.byte "Thou hast proven", $8d
	.byte "thyself to be", $8d
	.byte "truly good in", $8d
	.byte "nature.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "Thou must know", $8d
	.byte "that thy quest", $8d
	.byte "to become an", $8d
	.byte "Avatar is the", $8d
	.byte "endless quest of", $8d
	.byte "a lifetime.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "Avatarhood is a", $8d
	.byte "living gift. It", $8d
	.byte "must always and", $8d
	.byte "forever be", $8d
	.byte "nurtured to", $8d
	.byte "flourish.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "For if thou dost", $8d
	.byte "stray from the", $8d
	.byte "paths of virtue,", $8d
	.byte "thy way may be", $8d
	.byte "lost forever.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "Return now unto", $8d
	.byte "thine own world,", $8d
	.byte "live there as an", $8d
	.byte "example to thy", $8d
	.byte "people, as our", $8d
	.byte "memory of thy", $8d
	.byte "gallant deeds", $8d
	.byte "serves us.", 0
	jsr waitkey
	jsr j_clearview
	jsr clear_colors
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "As the sound of", $8d
	.byte "the voice trails", $8d
	.byte "off, darkness", $8d
	.byte "seems to rise", $8d
	.byte "around you.", $8d
	.byte "There is a", $8d
	.byte "moment of", $8d
	.byte "intense, ", $8d
	.byte "wrenching", $8d
	.byte "vertigo.", 0
	jsr waitkey
	lda #$0b
	jsr draw_packed_image
	jsr set_win_colors
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "You open your", $8d
	.byte "eyes to a", $8d
	.byte "familiar circle", $8d
	.byte "of stones. You", $8d
	.byte "wonder of your", $8d
	.byte "recent", $8d
	.byte "adventures.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "It seems a time", $8d
	.byte "and place very", $8d
	.byte "distant. You", $8d
	.byte "wonder if it", $8d
	.byte "really happened.", $8d
	.byte "Then you realize", $8d
	.byte "that in your", $8d
	.byte "hand you hold", $8d
	.byte "The Ankh.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "You walk away", $8d
	.byte "from the circle,", $8d
	.byte "knowing that", $8d
	.byte "you can always", $8d
	.byte "return from", $8d
	.byte "whence you came,", $8d
	.byte "since you now", $8d
	.byte "know the secret", $8d
	.byte "of the gates.", 0
	jsr waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "CONGRATULATIONS!", $8d
	.byte "   Thou hast", $8d
	.byte "   completed", $8d
	.byte "   ULTIMA IV", $8d
	.byte "  Quest of the", $8d
	.byte "     AVATAR", $8d
	.byte "  in ", 0
	lda #$00
	sta leading_spaces
	lda move_counter
	jsr print_bcd
	lda move_counter + 1
	jsr print_bcd
	lda move_counter + 2
	jsr print_bcd
	lda move_counter + 3
	jsr print_bcd
	jsr j_primm
	.byte $8d
	.byte " turns! Report", $8d
	.byte " thy feat unto", $8d
	.byte "Lord British at", $8d
	.byte "Origin Systems!", 0
halt:
	jmp halt

set_win_colors:
	ldx #$16
@next_row:
	ldy #$16
	lda chrlineaddr_lo,x
	sta ptr1
	lda chrlineaddr_hi,x
	sta ptr1 + 1
	cpx #$05
	bcs @grass
	lda #$65     ;dark_blue on dark_green
	jmp @next_col

@grass:
	lda #$15     ;white on dark_green
@next_col:
	sta (ptr1),y
	dey
	bne @next_col
	dex
	bne @next_row
	rts

leading_spaces:
	.byte 0

print_bcd:
	pha
	lsr
	lsr
	lsr
	lsr
	jsr print_digit
	pla
	and #$0f
print_digit:
	cmp #$00
	bne @end_spaces
	ldx leading_spaces
	bne @allow_zeroes
	lda #char_space
	bne @print
@end_spaces:
	inc leading_spaces
@allow_zeroes:
	clc
	adc #char_num_first
@print:
	jsr j_console_out
	rts

return_to_world:
	pha
	lda #$05
	jsr delay
	jsr j_primm
	.byte $8d
	.byte 0
	lda #disk_program
	jsr insert_disk
	lda #file_cmd_Load
	ldx #$5b
	jsr j_fileio
	lda #disk_britannia
	jsr j_request_disk
	pla
	tay
	lda world_location_y,y
	sta player_ypos
	lda world_location_x,y
	sta player_xpos
	lda save_party_size
	sta party_size
	lda #loc_world
	sta current_location
	lda #mode_world
	sta game_mode
	jsr j_player_teleport
	jmp j_game_init

world_location_x:
	.byte $e7,$53,$23,$3b,$9e,$69,$17,$ba
	.byte $d8,$1d,$91,$59,$e9
world_location_y:
	.byte $88,$69,$dd,$2c,$15,$b7,$81,$ac
	.byte $6a,$30,$f3,$6a,$e9

insert_disk:
	jsr j_request_disk
	nop
	rts

voice_asks:
	lda #$02
	jsr delay
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "The voice asks:", $8d
	.byte 0
input_answer:
	lda #$02
	jsr delay
	lda question_number
	jsr print_string
	jsr get_input
	lda question_number
	sec
	sbc #$01
	asl
	asl
	clc
	adc #<answer_table
	sta ptr1
	lda #>answer_table
	adc #$00
	sta ptr1 + 1
	ldy #$03
@copy_keyword:
	lda (ptr1),y
	sta keyword_compare,y
	dey
	bpl @copy_keyword
	jsr match_input_inline
keyword_compare:
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	rts

answer_table:
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte "TRUT"
	.byte "LOVE"
	.byte "COUR"
	.byte "SELF"   ; unused
	.byte "INFI"

waitkey:
	jsr j_waitkey
	bpl waitkey
	rts

save_party_size:
	.byte 0
question_number:
	.byte 0

delay:
	sta ptr1
@count:
	ldy #$c0
@outer:
	ldx #$ff
@inner:
	pha
	pla
	dex
	bne @inner
	dey
	bne @outer
	dec ptr1
	bne @count
	rts

match_input_inline:
	lda #$00
	sta @mismatch
	pla
	sta @ptr
	pla
	sta @ptr + 1
	ldx #$ff
@next:
	inc @ptr
	bne :+
	inc @ptr + 1
:	inx
@ptr=*+$01
	lda TMP_ADDR
	beq @done
	cmp inbuffer,x
	beq @next
	lda #$01
	sta @mismatch
	bne @next
@done:
	lda @ptr + 1
	pha
	lda @ptr
	pha
	lda @mismatch
	rts

@mismatch:
	.byte 0

get_input:
	lda #$00
	sta zp_input_index
	lda #char_question
	jsr j_console_out
@get_char:
	jsr waitkey
	cmp #char_enter
	beq @got_input
	cmp #$94     ;char_DEL
	beq @backspace
	cmp #char_space
	bcc @get_char
	ldx zp_input_index
	cpx #$0e
	beq @get_char
	sta inbuffer,x
	jsr j_console_out
	inc zp_input_index
	jmp @get_char

@backspace:
	lda zp_input_index
	beq @get_char
	dec zp_input_index
	lda #char_space
	jsr j_console_out
	dec console_xpos
	dec console_xpos
	lda #char_space
	jsr j_console_out
	dec console_xpos
	jmp @get_char

@got_input:
	ldx zp_input_index
	beq @get_char
	lda #$00
@pad_zeroes:
	sta inbuffer,x
	inx
	cpx #$0f
	bcc @pad_zeroes
	lda #char_enter
	jsr j_console_out
	rts

shake_screen:
	jsr shake_up
	jsr shake_down
	jsr shake_up
	jsr shake_down
	jsr shake_up
	jsr shake_down
	jsr shake_up
	jsr shake_down
	rts

shake_down:
	ldx #8 * 22 - 2
@next:
	lda bmplineaddr_lo + 9,x
	sta ptr1
	lda bmplineaddr_hi + 9,x
	sta ptr1 + 1
	lda bmplineaddr_lo + 7,x
	sta ptr2
	lda bmplineaddr_hi + 7,x
	sta ptr2 + 1
	ldy #8 * 22
@copy:
	lda (ptr2),y
	sta (ptr1),y
	tya
	sec
	sbc #$08
	tay
	bne @copy
	bit sfx_volume
	bpl @skip
	jsr j_rand
	bmi @skip
	jsr j_togglesnd
@skip:
	dex
	bne @next
	rts

shake_up:
	ldx #$00
@next:
	lda bmplineaddr_lo + 8,x
	sta ptr1
	lda bmplineaddr_hi + 8,x
	sta ptr1 + 1
	lda bmplineaddr_lo + 10,x
	sta ptr2
	lda bmplineaddr_hi + 10,x
	sta ptr2 + 1
	ldy #8 * 22
@copy:
	lda (ptr2),y
	sta (ptr1),y
	tya
	sec
	sbc #$08
	tay
	bne @copy
	bit sfx_volume
	bpl @skip
	jsr j_rand
	bmi @skip
	jsr j_togglesnd
@skip:
	inx
	cpx #8 * 22 - 2
	bcc @next
	rts

print_string:
	tay
	lda #<string_table
	sta ptr1
	lda #>string_table
	sta ptr1 + 1
	ldx #$00
@next_char:
	lda (ptr1,x)
	beq @end_string
@next_string:
	jsr inc_ptr
	jmp @next_char

@end_string:
	dey
	beq @print_char
	jmp @next_string

@print_char:
	jsr inc_ptr
	ldx #$00
	lda (ptr1,x)
	beq @done
	jsr j_console_out
	jmp @print_char

@done:
	rts

inc_ptr:
	inc ptr1
	bne :+
	inc ptr1 + 1
:	rts

clear_colors:
	lda #<(screen + 40)
	sta ptr1
	lda #>(screen + 40)
	sta ptr1 + 1
	ldx #$16
@next_row:
	ldy #$16
	lda #$10     ;white on black
@next_col:
	sta (ptr1),y
	dey
	bne @next_col
	lda ptr1
	clc
	adc #$28     ;40
	sta ptr1
	lda ptr1 + 1
	adc #$00
	sta ptr1 + 1
	dex
	bne @next_row
	rts

anim_open_door:
	ldx #$08
@next_line:
	lda bmplineaddr_lo,x
	sta ptr1
	lda bmplineaddr_hi,x
	sta ptr1 + 1
	ldy #$58
	lda #$03     ;left door edge
	ora (ptr1),y
	sta (ptr1),y
	ldy #$60
	lda #$c0     ;right door edge
	ora (ptr1),y
	sta (ptr1),y
	inx
	cpx #8*23
	bne @next_line
	lda #$00
	sta @anim_frame
@next_frame:
	lda @anim_frame
	sta @anim_col
@next_col:
	lda #$00
	sta @anim_row
@next_row:
	lda @anim_col
	sec
	sbc @anim_frame
	sta cell_col_dst
	clc
	adc #$01
	sta cell_col_src
	lda @anim_row
	sta cell_row
	jsr copy_cell
	lda @anim_col
	cmp #$09
	bne @scroll_left_done
	inc cell_col_dst
	jsr copy_revealed_cell
@scroll_left_done:
	lda #$15
	sec
	sbc @anim_col
	clc
	adc @anim_frame
	sta cell_col_dst
	sec
	sbc #$01
	sta cell_col_src
	jsr copy_cell
	lda @anim_col
	cmp #$09
	bne @scroll_right_done
	dec cell_col_dst
	jsr copy_revealed_cell
@scroll_right_done:
	inc @anim_row
	lda @anim_row
	cmp #$16
	bcc @next_row
	inc @anim_col
	lda @anim_col
	cmp #$0a
	bcc @next_col
	inc @anim_frame
	lda @anim_frame
	cmp #$0b
	bcc @next_frame
	rts

@anim_frame:
	.byte $41
@anim_col:
	.byte $33
@anim_row:
	.byte $20
cell_col_src:
	.byte $20
cell_col_dst:
	.byte $20
cell_row:
	.byte $20

; src = end_graphics + (row-2) * 8 * 18  ;window 22 with margin 2 on either side
copy_revealed_cell:
	lda cell_row
	sec
	sbc #$02
	asl
	asl
	asl
	pha
	sta ptr2
	lda #$00
	sta ptr2 + 1
	asl ptr2
	rol ptr2 + 1
	asl ptr2
	rol ptr2 + 1
	asl ptr2
	rol ptr2 + 1
	pla
	clc
	adc ptr2
	sta ptr2
	bcc :+
	inc ptr2 + 1
:	asl ptr2
	rol ptr2 + 1
	lda ptr2
	clc
	adc #<end_graphics
	sta ptr2
	lda ptr2 + 1
	adc #>end_graphics
	sta ptr2 + 1

; dst = bitmap_line[ (row+1)*8 ]
	lda cell_row
	clc
	adc #$01
	asl
	asl
	asl
	tay
	lda bmplineaddr_lo,y
	sta ptr1
	lda bmplineaddr_hi,y
	sta ptr1 + 1

; src += (col-2)*8
	lda cell_col_src
	sec
	sbc #$02
	asl
	asl
	asl
	adc ptr2
	sta ptr2
	bcc :+
	inc ptr2 + 1

; dst += (col+1)*8
:	lda cell_col_dst
	clc
	adc #$01
	asl
	asl
	asl
	adc ptr1
	sta ptr1
	bcc :+
	inc ptr1 + 1

; copy from src if in-bounds, else from zero8
:	lda cell_row
	cmp #$02
	bcc @src_clear
	cmp #$14
	bcs @src_clear
	lda cell_col_src
	cmp #$02
	bcc @src_clear
	cmp #$14
	bcs @src_clear
	jmp @copy_cell

@src_clear:
	lda #<zero8
	sta ptr2
	lda #>zero8
	sta ptr2 + 1
@copy_cell:
	ldy #$07
@next:
	lda (ptr2),y
	sta (ptr1),y
	dey
	bpl @next
	rts

copy_cell:
	lda cell_row
	clc
	adc #$01
	asl
	asl
	asl
	tay
	lda bmplineaddr_lo,y
	sta ptr2
	sta ptr1
	lda bmplineaddr_hi,y
	sta ptr2 + 1
	sta ptr1 + 1
	lda cell_col_src
	clc
	adc #$01
	asl
	asl
	asl
	adc ptr2
	sta ptr2
	bcc :+
	inc ptr2 + 1
:	lda cell_col_dst
	clc
	adc #$01
	asl
	asl
	asl
	adc ptr1
	sta ptr1
	bcc :+
	inc ptr1 + 1
:	ldy #$07
@copy_cell:
	lda (ptr2),y
	sta (ptr1),y
	dey
	bpl @copy_cell
	rts

zero8:
	.byte 0, 0, 0, 0, 0, 0, 0, 0

draw_packed_image:
	asl
	tax
	lda image_addr_table,x
	sta ptr2
	lda image_addr_table+1,x
	sta ptr2 + 1
	cpx #$16     ;final image fills entire window
	bne @inset_image

@full_image:
	lda #<(bitmap + 8 * ((40*1)+1))
	sta ptr1
	lda #>(bitmap + 8 * ((40*1)+1))
	sta ptr1 + 1
	lda #8 * 22
	sta set_pix_block_size
	sta set_pix_remain
	lda #8 * 18
	sta set_pix_block_gap
	jmp @next_code

@inset_image:
	lda #<(bitmap + 8 * ((40*3)+3))
	sta ptr1
	lda #>(bitmap + 8 * ((40*3)+3))
	sta ptr1 + 1
	lda #8 * 18
	sta set_pix_block_size
	sta set_pix_remain
	lda #8 * 22
	sta set_pix_block_gap

@next_code:
	jsr read_byte
	cmp #$00
	beq @done
	cmp #repeat_marker
	bne @literal_sequence

@repeat_sequence:
	jsr read_byte
	sta @repeat_count
	jsr read_byte
@repeat:
	jsr set_pixels
	dec @repeat_count
	bne @repeat
	beq @next_code

@literal_sequence:
	jsr read_byte
	sta @literal_count
@literal:
	jsr read_byte
	jsr set_pixels
	dec @literal_count
	bne @literal
	beq @next_code

@done:
	rts

@repeat_count:
	.byte $50
@unused:
	.byte $45
@literal_count:
	.byte $52

read_byte:
	sty @save_reg_y
	ldy #$00
	lda (ptr2),y
	inc ptr2
	bne :+
	inc ptr2 + 1
:	ldy @save_reg_y
	rts

@save_reg_y:
	.byte $20

set_pixels:
	sty @save_reg_y
	sta @save_reg_a
	ldy #$00
	ora (ptr1),y
	sta (ptr1),y
	inc ptr1
	bne :+
	inc ptr1 + 1
:	dec set_pix_remain
	bne @done
	lda set_pix_block_size
	sta set_pix_remain
	lda ptr1
	clc
	adc set_pix_block_gap
	sta ptr1
	bcc @done
	inc ptr1 + 1
@done:
	lda @save_reg_a
	ldy @save_reg_y
	rts

@save_reg_a:
	.byte $24
@save_reg_y:
	.byte $36
set_pix_remain:
	.byte $36
set_pix_block_size:
	.byte $0d
set_pix_block_gap:
	.byte $0e

image_addr_table:
	.addr image_addr_00
	.addr image_addr_01
	.addr image_addr_02
	.addr image_addr_03
	.addr image_addr_04
	.addr image_addr_05
	.addr image_addr_06
	.addr image_addr_07
	.addr image_addr_08
	.addr image_addr_09
	.addr image_addr_0a
	.addr image_addr_0b
	.addr image_addr_0c

string_table:
; STRING $00 (0)
	.byte 0
; STRING $01 (1)
	.byte $8d
	.byte "What dost thou", $8d
	.byte "possess if all", $8d
	.byte "may rely upon", $8d
	.byte "your every word?", $8d
	.byte 0
; STRING $02 (2)
	.byte $8d
	.byte "What quality", $8d
	.byte "compels one to", $8d
	.byte "share in the", $8d
	.byte "journeys of", $8d
	.byte "others?", $8d
	.byte 0
; STRING $03 (3)
	.byte $8d
	.byte "What answers", $8d
	.byte "when great deeds", $8d
	.byte "are called for?", $8d
	.byte 0
; STRING $04 (4)
	.byte $8d
	.byte "What should be", $8d
	.byte "the same for", $8d
	.byte "Lord and Serf", $8d
	.byte "alike?", $8d
	.byte 0
; STRING $05 (5)
	.byte $8d
	.byte "What is loath", $8d
	.byte "to place the", $8d
	.byte "self above aught", $8d
	.byte "else?", $8d
	.byte 0
; STRING $06 (6)
	.byte $8d
	.byte "What shirks no", $8d
	.byte "duty?", $8d
	.byte 0
; STRING $07 (7)
	.byte $8d
	.byte "What, in knowing", $8d
	.byte "the true self,", $8d
	.byte "knows all?", $8d
	.byte 0
; STRING $08 (8)
	.byte $8d
	.byte "What is that", $8d
	.byte "which Serfs are", $8d
	.byte "born with but", $8d
	.byte "Nobles must", $8d
	.byte "strive to", $8d
	.byte "obtain?", $8d
	.byte 0
; STRING $09 (9)
	.byte $8d
	.byte "If all else is", $8d
	.byte "imaginary, this", $8d
	.byte "is real...", $8d
	.byte 0
; STRING $0A (10)
	.byte $8d
	.byte "What plunges to", $8d
	.byte "the depths,", $8d
	.byte "while soaring on", $8d
	.byte "the heights?", $8d
	.byte 0
; STRING $0B (11)
	.byte $8d
	.byte "What turns not", $8d
	.byte "away from any", $8d
	.byte "peril?", $8d
	.byte 0
; STRING $0C (12)
	.byte $8d
	.byte "If all eight", $8d
	.byte "virtues of the", $8d
	.byte "Avatar combine", $8d
	.byte "into and are", $8d
	.byte "derived from the", $8d
	.byte "three principles", $8d
	.byte "of Truth, Love,", $8d
	.byte "and Courage...", 0
; STRING $0D (13)
	.byte $8d
	.byte $8d
	.byte "then what is the", $8d
	.byte "one thing which", $8d
	.byte "encompasses and", $8d
	.byte "is the whole of", $8d
	.byte "all undeniable", $8d
	.byte "Truth, unending", $8d
	.byte "Love, and", $8d
	.byte "unyielding", $8d
	.byte "Courage?", $8d
	.byte 0

junk:
;                      "AE10"
; $10,"DMSX    ",$d9," $AE20"
; $10,"DMSY    ",$d9," $AE30"
; $10,"DPSX    ",$d9," $AE40"
; $10,"DPSY    ",$d9," $AE48"
; $02,";"
; $10,"MONX    ",$d9," $AD00"
; $10,"MONY    ",$d9," $AD10"
; $10,"OMONX   ",$d9," $AD20"
; $10,"O"

;	.byte $41,$45,$31,$30,$0d,$10,$44,$4d
;	.byte $53,$58,$20,$20,$20,$20,$d9,$20
;	.byte $24,$41,$45,$32,$30,$0d,$10,$44
;	.byte $4d,$53,$59,$20,$20,$20,$20,$d9
;	.byte $20,$24,$41,$45,$33,$30,$0d,$10
;	.byte $44,$50,$53,$58,$20,$20,$20,$20
;	.byte $d9,$20,$24,$41,$45,$34,$30,$0d
;	.byte $10,$44,$50,$53,$59,$20,$20,$20
;	.byte $20,$d9,$20,$24,$41,$45,$34,$38
;	.byte $0d,$02,$3b,$0d,$10,$4d,$4f,$4e
;	.byte $58,$20,$20,$20,$20,$d9,$20,$24
;	.byte $41,$44,$30,$30,$0d,$10,$4d,$4f
;	.byte $4e,$59,$20,$20,$20,$20,$d9,$20
;	.byte $24,$41,$44,$31,$30,$0d,$10,$4f
;	.byte $4d,$4f,$4e,$58,$20,$20,$20,$d9
;	.byte $20,$24,$41,$44,$32,$30,$0d,$10
;	.byte $4f

; 3 empty sectors
;	.byte     $4b,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$4b,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$4b,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01,$01,$01,$01,$01,$01,$01,$01
;	.byte $01
