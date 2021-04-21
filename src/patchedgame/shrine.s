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
last_meditated		= $0029
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

shrine:
	lda current_location
	sec
	sbc #$19
	sta shrine_num
	tay
	lda runes
	and rune_mask,y
	bne @haverune
	jsr j_primm
	.byte $8d
	.byte "Thou dost not", $8d
	.byte "bear the rune", $8d
	.byte "of entry! A", $8d
	.byte "strange force", $8d
	.byte "keeps you out!", $8d
	.byte 0

	jmp exit_shrine

@haverune:
	lda #$cc
	ldx #$1c
	jsr j_fileio
	ldx #$7f
@copymap:
	lda tempmap,x
	sta currmap,x
	dex
	bpl @copymap
	lda #$ff
	sta game_mode
	jsr j_update_view
	lda #$03
	jsr music_ctl
	jsr j_primm
	.byte $8d
	.byte "You enter the", $8d
	.byte "ancient shrine", $8d
	.byte "and sit before", $8d
	.byte "the altar...", $8d
	.byte $8d
	.byte "Upon what virtue", $8d
	.byte "dost thou", $8d
	.byte "meditate?", $8d
	.byte 0

	lda #$00
	sta num_cycles
	jsr get_string
@askcycles:
	jsr j_primm
	.byte $8d
	.byte "For how many", $8d
	.byte "cycles (0-3):", 0

	jsr get_number			; Buggy original:
	bne :+                          ;	cmp #$04
	jmp no_focus                    ;	bcs @askcycles
:	cmp #$04                        ;	sta num_cycles
	bcs @askcycles                  ;	sta cycle_ctr
	sta num_cycles                  ;	bne :+
	sta cycle_ctr                   ;	jmp no_focus
	lda #$00
	sta unused
	jsr compare_string
	cmp shrine_num
	beq @virtue_shrine_match
	jmp no_focus

@virtue_shrine_match:
	lda move_counter+2
	cmp last_meditated
	bne @begin
	jmp still_weary

@begin:
	sta last_meditated
	jsr j_primm
	.byte $8d
	.byte "Begin meditation", $8d
	.byte 0

@slowdots:
	lda #$10
	sta $70
@print:
	jsr delay
	lda #$ae
	jsr j_console_out
	dec $70
	bne @print
	bit $c010
	lda #$00
	sta key_buf_len
	jsr j_primm
	.byte $8d
	.byte "Mantra", 0

	jsr get_string
	jsr compare_string
	sec
	sbc #$08
	cmp shrine_num
	beq @correctmantra
	jmp @wrongmantra

@correctmantra:
	dec cycle_ctr
	bne @slowdots
	jmp @checkresult

@wrongmantra:
	jsr j_primm
	.byte $8d
	.byte "Thou art not", $8d
	.byte "able to focus", $8d
	.byte "thy thoughts", $8d
	.byte "with that", $8d
	.byte "mantra!", $8d
	.byte 0

	ldy #$06
	lda #$03
	jsr decrease_virtue
	jmp exit_shrine

@checkresult:
	lda num_cycles
	cmp #$03
	bne @vision
	ldy shrine_num
	lda virtues_and_stats,y
	cmp #$99
	bne @vision
	jmp partial_avatar

@vision:
	jsr j_primm
	.byte $8d
	.byte "Thy thoughts", $8d
	.byte "are pure,", $8d
	.byte "thou art granted", $8d
	.byte "a vision!", $8d
	.byte 0

	ldy #$06
	lda num_cycles
	asl a
	adc num_cycles
	jsr increase_virtue
	jsr j_waitkey
	lda #$8d
	jsr j_console_out
	ldy shrine_num
	lda shrine_msg_idx,y
	clc
	ldy num_cycles
	adc shrine_msg_per_cycle,y
	clc
	adc #$01
	jsr print_hint
	jsr j_waitkey
exit_shrine:
	lda #$8d
	jsr j_console_out
	lda #$00
	sta current_location
	lda #$01
	sta game_mode
	jsr j_update_view
	rts

	ldx #$0a
:	jsr shortdelay
	dex
	bne :-
	rts

delay:
	ldx #$05
:	jsr shortdelay
	dex
	bne :-
	rts

shortdelay:
	ldy #$ff
