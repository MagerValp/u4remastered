	.include "uscii.i"


player_xpos		= $0010
player_ypos		= $0011
tile_xpos		= $0012
tile_ypos		= $0013
map_x			= $0014
map_y			= $0015
new_x			= $0016
new_y			= $0017
britannia_x		= $0018
britannia_y		= $0019
current_location	= $001a
game_mode		= $001b
dungeon_level		= $001c
balloon_flying		= $001d
player_transport	= $001e
party_size		= $001f
dng_direction		= $0020
light_duration		= $0021
moon_phase_trammel	= $0022
moon_phase_felucca	= $0023
horse_mode		= $0024
player_has_spoken_to_lb = $0025
last_humility_check	= $0027
altar_room_principle	= $0028
last_found_reagent	= $002a
ship_hull		= $002b
move_counter		= $002c
key_buf 		= $0030
key_buf_len		= $0038
charptr 		= $003d
magic_aura		= $0046
aura_duration		= $0047
tile_under_player	= $0048
tile_north		= $0049
tile_south		= $004a
tile_east		= $004b
tile_west		= $004c
music_volume		= $004d
console_xpos		= $004e
console_ypos		= $004f
diskid			= $0050
numdrives		= $0051
currdisk_drive1 	= $0052
currdisk_drive2 	= $0053
currplayer		= $0054
hexnum			= $0056
bcdnum			= $0057
zptmp1			= $005a
damage			= $005c
reqdisk 		= $005e
currdrive		= $005f
lt_y			= $0060
lt_x			= $0061
lt_rwflag		= $0062
lt_addr_hi		= $0063
monster_type		= $0066
game_mode_temp		= $0068
moongate_tile		= $006d
moongate_xpos		= $006e
moongate_ypos		= $006f
tilerow 		= $0072
movement_mode		= $0074
direction		= $0075
delta_x 		= $0078
delta_y 		= $0079
temp_x			= $007a
temp_y			= $007b
ptr2			= $007c
ptr1			= $007e
j_waitkey		= $0800
j_player_teleport	= $0803
j_move_east		= $0806
j_move_west		= $0809
j_move_south		= $080c
j_move_north		= $080f
j_drawinterface 	= $0812
j_drawview		= $0815
j_update_britannia	= $0818
j_primm_xy		= $081e
j_primm 		= $0821
j_console_out		= $0824
j_clearbitmap		= $0827
j_mulax 		= $082a
j_get_stats_ptr 	= $082d
j_printname		= $0830
j_printbcd		= $0833
j_drawcursor		= $0836
j_drawcursor_xy 	= $0839
j_drawvert		= $083c
j_drawhoriz		= $083f
j_request_disk		= $0842
j_update_status 	= $0845
j_blocked_tile		= $0848
j_update_view		= $084b
j_rand			= $084e
j_loadsector		= $0851
j_playsfx		= $0854
j_update_view_combat	= $0857
j_getnumber		= $085a
j_getplayernum		= $085d
j_update_wind		= $0860
j_animate_view		= $0863
j_printdigit		= $0866
j_clearstatwindow	= $0869
j_animate_creatures	= $086c
j_centername		= $086f
j_print_direction	= $0872
j_clearview		= $0875
j_invertview		= $0878
j_centerstring		= $087b
j_printstring		= $087e
j_gettile_bounds	= $0881
j_gettile_britannia	= $0884
j_gettile_opposite	= $0887
j_gettile_currmap	= $088a
j_gettile_tempmap	= $088d
j_get_player_tile	= $0890
j_gettile_towne 	= $0893
j_gettile_dungeon	= $0896
div32			= $1572
div16			= $1573
mul32			= $1578
mul16			= $1579
j_fileio		= $a100
j_readblock		= $a103
j_loadtitle		= $a106
j_togglesnd		= $a109
j_kernalin		= $a10c
j_setirqv		= $a10f
j_clearkbd		= $a112
j_irqhandler		= $a115
party_stats		= $aa00
virtues_and_stats	= $ab00
torches 		= $ab08
gems			= $ab09
keys			= $ab0a
sextant 		= $ab0b
stones			= $ab0c
runes			= $ab0d
items			= $ab0e
threepartkey		= $ab0f
food_hi 		= $ab10
food_lo 		= $ab11
food_frac		= $ab12
gold			= $ab13
horn			= $ab15
wheel			= $ab16
skull			= $ab17
armour			= $ab18
weapons 		= $ab20
reagents		= $ab38
mixtures		= $ab40
map_status		= $ac00
object_xpos		= $ac20
object_ypos		= $ac40
object_tile		= $ac60
currmap 		= $ae00
tempmap 		= $ae80
inbuffer		= $af00
music_ctl		= $af20
music_nop		= $af23
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198
tile_color		= $e1b0
music_init		= $ec00


	.segment "OVERLAY"

