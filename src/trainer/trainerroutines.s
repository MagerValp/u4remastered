	.include "uscii.i"
	.include "u4loader.i"


	.export ask_exit_north
	.export ask_exit_south
	.export ask_exit_west
	.export ask_exit_east
	.export initiate_new_game
	.export trainer_teleport
	.export trainer_board
	.export trainer_avoid
	.export trainer_trolls
	.export trainer_cmd_attack
	.export trainer_dng_check_attacked
	.export trainer_avoid_dungeon
	.export trainer_balloon_north
	.export trainer_balloon_south
	.export trainer_balloon_west
	.export trainer_balloon_east
	.export trainer_balloon_klimb
	.export trainer_balloon_descend
	.export quit_and_save_dungeon
	.export load_dungeon
	.export supercpu_idle
	.export supercpu_idle_combat
	.export supercpu_playsfx
	.export supercpu_draw_lb_logo
	.export supercpu_fade_in_monsters
	.export supercpu_animate_monster1
;	.export supercpu_delay_checkkey
	.export fixed_getkey
	.export dirkey_trans_tab
	.export active_char_combat_start
	.export active_char_player_turn
	.export active_char_check
	.export active_char_check_command
	.export enter_balloon
	.export board_ship_check_britannia
	.export attack_lost_virtue
	.export attack_fix
	.export attack_creature_check
	.export combat_animate_fix
	.export npc_names
	.export combat_immobile
	.export combat_immobile_size
	.export attack_ranged
	.export attacked_by_fix
	.export players_dead_fix
	.export bridge_trolls_fix
	.export cmd_volume_sfx



opcode_BIT = $2c
opcode_STA = $8d

player_xpos		= $10
player_ypos		= $11
current_location	= $1a
game_mode		= $1b
balloon_flying		= $1d
player_transport	= $1e
party_size		= $1f
attacking_monster_type	= $40
tile_north		= $49
tile_south		= $4a
tile_east		= $4b
tile_west		= $4c
currplayer		= $54
movement_mode		= $74

j_waitkey		= $0800
j_player_teleport	= $0803
j_move_east		= $0806
j_move_west		= $0809
j_move_south		= $080c
j_move_north		= $080f
j_primm			= $0821
j_console_out		= $0824
j_get_stats_ptr		= $082d
j_printname		= $0830
j_request_disk		= $0842
j_update_status		= $0845
j_update_view		= $084b

sfx_play_opcode		= $19ea

cmd_unknown		= $4112
cmd_error		= $411c
print_only_on_foot	= $4139
print_not_here		= $4178
print_cant		= $4189
prepare_combat		= $4731
board_find_object	= $480b
print_volume		= $5b28
cmd_done		= $621e
dng_check_attacked	= $6cf2
generate_combat		= $6ea3
combat_monster_turn	= $7181
combat_check_sleep	= $714e
check_awake		= $7daf
print_object_name	= $8357
print_creature_name	= $835c
getandprintkey		= $8398
run_file_dead		= $83c7

sfx_toggle_opcode	= $a03e

map_status		= $ac00
object_tile		= $ac60

monster_sleep		= $ad70
player_tile		= $ada0

music_ctl		= $af20


	.segment "ASKEXIT1"

ask_exit_north:
	lda player_ypos
	bne @north
	jsr askexit
@north:
	dec player_ypos
	lda player_ypos
	rts

	.segment "ASKEXIT2"

ask_exit_south:
	lda player_ypos
	cmp #$1f
	bne @south
	jsr askexit
@south:
	inc player_ypos
	lda player_ypos
	rts

	.segment "ASKEXIT3"

ask_exit_west:
	lda player_xpos
	bne @west
	jsr askexit
@west:
	dec player_xpos
	lda player_xpos
	rts

	.segment "ASKEXIT4"

ask_exit_east:
	lda player_xpos
	cmp #$1f
	bne @east
	jsr askexit
@east:
	inc player_xpos
	lda player_xpos
	rts

	.segment "ASKEXIT5"

askexit:
	jsr j_primm
	.byte "Exit? ", 0
	jsr getandprintkey
	bne :+
@no:
	pla
	pla
	pla
	pla
	rts
:	cmp #'Y'
	bne @no
	rts