:	lda #$ff
:	sec
	sbc #$01
	bne :-
	dey
	bne :--
	jsr j_clearkbd
	rts

no_focus:
	jsr j_primm
	.byte $8d
	.byte "Thou art unable", $8d
	.byte "to focus thy", $8d
	.byte "thoughts on", $8d
	.byte "this subject!", $8d
	.byte 0

	jsr j_waitkey
	jmp exit_shrine

still_weary:
	jsr j_primm
	.byte $8d
	.byte "Thy mind is", $8d
	.byte "still weary", $8d
	.byte "from thy last", $8d
	.byte "meditation!", $8d
	.byte 0

	jsr j_waitkey
	jmp exit_shrine

increase_virtue:
	sta $59
	sed
	clc
	lda virtues_and_stats,y
	beq @nooverflow
	adc $59
	bcc @nooverflow
	lda #$99
@nooverflow:
	sta virtues_and_stats,y
	cld
	rts

decrease_virtue:
	sta zptmp1
	sty $59
	lda virtues_and_stats,y
	beq @lost_an_eighth
@subtract:
	sed
	sec
	sbc zptmp1
	beq :+
	bcs @positive
:	lda #1
@positive:
	sta virtues_and_stats,y
	cld
	rts

@lost_an_eighth:
	jsr j_primm
	.byte $8d
	.byte "Thou hast lost", $8d
	.byte "an eighth!", $8d
	.byte 0

	ldy $59
	lda #$99
	jmp @subtract

partial_avatar:
	jsr j_primm
	.byte $8d
	.byte "Thou hast", $8d
	.byte "achieved partial", $8d
	.byte "Avatarhood in", $8d
	.byte "the virtue of", $8d
	.byte 0

	lda #$97
	clc
	adc shrine_num
	jsr j_printstring
	jsr j_invertview
	ldx #$ff
	lda #$09
	jsr j_playsfx
	jsr j_invertview
	lda #$8d
	jsr j_console_out
	ldy shrine_num
	lda #$00
	sta virtues_and_stats,y
	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Thou art granted", $8d
	.byte "a vision!", $8d
	.byte 0

	lda #$00
	sta game_mode
	lda shrine_num
	jsr draw_rune
	jsr j_waitkey
	jmp exit_shrine

get_number:
	jsr j_waitkey
	beq get_number
	sec
	sbc #$b0
	cmp #$0a
	bcc @ok
	lda #$00
@ok:
	pha
	jsr j_printdigit
	lda #$8d
	jsr j_console_out
	pla
	rts

shrine_num:
	.byte 0
num_cycles:
	.byte 0
cycle_ctr:
	.byte 0
unused:
	.byte 0
shrine_msg_idx:
	.byte 0, 3, 6, 9, $0c, $0f, $12, $15
shrine_msg_per_cycle:
;	.byte $18, 0, 0, 0, 1, 1, 1, 2, 2, 2	; Buggy original.
	.byte $18, 0, 1, 2, 1, 1, 1, 2, 2, 2	; Fixed version.
rune_mask:
	.byte $80, $40, $20, $10, 8, 4, 2, 1

get_string:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta $6a
@waitkey:
	jsr j_waitkey
	beq @timeout
@checkkey:
	cmp #$8d
	beq @done
	cmp #$94
	beq @del
	cmp #$a0
	bcc @waitkey
	ldx $6a
	sta $af00,x
	jsr j_console_out
	inc $6a
	lda $6a
	cmp #$0f
	bcc @waitkey
	bcs @done
@del:
	lda $6a
	beq @waitkey
	dec $6a
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @waitkey

@timeout:
	lda num_cycles
	beq @checkkey
@done:
	ldx $6a
	lda #$a0
@clearend:
	sta $af00,x
	inx
	cpx #$06
	bcc @clearend
	lda #$8d
	jsr j_console_out
	rts

compare_string:
	lda #$0f
	sta $6a
@nextstring:
	lda $6a
	asl a
	asl a
	tay
	ldx #$00
@compare:
	lda virtues_and_mantras,y
	cmp $af00,x
	bne @differ
	iny
	inx
	cpx #$04
	bcc @compare
	lda $6a
	rts

@differ:
	dec $6a
	bpl @nextstring
	lda $6a
	rts