use:
	jsr j_primm
	.byte "Which item:", $8d
	.byte 0

	jsr get_input
	jsr compare_keywords
	bpl keyword_matched
	jsr j_primm
	.byte $8d
	.byte "Not usable item!", $8d
	.byte 0

	rts

print_none_owned:
	jsr j_primm
	.byte $8d
	.byte "None owned!", $8d
	.byte 0

	rts

print_no_effect:
	jsr j_primm
	.byte $8d
	.byte "Hmm...No effect!", $8d
	.byte 0

	rts

keyword_matched:
	asl a
	tay
	lda keyword_handlers,y
	sta ptr1
	lda keyword_handlers+1,y
	sta ptr1+1
	jmp (ptr1)

keyword_handlers:
	.addr use_stone
	.addr use_bell
	.addr use_book
	.addr use_candle
	.addr use_key
	.addr use_horn
	.addr use_wheel
	.addr use_skull

use_stone:
	lda stones
	bne @have_stone
	jmp print_none_owned

@have_stone:
	jsr j_primm
	.byte $8d
	.byte "No place to", $8d
	.byte "use them!", $8d
	.byte 0

	rts

use_bell:
	lda items
	and #$04
	bne @have_bell
	jmp print_none_owned

@no_effect:
	jmp print_no_effect

@have_bell:
	lda #$e9
	cmp player_xpos
	bne @no_effect
	cmp player_ypos
	bne @no_effect
	lda items
	ora #$40
	sta items
	jsr j_primm
	.byte $8d
	.byte "The bell rings", $8d
	.byte "on and on!", $8d
	.byte 0

	rts

use_book:
	lda items
	and #$02
	bne @have_book
	jmp print_none_owned

@no_effect:
	jmp print_no_effect

@have_book:
	lda #$e9
	cmp player_xpos
	bne @no_effect
	cmp player_ypos
	bne @no_effect
	lda items
	and #$40
	beq @no_effect
	lda items
	ora #$20
	sta items
	jsr j_primm
	.byte $8d
	.byte "The words", $8d
	.byte "resonate with", $8d
	.byte "the ringing!", $8d
	.byte 0

	rts

use_candle:
	lda items
	and #$01
	bne @have_candle
	jmp print_none_owned

@no_effect:
	jmp print_no_effect

@have_candle:
	lda #$e9
	cmp player_xpos
	bne @no_effect
	cmp player_ypos
	bne @no_effect
	lda items
	and #$20
	beq @no_effect
	lda items
	ora #$10
	sta items
	jsr j_primm
	.byte $8d
	.byte "As you light the", $8d
	.byte "candle the earth", $8d
	.byte "trembles!", $8d
	.byte 0

	jsr shake_screen
	rts

use_key:
	lda threepartkey
	bne @no_effect
	jmp print_none_owned

@no_effect:
	jmp print_no_effect

use_horn:
	lda horn
	bne @have_horn
	jmp print_none_owned

@have_horn:
	jsr j_primm
	.byte $8d
	.byte "The horn sounds", $8d
	.byte "an eerie tone!", $8d
	.byte 0

	lda #$5f
	sta magic_aura
	lda #$0a
	sta aura_duration
	rts

use_wheel:
	lda wheel
	bne @have_wheel
	jmp print_none_owned

@have_wheel:
	lda player_transport
	cmp #$14
	bcc @ship
	jmp print_no_effect

@ship:
	lda ship_hull
	cmp #$50
	beq @not_damaged
	jmp print_no_effect

@not_damaged:
	lda #$99
	sta ship_hull
	jsr j_primm
	.byte $8d
	.byte "Once mounted,", $8d
	.byte "the wheel glows", $8d
	.byte "with a blue", $8d
	.byte "light!", $8d
	.byte 0

	rts

use_skull:
	lda skull
	cmp #$01
	beq @have_skull
	jmp print_none_owned

@have_skull:
	lda #$e9
	cmp player_xpos
	bne @not_at_abyss
	cmp player_ypos
	beq use_skull_at_abyss
