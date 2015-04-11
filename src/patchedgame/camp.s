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
last_sleep		= $0026
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
sleep_counter		= $006a
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
L4006			= $4006
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
cbt_player_xpos 	= $ad80
cbt_player_ypos 	= $ad90
player_tile		= $ada0
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

camp:
	lda #$cc
	ldx #$0f
	jsr j_fileio
	lda #$00
	tax
@clear:
	sta $ad00,x
	dex
	bne @clear
	lda party_size
	sta currplayer
@place_next:
	jsr check_alive
	bmi @skip
	lda #$38
	ldx currplayer
	dex
	sta player_tile,x
	lda currmap+96,x
	sta cbt_player_xpos,x
	lda currmap+104,x
	sta cbt_player_ypos,x
@skip:
	dec currplayer
	bne @place_next
	jsr j_primm
	.byte "Resting...", $8d
	.byte 0

	lda #$4b
	sta sleep_counter
@sleep:
	jsr j_update_view_combat
	dec sleep_counter
	bne @sleep
	jsr j_rand
	and #$07
	bne check_sleep_effect
	jsr j_primm
	.byte "Ambushed!", $8d
	.byte 0

	jsr j_rand
	and #$07
	tay
	lda ambush_monsters,y
	sta $40
	sta monster_type
	lda player_xpos
	sta $41
	lda player_ypos
	sta $42
	lda party_size
	sta currplayer
@next_character:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c7
	bne :+
	lda #$d3
	sta (ptr1),y
:	dec currplayer
	bne @next_character
	lda #$cc
	ldx #$0f
	jsr j_fileio
	pla
	pla
	jmp L4006

check_sleep_effect:
	lda move_counter+2
	cmp last_sleep
	bne @rested
	jsr j_primm
	.byte "No effect.", $8d
	.byte 0

	jmp camp_done

@rested:
	sta last_sleep
	lda party_size
	sta currplayer
@next_character:
	jsr check_alive
	bmi @skip
	ldy #$12
	lda (ptr1),y
	cmp #$d3
	bne @not_sleeping
	lda #$c7
	sta (ptr1),y
@not_sleeping:
	jsr j_rand
	and #$77
	jsr increase_hp
	lda #$99
	jsr increase_hp
@skip:
	dec currplayer
	bne @next_character
	jsr restore_mp
	jsr j_primm
	.byte "Players healed!", $8d
	.byte 0

camp_done:
	rts

ambush_monsters:
	.byte $C0,$C4,$C8,$CC,$B4,$A0,$A4,$DC

check_alive:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c7
	beq @alive
	cmp #$d0
	beq @alive
	cmp #$d3
	beq @alive
	lda #$ff
	rts

@alive:
	lda #$00
	rts

increase_hp:
	sta zptmp1
	jsr j_get_stats_ptr
	ldy #$19
	sed
	clc
	lda (ptr1),y
	adc zptmp1
	sta (ptr1),y
	dey
	lda (ptr1),y
	adc #$00
	sta (ptr1),y
	cld
	ldy #$18
	lda (ptr1),y
	ldy #$1a
	cmp (ptr1),y
	bcc @done
	ldy #$19
	lda (ptr1),y
	ldy #$1b
	cmp (ptr1),y
	bcc @done
	ldy #$1a
	lda (ptr1),y
	ldy #$18
	sta (ptr1),y
	ldy #$1b
	lda (ptr1),y
	ldy #$19
	sta (ptr1),y
@done:
	rts

restore_mp:
	lda party_size
	sta currplayer
@next_character:
	jsr check_alive
	bmi @skip
	ldy #$11
	lda (ptr1),y
	sta $58
	ldy #$15
	lda (ptr1),y
	jsr bcd_to_dec
	asl a
	ldx $58
	beq @add_mp
	dex
	beq @half
	dex
	beq @none
	dex
	beq @three_quarter
	dex
	beq @one_quarter
	dex
	beq @half
	dex
	beq @half
@none:
	lda #$00
	jmp @add_mp

@one_quarter:
	lsr a
	lsr a
	jmp @add_mp

@half:
	lsr a
	jmp @add_mp

@three_quarter:
	lsr a
	sta $58
	lsr a
	adc $58
@add_mp:
	jsr dec_to_bcd
	ldy #$16
	sta (ptr1),y
@skip:
	dec currplayer
	bpl @next_character
	rts

dec_to_bcd:
	cmp #$00
	beq @done
	cmp #$63
	bcs @max99
	sed
	tax
	lda #$00
@inc:
	clc
	adc #$01
	dex
	bne @inc
	beq @done
@max99:
	lda #$99
@done:
	cld
	rts

bcd_to_dec:
	cmp #$00
	beq @zero
	ldx #$00
	sed
@inc:
	inx
	sec
	sbc #$01
	bne @inc
	txa
	cld
@zero:
	rts