virtues_and_mantras:
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte "AHM "
	.byte "MU  "
	.byte "RA  "
	.byte "BEH "
	.byte "CAH "
	.byte "SUMM"
	.byte "OM  "
	.byte "LUM "

print_hint:
	tay
	lda #<string_table
	sta ptr1
	lda #>string_table
	sta ptr1+1
	ldx #$00
@checknext:
	lda (ptr1,x)
	beq @possiblestring
@wrongstring:
	jsr @incptr
	jmp @checknext

@possiblestring:
	dey
	beq @gotstring
	jmp @wrongstring

@gotstring:
	jsr @incptr
	ldx #$00
	lda (ptr1,x)
	beq @done
	jsr j_console_out
	jmp @gotstring

@done:
	rts

@incptr:
	inc ptr1
	bne :+
	inc ptr1+1
:	rts

string_table:
hint_honesty_0:
	.byte 0, "Take not the", $8d
	.byte "gold of others", $8d
	.byte "found in towns", $8d
	.byte "and castles for", $8d
	.byte "yours it is not!", $8d
hint_honesty_1:
	.byte 0, "Cheat not the", $8d
	.byte "merchants and", $8d
	.byte "peddlers for", $8d
	.byte "'tis an evil", $8d
	.byte "thing to do!", $8d
hint_honesty_2:
	.byte 0, "Second, read the", $8d
	.byte "book of truth at", $8d
	.byte "the entrance to", $8d
	.byte "the Great", $8d
	.byte "Stygian Abyss!", $8d
hint_compassion_0:
	.byte 0, "Kill not the", $8d
	.byte "non-evil beasts", $8d
	.byte "of the land, and", $8d
	.byte "do not attack", $8d
	.byte "the fair people!", $8d
hint_compassion_1:
	.byte 0, "Give of thy", $8d
	.byte "purse to those", $8d
	.byte "who beg and thy", $8d
	.byte "deed shall not", $8d
	.byte "be forgotten!", $8d
hint_compassion_2:
	.byte 0, "Third, light the", $8d
	.byte "candle of love", $8d
	.byte "at the entrance", $8d
	.byte "to the Great", $8d
	.byte "Stygian Abyss!", $8d
hint_valor_0:
	.byte 0, "Victories scored", $8d
	.byte "over evil", $8d
	.byte "creatures help", $8d
	.byte "to build a", $8d
	.byte "valorous soul!", $8d
hint_valor_1:
	.byte 0, "To flee from", $8d
	.byte "battle with less", $8d
	.byte "than grievous", $8d
	.byte "wounds often", $8d
	.byte "shows a coward!", $8d
hint_valor_2:
	.byte 0, "First, ring the", $8d
	.byte "bell of courage", $8d
	.byte "at the entrance", $8d
	.byte "to the Great", $8d
	.byte "Stygian Abyss!", $8d
hint_justice_0:
	.byte 0, "To take the gold", $8d
	.byte "of others is", $8d
	.byte "injustice not", $8d
	.byte "soon forgotten,", $8d
	.byte "take only thy", $8d
	.byte "due!", $8d
hint_justice_1:
	.byte 0, "Attack not a", $8d
	.byte "peaceful citizen", $8d
	.byte "for that action", $8d
	.byte "deserves strict", $8d
	.byte "punishment!", $8d
hint_justice_2:
	.byte 0, "Kill not a", $8d
	.byte "non-evil beast", $8d
	.byte "for they deserve", $8d
	.byte "not death even", $8d
	.byte "if in hunger", $8d
	.byte "they attack", $8d
	.byte "thee!", $8d
hint_sacrifice_0:
	.byte 0, "To give thy last", $8d
	.byte "gold piece unto", $8d
	.byte "the needy shows", $8d
	.byte "good measure of", $8d
	.byte "self-sacrifice!", $8d
hint_sacrifice_1:
	.byte 0, "For thee to flee", $8d
	.byte "and leave thy", $8d
	.byte "companions is a", $8d
	.byte "self-seeking", $8d
	.byte "action to be", $8d
	.byte "avoided!", $8d
hint_sacrifice_2:
	.byte 0, "To give of thy", $8d
	.byte "life's blood so", $8d
	.byte "that others may", $8d
	.byte "live is a virtue", $8d
	.byte "of great praise!", $8d