@not_at_abyss:
	jsr j_primm
	.byte $8d
	.byte "You hold the", $8d
	.byte "evil skull of", $8d
	.byte "Mondain the", $8d
	.byte "wizard aloft....", $8d
	.byte 0

	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
	ldx #$07
	lda #$00
@clear:
	sta object_tile,x
	sta map_status,x
	dex
	bpl @clear
	jsr j_update_view
	lda #$07
	sta $6a
@next_virtue:
	ldy $6a
	lda #$05
	jsr dec_virtue
	dec $6a
	bpl @next_virtue
	jsr j_update_status
	rts

use_skull_at_abyss:
	jsr j_primm
	.byte $8d
	.byte "You cast the", $8d
	.byte "skull of Mondain", $8d
	.byte "into the abyss!", $8d
	.byte 0

	lda #$ff
	sta skull
	lda #$07
	sta $6a
@next_virtue:
	ldy $6a ; BUG FIX, was #$6a in original
	lda #$10
	jsr inc_virtue
	dec $6a
	bpl @next_virtue
	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
	rts

get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta $6a
@get_char:
	jsr j_waitkey
	cmp #$8d
	beq @got_input
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @get_char
	ldx $6a
	sta inbuffer,x
	jsr j_console_out
	inc $6a
	lda $6a
	cmp #$0f
	bcc @get_char
	bcs @got_input
@backspace:
	lda $6a
	beq @get_char
	dec $6a
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @get_char

@got_input:
	ldx $6a
	lda #$a0
@pad_spaces:
	sta inbuffer,x
	inx
	cpx #$06
	bcc @pad_spaces
	lda #$8d
	jsr j_console_out
	rts

compare_keywords:
	lda #$07
	sta $6a
@next:
	lda $6a
	asl a
	asl a
	tay
	ldx #$00
@compare:
	lda keywords,y
	cmp inbuffer,x
	bne @nomatch
	iny
	inx
	cpx #$04
	bcc @compare
	lda $6a
	rts

@nomatch:
	dec $6a
	bpl @next
	lda $6a
	rts

keywords:
	.byte "STON"
	.byte "BELL"
	.byte "BOOK"
	.byte "CAND"
	.byte "KEY "
	.byte "HORN"
	.byte "WHEE"
	.byte "SKUL"

shake_screen:
	lda #$06
	jsr j_playsfx
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
	ldx #$ae
@next:
	lda bmplineaddr_lo+9,x
	sta ptr1
	lda bmplineaddr_hi+9,x
	sta ptr1+1
	lda bmplineaddr_lo+7,x
	sta ptr2
	lda bmplineaddr_hi+7,x
	sta ptr2+1
	ldy #$b0
@copy:
	lda (ptr2),y
	sta (ptr1),y
	tya
	sec
	sbc #$08
	tay
	bne @copy
	jsr j_rand
	bmi @skip
	jsr j_togglesnd  ;BUGFIX: opcode was 'bit'
@skip:
	dex
	bne @next
	rts

shake_up:
	ldx #$00
@next:
	lda bmplineaddr_lo+8,x
	sta ptr1
	lda bmplineaddr_hi+8,x
	sta ptr1+1
	lda bmplineaddr_lo+10,x
	sta ptr2
	lda bmplineaddr_hi+10,x
	sta ptr2+1
	ldy #$b0
@copy:
	lda (ptr2),y
	sta (ptr1),y
	tya
	sec
	sbc #$08
	tay
	bne @copy
	jsr j_rand
	bmi @skip
	jsr j_togglesnd  ;BUGFIX: opcode was 'bit'
@skip:
	inx
	cpx #$ae
	bcc @next
	rts

inc_virtue:
	sta $59
	sed
	clc
	lda virtues_and_stats,y
	beq @store
	adc $59
	bcc @store
	lda #$99
@store:
	sta virtues_and_stats,y
	cld
	rts

dec_virtue:
	sta zptmp1
	sty $59
	lda virtues_and_stats,y
	beq @lost_an_eight
@continue:
	sed
	sec
	sbc zptmp1
	beq @underflow
	bcs @store
@underflow:
	lda #$01
@store:
	sta virtues_and_stats,y
	cld
	rts

@lost_an_eight:
	jsr j_primm
	.byte $8d
	.byte "Thou hast lost", $8d
	.byte "an eighth!", $8d
	.byte 0

	lda #$99
	ldy $59
	jmp @continue