initiate_new_game:
;	jmp *

;	lda #0
;	sta game_mode
;	lda #1
;	jsr j_request_disk
;	lda #$d2
;	ldx #$50
;	jmp j_fileio


	.segment "TELEPORT1"

trainer_teleport:
	lda game_mode			; check if we're in britannia
	cmp #1
	beq :+
	jmp j_primm			; nope, continue talk command
:
	pla				; pull return address
	pla

	lda player_transport
	cmp #$14
	bcs :+
	jmp print_only_on_foot
:
	jsr j_primm
	.byte "Teleport-", 0

	jsr getandprintkey
	beq @done

	cmp #'T'
	beq @towne
	cmp #'D'
	beq @dungeon
	cmp #'S'
	beq @shrine
	cmp #'L'
	beq @location
	cmp #'C'
	beq @coordinate

@done:
	jmp cmd_done

@towne:
	jsr j_primm
	.byte "Towne-", 0
	jsr getnum
	tax
	lda towne_ypos,x
	tay
	lda towne_xpos,x
	jmp teleport

@dungeon:
	jsr j_primm
	.byte "Dungeon-", 0
	jsr getnum
	tax
	lda dungeon_ypos,x
	tay
	lda dungeon_xpos,x
	jmp teleport

@shrine:
	jsr j_primm
	.byte "Shrine-", 0
	jsr getnum
	tax
	lda shrine_ypos,x
	tay
	lda shrine_xpos,x
	jmp teleport

@location:
	jsr j_primm
	.byte "Location-", 0
	jsr getnum
	cmp #4
	bcc :+
	clc
	adc #8
:	tax
	lda location_ypos,x
	tay
	lda location_xpos,x
	jmp teleport

@coordinate:
	jsr j_primm
	.byte "Coord: ",0
	jsr getcoord
	asl
	asl
	asl
	asl
	sta $7a

	lda #$27
	jsr j_console_out

	jsr getcoord
	ora $7a
	sta $7a

	jsr j_primm
	.byte $22, $20, 0

	jsr getcoord
	asl
	asl
	asl
	asl
	sta $7b

	lda #$27
	jsr j_console_out

	jsr getcoord
	ora $7b
	sta $7b

	lda #$22
	jsr j_console_out

	ldy $7a
	lda $7b
	jmp teleport


	.segment "TELEPORT2"

teleport:
	sta player_xpos
	sty player_ypos
	ldx #7
	lda #$00
:	sta object_tile,x
	dex
	bpl :-
	jsr j_player_teleport
	jmp cmd_done


getcoord:
	jsr j_waitkey
	beq abort
	pha
	jsr j_console_out
	pla
	sec
	sbc #$c1
	bmi abort
	cmp #$10
	bcs abort
	rts


getnum:
	jsr getandprintkey
	beq abort
	sec
	sbc #$b1
	bmi abort
	cmp #8
	bcs abort
	rts
abort:
	pla
	pla
	jmp cmd_done

towne_xpos	= $519e
towne_ypos	= $51be
dungeon_xpos	= $51aa
dungeon_ypos	= $51ca
shrine_xpos	= $51b2
shrine_ypos	= $51d2
location_xpos	= $519a
location_ypos	= $51ba


;supercpu_delay_checkkey:
;	pha
;	lda $c6
;	beq @gotkey
;	sta $d07a
;	pla
;	jsr $625a
;	sta $d07b
;	rts
;@gotkey:
;	pla
;	rts


	.segment "KEYBOARDFIX"

fixed_getkey:
	sei
	ldy $c6
	beq checkjoy
	ldy $0277
	ldx #0
:	lda $0278,x
	sta $0277,x
	inx
	cpx $c6
	bne :-
	dec $c6
checktrans:
	tya
	ldy #3
:	cmp dirkey_trans_tab,y
	beq @trans
	dey
	bpl :-
	bmi :+
@trans:
	lda @dirkeys,y
:	cli
	rts

@dirkeys:
	.byte $40, $2f, $3a, $3b
dirkey_trans_tab:
	.byte $40, $2f, $3a, $3b