hint_honor_0:
	.byte 0, "Take not the", $8d
	.byte "gold of others", $8d
	.byte "for this shall", $8d
	.byte "bring dishonor", $8d
	.byte "upon thee!", $8d
hint_honor_1:
	.byte 0, "To strike first", $8d
	.byte "a non-evil being", $8d
	.byte "is by no means", $8d
	.byte "an honorable", $8d
	.byte "deed!", $8d
hint_honor_2:
	.byte 0, "Seek ye to solve", $8d
	.byte "the many quests", $8d
	.byte "before thee, and", $8d
	.byte "honor shall be", $8d
	.byte "a reward!", $8d
hint_spirituality_0:
	.byte 0, "Seek ye to know", $8d
	.byte "thyself, visit", $8d
	.byte "the seer often", $8d
	.byte "for he can", $8d
	.byte "see into thy", $8d
	.byte "inner being!", $8d
hint_spirituality_1:
	.byte 0, "Meditation", $8d
	.byte "leads to", $8d
	.byte "enlightenment.", $8d
	.byte "Seek ye all", $8d
	.byte "wisdom and", $8d
	.byte "knowledge!", $8d
hint_spirituality_2:
	.byte 0, "If thou dost", $8d
	.byte "seek the white", $8d
	.byte "stone, search ye", $8d
	.byte "not under the", $8d
	.byte "ground, but in", $8d
	.byte "the sky near", $8d
	.byte "serpents spine!", $8d
hint_humility_0:
	.byte 0, "Claim not to be", $8d
	.byte "that which thou", $8d
	.byte "art not, humble", $8d
	.byte "actions speak", $8d
	.byte "well of thee!", $8d
hint_humility_1:
	.byte 0, "Strive not to", $8d
	.byte "wield the great", $8d
	.byte "force of evil", $8d
	.byte "for its power", $8d
	.byte "will overcome", $8d
	.byte "thee!", $8d
hint_humility_2:
	.byte 0, "If thou dost", $8d
	.byte "seek the black", $8d
	.byte "stone, search ye", $8d
	.byte "at the time and", $8d
	.byte "place of the", $8d
	.byte "gate on the", $8d
	.byte "darkest of all", $8d
	.byte "nights!", $8d
hint_end:
	.byte 0

draw_rune:
	pha
	jsr swap_buf
	jsr j_clearview
	jsr clear_view_colors
	pla
	tax
	lda infinity,x
	asl a
	tax
	lda rune_addr,x
	sta key_buf
	lda rune_addr+1,x
	sta key_buf+1
	ldx #$50
	lda bmplineaddr_lo,x
	clc
	adc #$48
	sta key_buf+2
	lda bmplineaddr_hi,x
	adc #$00
	sta key_buf+3
	lda #$04
	sta row_ctr
@nextline:
	ldy #$00
:	lda (key_buf),y
	sta (key_buf+2),y
	iny
	cpy #$18
	bne :-
	lda key_buf
	clc
	adc #$18
	sta key_buf
	lda key_buf+1
	adc #$00
	sta key_buf+1
	lda key_buf+2
	clc
	adc #$40
	sta key_buf+2
	lda key_buf+3
	adc #$01
	sta key_buf+3
	dec row_ctr
	bne @nextline
	jsr swap_buf
	rts

clear_view_colors:
	lda #$29
	sta key_buf
	lda #$04
	sta key_buf+1
	ldx #$16
@nextline:
	ldy #$00
@nextchar:
	lda #$10
	sta (key_buf),y
	iny
	cpy #$16
	bne @nextchar
	lda key_buf
	clc
	adc #$28
	sta key_buf
	bcc :+
	inc key_buf+1
:	dex
	bne @nextline
	rts

swap_buf:
	ldx #$07
:	lda key_buf,x
	tay
	lda key_buf_tmp,x
	sta key_buf,x
	tya
	sta key_buf_tmp,x
	dex
	bpl :-
	rts

key_buf_tmp:
	.res 8, 0
row_ctr:
	.byte 0
infinity:
	.byte 0, 1, 2, 0, 1, 0, 3, 4

rune_addr:
	.addr rune_i
	.addr rune_n
	.addr rune_f
	.addr rune_t
	.addr rune_y

