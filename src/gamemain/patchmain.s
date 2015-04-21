	.include "trainer.i"
	.include "u4loader.i"


	.export game_startup_patch

	.import start_game
	.import ask_exit_north
	.import ask_exit_south
	.import ask_exit_west
	.import ask_exit_east
	.import initiate_new_game
	.import trainer_teleport
	.import trainer_board
	.import trainer_avoid
	.import trainer_trolls
	.import trainer_balloon_north
	.import trainer_balloon_south
	.import trainer_balloon_west
	.import trainer_balloon_east
	.import quit_and_save_dungeon
	.import load_dungeon
	.import dirkey_trans_tab
	.import active_char_combat_start
	.import active_char_player_turn
	.import active_char_check
	.import active_char_check_command
	.import enter_balloon
	.import board_ship_check_britannia
	.import attack_fix
	.import attack_creature_check
	.import combat_animate_fix


	.segment "TRAINER"

src		= $7e
dest		= $7c
key_north	= dirkey_trans_tab
key_south	= dirkey_trans_tab + 1
key_east	= dirkey_trans_tab + 2
key_west	= dirkey_trans_tab + 3


game_startup_patch:
	lda #$09		; Restore original jump address.
	sta start_game + 1
	lda #$40
	sta start_game + 2

	jsr j_init_tempmap_cache

	ldx #0
@check:
	cpx #ntrainers
	bcs :+
	lda select,x
	beq @next
:	lda patchchain_lo,x
	sta src
	lda patchchain_hi,x
	sta src + 1
	jsr patch
@next:
	inx
	cpx #npatches
	bne @check

	sei
	lda $01
	pha

	lda #$36
	sta $01

	lda $ebaf
	sta key_north
	lda $ebb8
	sta key_south
	lda $ebae
	sta key_east
	lda $ebb3
	sta key_west

	pla
	sta $01
	cli

	lda #0
	sta $c6

	jmp start_game


patch:
	jsr getbyte
	bne :+
	rts
:
	sta patchlen

	jsr getbyte
	sta dest
	jsr getbyte
	sta dest + 1

	ldy #0
:	lda (src),y
	sta (dest),y
	iny
patchlen = * + 1
	cpy #$ff
	bne :-

	lda patchlen
	clc
	adc src
	sta src
	bcc :+
	inc src + 1
:	jmp patch


getbyte:
	ldy #0
	lda (src),y
	php
	inc src
	bne :+
	inc src + 1
:	plp
	rts


patchchain_lo:
	.byte <patch_magic
	.byte <patch_food
	.byte <patch_torch
	.byte <patch_jimmy
	.byte <patch_peer
	.byte <patch_avoid
	.byte <patch_balloon
	.byte <patch_keys
	.byte <patch_pass
	.byte <patch_save_britannia
	.byte <patch_save_dungeon
	.byte <patch_shake
	.byte <patch_exit_north
	.byte <patch_exit_south
	.byte <patch_exit_east
	.byte <patch_exit_west
	.byte <patch_init_new_game
	.byte <patch_active_char
	.byte <patch_music
	.byte <patch_enter_balloon
	.byte <patch_board_dungeon
	.byte <patch_attack
npatches = < (* - patchchain_lo)

patchchain_hi:
	.byte >patch_magic
	.byte >patch_food
	.byte >patch_torch
	.byte >patch_jimmy
	.byte >patch_peer
	.byte >patch_avoid
	.byte >patch_balloon
	.byte >patch_keys
	.byte >patch_pass
	.byte >patch_save_britannia
	.byte >patch_save_dungeon
	.byte >patch_shake
	.byte >patch_exit_north
	.byte >patch_exit_south
	.byte >patch_exit_east
	.byte >patch_exit_west
	.byte >patch_init_new_game
	.byte >patch_active_char
	.byte >patch_music
	.byte >patch_enter_balloon
	.byte >patch_board_dungeon
	.byte >patch_attack