checkjoy:
	lda $a2
	sec
	sbc @lastscan
	cmp #5
	bcc checktrans

	lda $a2
	sta @lastscan

	lda $dc00

	lsr
	bcc @up
	lsr
	bcc @down
	lsr
	bcc @left
	lsr
	bcc @right
	lsr
	bcs checktrans
@fire:
	lda game_mode
	bmi @combat
	cmp #1
	beq @britannia
	cmp #2
	beq @towne
	cmp #3
	beq @dungeon

	ldy #$00
	.byte $2c
@britannia:
	ldy #$45
	.byte $2c
@towne:
	ldy #$54
	.byte $2c
@dungeon:
	ldy #$00
	.byte $2c
@combat:
	ldy #$41
	.byte $2c
@up:
	ldy #$40
	.byte $2c
@down:
	ldy #$2f
	.byte $2c
@left:
	ldy #$3a
	.byte $2c
@right:
	ldy #$3b
	jmp checktrans

@lastscan:
	.byte 0


	.segment "TRAINERAVOID"

trainer_avoid:
	jsr print_object_name
	jsr checkavoid
	bcc :+
plaplarts:
	pla
	pla
:	rts


trainer_trolls:
	jsr checkavoid
	bcc :+
	pla
	pla
:	lda #$a4
	sta attacking_monster_type
	rts


player_did_attack:
	.byte 0

trainer_cmd_attack:
	lda #1
	sta player_did_attack
	jsr dng_check_attacked
	jmp cmd_unknown
	
	
trainer_dng_check_attacked:
	lda #0
	sta player_did_attack
	jmp dng_check_attacked


trainer_avoid_dungeon:
	asl
	adc #$8c
	ldx player_did_attack
	bne @allow
	pha
	jsr j_primm
	.byte "Attacked by", $8d, 0
	pla
	pha
	jsr print_creature_name
	jsr checkavoid
	pla
	bcs plaplarts
@allow:
	rts


checkavoid:
	jsr j_primm
	.byte "Avoid? ", 0
	jsr getandprintkey
	bne :+
@no:
	clc
	rts
:	cmp #'Y'
	bne @no
	sec
	rts


	.segment "TRAINERBOARD"

trainer_board:
	lda current_location
	beq @ask
	jmp print_not_here
@ask:
	jsr j_primm
	.byte "what? ", 0
	jsr getandprintkey
	beq @done

	ldx #$1f
@horse:
	cmp #'H'
	bne @ship
	ldx #$14
@ship:
	cmp #'S'
	bne @balloon
	jmp trainer_ship
@balloon:
	cmp #'B'
	bne @none
	lda #$ff
	sta balloon_flying
	sta movement_mode
	ldx #$18
@none:
	stx player_transport
@done:
	jmp cmd_done


	.segment "TRAINERSHIP"

trainer_ship:
	ldx #3
:	lda tile_north,x
	cmp #2
	bcc @ok
	dex
	bpl :-
	jmp print_not_here
@ok:
	ldx #$10
	stx player_transport
	jmp cmd_done


	.segment "TRAINERBALLOON"

print_north		= $8303
print_south		= $830e
print_east		= $8319
print_west		= $8323
print_drift_only	= $41f7


not_steering:
	jmp print_drift_only


trainer_balloon_north:
	lda movement_mode
	bpl not_steering
	jsr print_north
	jsr j_move_north
	jmp cmd_done


trainer_balloon_south:
	lda movement_mode
	bpl not_steering
	jsr print_south
	jsr j_move_south
	jmp cmd_done


trainer_balloon_west:
	lda movement_mode
	bpl not_steering
	jsr print_west
	jsr j_move_west
	jmp cmd_done


trainer_balloon_east:
	lda movement_mode
	bpl not_steering
	jsr print_east
	jsr j_move_east
	jmp cmd_done


	.segment "BALLOONKLIMB"

trainer_balloon_klimb:
	; $00 (no fly) =>  $ff  (steer)
	; $ff (flying) =>  $01  (drift)
	lda balloon_flying
	eor #$ff
	ora #$01
	sta movement_mode
	lda #$ff
	rts


	.segment "BALLOONDESCEND"

trainer_balloon_descend:
	ldx movement_mode
	dex
	bpl @drifting
	jmp j_primm  ;return to normal "Land Balloon" logic
