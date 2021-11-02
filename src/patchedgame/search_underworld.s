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
music_init		= $ec00


	.segment "OVERLAY"

search:
	lda current_location
	sec
	sbc #$11
	sta dungeon_number
	lda tile_under_player
	bne check_orb
print_you_find_nothing:
	jsr j_primm
	.byte $8d
	.byte "You find", $8d
	.byte "nothing!", $8d
	.byte 0

	rts

check_orb:
	and #$f0
	cmp #$70
	beq find_orb
	cmp #$90
	bne @check_fountain
	jmp find_fountain

@check_fountain:
	cmp #$b0
	bne print_you_find_nothing
	jmp find_stone

find_orb:
	jsr j_primm
	.byte $8d
	.byte "You find a", $8d
	.byte "magical ball...", $8d
	.byte "Who will touch", $8d
	.byte "it? ", 0

	jsr j_getplayernum
	jsr check_awake
	beq @awake
	jmp print_you_find_nothing

@awake:
	lda player_xpos
	sta new_x
	lda player_ypos
	sta new_y
	jsr j_gettile_dungeon
	lda #$00
	sta (ptr1),y
	ldy dungeon_number
	lda orb_damage,y
	jsr hurt_character
	ldy dungeon_number
	lda orb_strength,y
	beq @check_dex
	ldy #$13
	jsr increment_stat
	jsr j_primm
	.byte "Strength+5", $8d
	.byte 0

@check_dex:
	ldy dungeon_number
	lda orb_dexterity,y
	beq @check_int
	ldy #$14
	jsr increment_stat
	jsr j_primm
	.byte "Dexterity+5", $8d
	.byte 0

@check_int:
	ldy dungeon_number
	lda orb_intelligence,y
	beq @done
	ldy #$15
	jsr increment_stat
	jsr j_primm
	.byte "Intelligence+5", $8d
	.byte 0

@done:
	rts

find_fountain:
	jsr j_primm
	.byte $8d
	.byte "You find a", $8d
	.byte "fountain, who", $8d
	.byte "will drink? ", 0

	jsr j_getplayernum
	jsr check_awake
	beq @awake
	jmp print_you_find_nothing

@awake:
	lda tile_under_player
	and #$0f
	beq @no_effect
	cmp #$01
	beq @heal
	cmp #$02
	beq @hurt
	cmp #$03
	beq @check_cure
	cmp #$04
	beq @check_poisoned
@no_effect:
	jsr j_primm
	.byte $8d
	.byte "Hmmm--No effect!", $8d
	.byte 0

	rts

@heal:
	jsr j_primm
	.byte $8d
	.byte "Ahh--Refreshing!", $8d
	.byte 0

	jsr j_get_stats_ptr
	ldy #$1a
	lda (ptr1),y
	ldy #$18
	sta (ptr1),y
	lda #$00
	iny
	sta (ptr1),y
	rts

@hurt:
	jsr j_primm
	.byte $8d
	.byte "Bleck--Nasty!", $8d
	.byte 0

	lda #$01
	jsr hurt_character
	rts

@check_cure:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$d0
	beq @cure
	jmp @no_effect

@cure:
	lda #$c7
	sta (ptr1),y
	jsr j_primm
	.byte $8d
	.byte "Mmm--Delicious!", $8d
	.byte 0

	rts

@check_poisoned:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$d0
	bne @poison
	jmp @no_effect

@poison:
	lda #$d0
	sta (ptr1),y
	jsr j_primm
	.byte $8d
	.byte "ARGH-CHOKE-GASP!", $8d
	.byte 0

	lda #$01
	jsr hurt_character
	rts

find_stone:
	lda dungeon_number
	cmp #$07
	beq @find_nothing
	cmp #$06
	bne @check_stone
@find_nothing:
	jmp print_you_find_nothing

@check_stone:
	ldy dungeon_number
	lda bitmask,y
	and stones
	bne @find_nothing
	jsr j_primm
	.byte $8d
	.byte "You find the", $8d
	.byte 0

	jsr print_color
	jsr j_primm
	.byte " stone!", $8d
	.byte 0

	ldy dungeon_number
	lda bitmask,y
	ora stones
	sta stones
	sed
	clc
	lda virtues_and_stats+5
	beq @at_max
	adc #$05
	bcc @at_max
	lda #$99
@at_max:
	sta virtues_and_stats+5
	cld
	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$1c
	lda (ptr1),y
	sed
	clc
	adc #$02
	bcc @overflow
	lda #$99
	iny
	sta (ptr1),y
	dey
@overflow:
	sta (ptr1),y
	cld
	rts

print_color:
	lda dungeon_number
	beq @blue
	cmp #$01
	beq @yellow
	cmp #$02
	beq @red
	cmp #$03
	beq @green
	cmp #$04
	beq @orange
	jmp @purple

@blue:
	jsr j_primm
	.byte "blue", 0

	rts

@yellow:
	jsr j_primm
	.byte "yellow", 0

	rts

@red:
	jsr j_primm
	.byte "red", 0

	rts

@green:
	jsr j_primm
	.byte "green", 0

	rts

@orange:
	jsr j_primm
	.byte "orange", 0

	rts

@purple:
	jsr j_primm
	.byte "purple", 0

	rts

hurt_character:
	sta zptmp1
	jsr invert_status_line
	lda #$07
	jsr j_playsfx
	lda #$07
	jsr j_playsfx
	lda #$07
	jsr j_playsfx
	jsr invert_status_line
	jsr j_get_stats_ptr
	sed
	sec
	ldy #$18
	lda (ptr1),y
	sbc zptmp1
	cld
	bcs @alive
	lda #$00
	sta (ptr1),y
	iny
	sta (ptr1),y
	ldy #$12
	lda #$c4
	sta (ptr1),y
	rts

@alive:
	sta (ptr1),y
	rts

check_awake:
	lda currplayer
	beq @dead_or_sleeping
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c7
	beq @awake
	cmp #$d0
	beq @awake
@dead_or_sleeping:
	lda #$ff
	rts

@awake:
	lda #$00
	rts

invert_status_line:
	lda currplayer
	asl a
	asl a
	asl a
	tax
	lda bmplineaddr_lo,x
	clc
	adc #$c0
	sta ptr1
	lda bmplineaddr_hi,x
	adc #$c0
	sta ptr1+1
	ldy #$00
@invert:
	lda (ptr1),y
	eor #$ff
	sta (ptr1),y
	iny
	cpy #$78
	bne @invert
	rts

increment_stat:
	sta zptmp1
	sty $59
	jsr j_get_stats_ptr
	sed
	clc
	ldy $59
	lda (ptr1),y
	adc zptmp1
	cld
	cmp #$51
	bcc @max50
	lda #$50
@max50:
	sta (ptr1),y
	rts

bitmask:
	.byte $80, $40, $20, $10, 8, 4, 2, 1
orb_strength:
	.byte 0, 0, 5, 0, 5, 5, 5, 0
orb_dexterity:
	.byte 0, 5, 0, 5, 5, 0, 5, 0
orb_intelligence:
	.byte 5, 0, 0, 5, 0, 5, 5, 0
orb_damage:
	.byte 2, 2, 2, 4, 4, 4, 8, 8
dungeon_number:
	.byte 0