patch_magic:
	.byte 3
	.addr $48a1
	jmp $48dd

	.byte 0


patch_food:
	.byte 2
	.addr $6500
	sec
	rts

	.byte 0


patch_torch:
	.byte 3
	.addr $5518
	sec
	nop
	nop

	.byte 0


patch_jimmy:
	.byte 1
	.addr $5551
	.byte $0d

	.byte 0


patch_avoid:
	.byte 2
	.addr $66fc
	.addr trainer_avoid

	.byte 4
	.addr $62d7
	jsr trainer_trolls
	nop

	.byte 0


patch_balloon:
	.byte 2
	.addr $424e
	.addr trainer_balloon_north

	.byte 2
	.addr $434f
	.addr trainer_balloon_south

	.byte 2
	.addr $4428
	.addr trainer_balloon_west

	.byte 2
	.addr $44f1
	.addr trainer_balloon_east

	.byte 1
	.addr $0b15
	.byte $60

	.byte 0


patch_keys:
	.byte 3
	.addr $59ce
	jsr trainer_teleport

	.byte 2
	.addr $47ac
	.addr trainer_board

	.byte 0


patch_pass:
	.byte 3
	.addr $4096
	jmp $408f

	.byte 3
	.addr $70f0
	jmp $70eb

	.byte 0


patch_peer:
	.byte 3
	.addr $57cd
	jmp $57d7

	.byte 0


patch_save_britannia:
	.byte 2
	.addr $5840
	.addr j_save_7e_7f

	.byte 0


patch_save_dungeon:
	.byte 2
	.addr $582f
	.addr quit_and_save_dungeon

	.byte 6
	.addr $405c
	jsr load_dungeon
	nop
	nop
	nop

	.byte 0


patch_shake:
	.byte 23
	.addr $85fd
  .org $85fd
	sta $d07a
	lda #$04
	sta $8614
	jsr $8645
	jsr $8616
	dec $8614
	bne $8605
	sta $d07b
	rts
  .reloc

	.byte 0


patch_exit_north:
	.byte 4
	.addr $42e1
	jsr ask_exit_north
	nop

	.byte 0


patch_exit_south:
	.byte 4
	.addr $43ef
	jsr ask_exit_south
	nop

	.byte 0


patch_exit_west:
	.byte 4
	.addr $44b9
	jsr ask_exit_west
	nop

	.byte 0


patch_exit_east:
	.byte 4
	.addr $4591
	jsr ask_exit_east
	nop

	.byte 0


patch_init_new_game:
	.byte 3
	.addr $404d
	jmp initiate_new_game

	.byte 0


patch_active_char:
	.byte 2
	.addr $7097
	.addr active_char_combat_start

	.byte 4
	.addr $709d
	jsr active_char_player_turn
	nop

	.byte 3
	.addr $70c2
	jsr active_char_check

	.byte 2
	.addr $7131
	.addr active_char_check_command

	.byte 0


patch_music:
	.byte 1			; Descend.
	.addr $4f96
	.byte $2c

	.byte 1			; Klimb.
	.addr $55fe
	.byte $2c

	.byte 1			; Mix reagents.
	.addr $56b7
	.byte $2c

	.byte 1			; Quit and save.
	.addr $5833
	.byte $2c

	.byte 1			; Search.
	.addr $59b9
	.byte $2c

	.byte 1			; Use.
	.addr $5b01
	.byte $2c

	.byte 1			; Dead
	.addr $83dc
	.byte $c3

	.byte 0


patch_enter_balloon:
	.byte 3
	.addr $4fda
	jmp enter_balloon

	.byte 0


patch_board_dungeon:
	.byte 2
	.addr $47b1
	.addr board_ship_check_britannia

	.byte 0


patch_attack:
	.byte 3
	.addr $4733
	jsr attack_fix

	.byte 3
	.addr $46e1
	jsr attack_creature_check

	.byte 3
	.addr $0b6d
	jsr combat_animate_fix

	.byte 0