@drifting:
	dex
	stx movement_mode ;steer
	jsr j_primm
	.byte "Descend", $8d
	.byte "altitude", $8d, 0
	pla
	pla
	jmp cmd_done


	.segment "DUNGEONSAVE"

quit_and_save_dungeon:
	lda game_mode
	cmp #3
	beq :+
	jmp print_not_here
:
	lda #2
	jsr j_request_disk
	lda #$d3
	ldx #$7f
	jsr j_save_7e_7f
	ldx #$80
	jsr j_fileio
	ldx #$1a
	jsr j_fileio
	lda #4
	jsr j_request_disk
	jmp cmd_done


load_dungeon:
	lda game_mode
	cmp #3
	beq @dungeon
	lda $1d			; Restore balloon mode.
	sta $74
	rts

@dungeon:
	pla
	pla

	lda #0
	sta $74
	sta $75
	lda #4
	jsr j_request_disk
	lda #$cc
	ldx #$95
	jsr $a100
	jsr j_update_status
	jsr $50ad		; load dungeon
	lda #$ff
	sta $4d
	lda #$c4
	jsr music_ctl
	jmp cmd_done


	.segment "SUPERCPU"

idlewait7:
	lda #7
idlewait:
	sta @idle
:	lda $a2
	sec
	sbc @lastidle
@idle = * + 1
	cmp #7
	bcc :-
	lda $a2
	sta @lastidle
	rts

@lastidle:
	.byte 0


supercpu_playsfx:
	sta $d07a
	jsr $19ee
	sta $d07b
	rts


supercpu_draw_lb_logo:
	sta $d07a
	jmp $6092


supercpu_fade_in_monsters:
	sta $d07b
	jmp $6696


supercpu_animate_monster1:
	lda #5
	jsr idlewait
	ldx $6a4f
	rts

supercpu_idle:
	lda game_mode
	pha
	beq @delay
	bmi @combat

	jsr idlewait7
	pla
	jmp $0ada

@combat:
	lda #3
	jsr idlewait
	pla
	jmp $0b00

@delay:
	pla
	sta $d07a
	jsr $0b0a
	sta $d07b
	rts


supercpu_idle_combat:
	lda #3
	jsr idlewait
	jmp $0b4a


	.segment "ACTIVECHAR"

active_char_combat_start:
	lda #0
	sta combat_active_char
	jmp j_clearkbd


active_char_player_turn:
	lda combat_active_char
	bne @selected
@return_no_active:
	lda #0
	sta combat_active_char
	lda #1
	sta currplayer
	rts
@selected:
	sta currplayer
	jsr active_char_check_awake
	bne @return_no_active
	lda currplayer
	rts


active_char_check:
	lda combat_active_char
	beq @play_turn

	cmp currplayer
	beq @play_turn

	jsr active_char_check_awake
	beq @skip_char
	lda #0
	sta combat_active_char
	beq @play_turn
@skip_char:
	pla
	pla
	jmp combat_check_sleep
@play_turn:
	jmp j_update_view


active_char_check_command:
	cmp #$b0
	bcc @unknown
	cmp #$b9
	bcs @unknown

	and #$0f
	beq @deselect

	cmp party_size
	bcc :+
	bne @deselect
:
	pha
	jsr check_awake
	bne @not_awake
	pla
	sta combat_active_char
	ora #$b0
	jsr j_console_out
	jsr j_primm
	.byte " active", $8d, 0
	pha
@not_awake:
	pla
	jmp cmd_done

@deselect:
	lda #0
	sta combat_active_char
	jsr j_primm
	.byte "Party mode", $8d, 0
	jmp cmd_done

@unknown:
	jmp cmd_unknown


active_char_check_awake:
	ldx currplayer
	stx @restoreplayer
	sta currplayer
	jsr check_awake
	sta @result
	ldx currplayer
	lda player_tile - 1,x
	beq @exited
	cmp #$38
	beq @asleep
@done:
@restoreplayer = * + 1
	ldx #$5e
	stx currplayer
@result = * + 1
	lda #$5e
	rts
@exited:
@asleep:
	lda #$ff
	sta @result
	bne @done

combat_active_char:
	.byte 0


	.segment "ENTERBALLOON"

enter_balloon:
	lda current_location
	beq @in_britannia
