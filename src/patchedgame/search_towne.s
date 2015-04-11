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
map_buf			= $8b00
L9000			= $9000
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
music_ctl		= $af20
music_nop		= $af23
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198
tile_color		= $e1b0
gem_buf 		= $e800
music_init		= $ec00


	.segment "OVERLAY"

search:
	ldy #$0c
@next:
	jsr compare_position
	beq item_at_coordinate
	dey
	bpl @next
print_nothing_here:
	jsr j_primm
	.byte "NOTHING HERE!", $8d
	.byte 0

	rts

item_at_coordinate:
	cpy #$08
	bcc find_rune
	beq find_book
	cpy #$09
	beq find_candle
	cpy #$0a
	bne @check_armour
	jmp find_telescope

@check_armour:
	cpy #$0b
	bne @check_weapons
	jmp find_mystic_armour

@check_weapons:
	jmp find_mysic_weapons

find_rune:
	lda bitmask,y
	and runes
	bne print_nothing_here
	lda runes
	ora bitmask,y
	sta runes
	sty $58
	jsr print_you_find
	jsr j_primm
	.byte "The rune of", $8d
	.byte 0

	lda $58
	clc
	adc #$97
	jsr j_printstring
	jsr j_primm
	.byte "!", $8d
	.byte 0

	lda #$01
	jsr add_xp100
	rts

find_book:
	lda items
	and #$02
	beq @found
	jmp print_nothing_here

@found:
	lda items
	ora #$02
	sta items
	jsr print_you_find
	jsr j_primm
	.byte "The book", $8d
	.byte "of truth!", $8d
	.byte 0

	lda #$04
	jsr add_xp100
	rts

find_candle:
	lda items
	and #$01
	beq @found
	jmp print_nothing_here

@found:
	lda items
	ora #$01
	sta items
	jsr print_you_find
	jsr j_primm
	.byte "The candle", $8d
	.byte "of love!", $8d
	.byte 0

	lda #$04
	jsr add_xp100
	rts

find_telescope:
	jsr j_primm
	.byte "You see a knob", $8d
	.byte "on the telescope", $8d
	.byte "marked A-P", $8d
	.byte "You select:", 0

@waitkey:
	jsr j_waitkey
	beq @waitkey
	pha
	jsr j_console_out
	lda #$8d
	jsr j_console_out
	pla
	cmp #$c1
	bcc @nothing_here
	cmp #$d1
	bcc @view_location
@nothing_here:
	jmp print_nothing_here

@view_location:
	sec
	sbc #$c1
	clc
	adc #$5c
	tax
	lda #$cc
	jsr j_fileio
	jsr copymap
	lda #$cc
	ldx #$77
	jsr j_fileio
	lda #$00
	sta game_mode
	jsr L9000
	lda #$02
	sta game_mode
	lda #$cc
	ldx #$5d
	jsr j_fileio
	jsr copymap
	rts

copymap:
	ldx #$00
@copy:
	lda map_buf,x
	sta gem_buf,x
	lda map_buf+256,x
	sta gem_buf+256,x
	lda map_buf+512,x
	sta gem_buf+512,x
	lda map_buf+768,x
	sta gem_buf+768,x
	inx
	bne @copy
	rts

find_mystic_armour:
	ldx #$07
	lda #$00
@next_virtue:
	ora virtues_and_stats,x
	dex
	bpl @next_virtue
	cmp #$00
	beq @avatar
	jmp print_nothing_here

@avatar:
	lda armour+7
	beq @found
	jmp print_nothing_here

@found:
	jsr print_you_find
	jsr j_primm
	.byte "Mystic armour!", $8d
	.byte 0

	lda #$08
	sta armour+7
	lda #$04
	jsr add_xp100
	rts

find_mysic_weapons:
	ldx #$07
	lda #$00
@next_virtue:
	ora virtues_and_stats,x
	dex
	bpl @next_virtue
	cmp #$00
	beq @avatar
	jmp print_nothing_here

@avatar:
	lda weapons+15
	beq @found
	jmp print_nothing_here

@found:
	jsr print_you_find
	jsr j_primm
	.byte "Mystic weapons!", $8d
	.byte 0

	lda #$08
	sta weapons+15
	lda #$04
	jsr add_xp100
	rts

print_you_find:
	jsr j_primm
	.byte "You find...", $8d
	.byte 0

	sed
	clc
	lda virtues_and_stats+5
	beq @overflow
	adc #$05
	bcc @overflow
	lda #$99
@overflow:
	sta virtues_and_stats+5
	cld
	rts

bitmask:
	.byte $80, $40, $20, $10, 8, 4, 2, 1

compare_position:
	lda player_xpos
	cmp item_xpos,y
	bne @nothing_here
	lda player_ypos
	cmp item_ypos,y
	bne @nothing_here
	lda current_location
	cmp item_location,y
	bne @nothing_here
	lda #$00
	rts

@nothing_here:
	lda #$ff
	rts

item_xpos:
	.byte	$08,$19,$1E,$0D,$1C,$02,$11,$1D
	.byte	$06,$16,$16,$16,$08
item_ypos:
	.byte	$06,$01,$1E,$06,$1E,$1D,$08,$1D
	.byte	$06,$01,$03,$04,$0F
item_location:
	.byte	$05,$06,$07,$08,$09,$0A,$01,$0D
	.byte	$02,$10,$02,$03,$04

add_xp100:
	pha
	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$1c
	sed
	pla
	clc
	adc (ptr1),y
	bcc @overflow
	lda #$99
	iny
	sta (ptr1),y
	dey
@overflow:
	sta (ptr1),y
	cld
	rts