rune_i:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9510	........
	.byte	$0E,$3E,$3C,$1C,$1C,$1C,$1C,$1C ; 9518	N><\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9520	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9528	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9530	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9538	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9540	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9548	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9550	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9558	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 9560	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9568	........
rune_n:
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9570	........
	.byte	$0E,$3E,$3C,$1C,$1C,$1C,$1C,$1C ; 9578	N><\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9580	........
	.byte	$00,$00,$00,$03,$07,$0E,$0C,$0C ; 9588	...CGNLL
	.byte	$1C,$1C,$1C,$DC,$FC,$7C,$3C,$1E ; 9590	\\\\||<^
	.byte	$00,$00,$00,$00,$70,$38,$18,$18 ; 9598	....p8XX
	.byte	$0E,$07,$00,$00,$00,$00,$00,$00 ; 95A0	NG......
	.byte	$1F,$1F,$1D,$1C,$1C,$1C,$1C,$1C ; 95A8	__]\\\\\
	.byte	$38,$F0,$E0,$00,$00,$00,$00,$00 ; 95B0	8p`.....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 95B8	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 95C0	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 95C8	........
rune_f:
	.byte	$03,$0F,$0F,$07,$07,$07,$07,$07 ; 95D0	COOGGGGG
	.byte	$9E,$9E,$0C,$0C,$0C,$1C,$F8,$F0 ; 95D8	^^LLL\xp
	.byte	$78,$78,$30,$30,$30,$30,$30,$60 ; 95E0	xx00000`
	.byte	$07,$07,$07,$07,$07,$07,$07,$07 ; 95E8	GGGGGGGG
	.byte	$00,$00,$03,$FF,$FC,$00,$00,$00 ; 95F0	..C.|...
	.byte	$60,$E0,$C0,$80,$00,$00,$00,$00 ; 95F8	``@.....
	.byte	$07,$07,$07,$07,$07,$07,$07,$07 ; 9600	GGGGGGGG
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9608	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9610	........
	.byte	$07,$07,$0F,$0E,$00,$00,$00,$00 ; 9618	GGON....
	.byte	$00,$80,$80,$00,$00,$00,$00,$00 ; 9620	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9628	........
rune_t:
	.byte	$00,$00,$01,$07,$1F,$1C,$00,$00 ; 9630	..AG_\..
	.byte	$1C,$7F,$FF,$DD,$1C,$1C,$1C,$1C ; 9638	\..]\\\\
	.byte	$00,$00,$C0,$F0,$7C,$1C,$00,$00 ; 9640	..@p|\..
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9648	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9650	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9658	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9660	........
	.byte	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C ; 9668	\\\\\\\\
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9670	........
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9678	........
	.byte	$1C,$1E,$3E,$38,$00,$00,$00,$00 ; 9680	\^>8....
	.byte	$00,$00,$00,$00,$00,$00,$00,$00 ; 9688	........
rune_y:
	.byte	$E0,$FC,$7F,$77,$70,$70,$70,$70 ; 9690	`|.wpppp
	.byte	$00,$00,$80,$F0,$FE,$1F,$03,$00 ; 9698	...p~_C.
	.byte	$00,$00,$00,$00,$00,$C0,$F8,$7F ; 96A0	.....@x.
	.byte	$70,$70,$70,$70,$70,$70,$7F,$7F ; 96A8	pppppp..
	.byte	$00,$00,$00,$00,$00,$00,$FF,$FF ; 96B0	........
	.byte	$0F,$0E,$0E,$0E,$0E,$0E,$FE,$FE ; 96B8	ONNNNN~~
	.byte	$70,$70,$70,$70,$70,$70,$70,$70 ; 96C0	pppppppp
	.byte	$30,$30,$30,$30,$30,$30,$30,$30 ; 96C8	00000000
	.byte	$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E ; 96D0	NNNNNNNN
	.byte	$70,$78,$F8,$E0,$00,$00,$00,$00 ; 96D8	pxx`....
	.byte	$30,$38,$78,$70,$00,$00,$00,$00 ; 96E0	08xp....
	.byte	$0E,$0F,$1F,$1C,$00,$00,$00,$00 ; 96E8	NO_\....