@unknown:
	jmp cmd_unknown

@in_britannia:
	lda player_transport
	cmp #$18
	beq @unknown
	jmp $4fe1


	.segment "BOARDSHIP"

board_ship_check_britannia:
	ldx current_location
	beq @in_britannia
	pla
	pla
	jmp cmd_unknown

@in_britannia:
	jmp board_find_object


	.segment "ATTACKFIX"

attack_lost_virtue:
	jsr $8472       ; dec_virtue
	jmp j_update_status   ; BUGFIX: if lost eighth, show that in status icon
	;rts  implicit in jmp


attack_fix:
	lda object_tile,x
	cmp #$38		; Sick/sleeping.
	bne :+
	lda #$58		; Beggar.
:
	cmp #$02		; Water.
	bne :+
	lda #$01		; Deep water.
:
	cmp #$1f		; Avatar.
	bne :+
	lda #$2a		; Knight.
:
	cmp #$15		; Horse East.
	bne :+
	lda #$14		; Horse West.
:
	rts


attack_creature_check:
	lda object_tile,x
	cmp #$3c		; Chest.
	bne :+
	lda #$8c		; $8c/$8e can't be attacked.
:	rts


combat_animate_fix:
	cmp #$3d		; Ankh.
	beq @dontanim
	cmp #$4b		; Camp fire.
	beq @dontanim
	lda monster_sleep,x
	rts
@dontanim:
	lda #1
	rts


tile_water_coast	= $01
tile_horse_west		= $14
tile_class_mage		= $20
tile_anhk		= $3d
tile_camp_fire		= $4b
tile_lord_british	= $5e
tile_mimic		= $ac
tile_reaper		= $b0

string_phantom		= $13
string_water		= $9e
string_horse		= $9f
string_ankh		= $a0
string_camp_fire	= $a1

npc_names:
	ldx #4
:	cmp special_type,x
	beq :+
	dex
	bne :-
:	lda special_string,x
	jmp $8366  ;@print

special_type:
	.byte 0
	.byte tile_water_coast
	.byte tile_horse_west
	.byte tile_anhk
	.byte tile_camp_fire
special_string:
	.byte string_phantom
	.byte string_water
	.byte string_horse
	.byte string_ankh
	.byte string_camp_fire


attack_ranged:
	cmp #tile_class_mage
	beq @done   ; C=1, Z=1 : blue
	cmp #tile_lord_british
	beq @done   ; C=1, Z=1 : blue
	cmp #tile_camp_fire		; ADDED
	bne @done   ; C=1, Z=0 : none, continue
	clc         ; C=0, Z=1 : fire
	rts
@done:
	sec
	rts


attacked_by_fix:
	pla
	pla
	jmp prepare_combat

players_dead_fix:
; Reset stack. Impossible to know if we should pop 1, 3, or 4 frames
; because we could have arrived here via any of the following JSR stacks:
;     check_water_hazards > enter_whirlpool > damage_party, "thy ship sinks"
;     check_water_hazards > enter_twister > damage_party, "thy ship sinks"
;     mobs_act > mob_world_take_turn, fire_cannon_pirate > damage_party, "thy ship sinks"
;     mobs_act > mob_world_take_turn > fire_red_missile > damage_party, "thy ship sinks"
;     cmd_done > anyone_awake, all dead
;     cmd_done, next_turn > anyone_awake, all dead
; However, we do know that cmd_done is the top-most frame from which nothing ever RTS.
	ldx #$FF
	txs
	jmp cmd_done

bridge_trolls_fix:
	pla
	pla
	jmp generate_combat


	.segment "IMMOBILE"

combat_immobile:
	.byte tile_mimic
	.byte tile_reaper
	.byte tile_camp_fire	; ADDED
combat_immobile_size = * - combat_immobile


	.segment "SFXVOLUME"

cmd_volume_sfx:
	jsr j_waitkey
	cmp #$be    ;Ctrl+V
	beq @toggle_sfx
	rts
@toggle_sfx:
	pla
	pla
	jsr j_primm
	.byte "FX ", 0
	lda sfx_toggle_opcode
	eor #(opcode_STA ^ opcode_BIT)
	sta sfx_toggle_opcode
	sta sfx_play_opcode
	jmp print_volume
