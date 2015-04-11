	.include "uscii.i"


player_xpos		= $0010
player_ypos		= $0011
tile_xpos		= $0012
tile_ypos		= $0013
map_x			= $0014
map_y			= $0015
game_mode		= $001b
dungeon_level		= $001c
balloon_flying		= $001d
player_transport	= $001e
party_size		= $001f
dng_direction		= $0020
moon_phase_trammel	= $0022
moon_phase_felucca	= $0023
ship_hull		= $002b
key_buf 		= $0030
key_buf_len		= $0038
charptr 		= $003d
magic_aura		= $0046
tile_under_player	= $0048
tile_north		= $0049
tile_south		= $004a
tile_east		= $004b
tile_west		= $004c
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
reqdisk 		= $005e
currdrive		= $005f
lt_y			= $0060
lt_x			= $0061
lt_rwflag		= $0062
lt_addr_hi		= $0063
moongate_tile		= $006d
moongate_xpos		= $006e
moongate_ypos		= $006f
tilerow 		= $0072
movement_mode		= $0074
direction		= $0075
ptr2			= $007c
ptr1			= $007e
L8C03			= $8c03
L9F00			= $9f00
L9F26			= $9f26
L9F54			= $9f54
L9F78			= $9f78
L9F85			= $9f85
L9F8C			= $9f8c
L9FAF			= $9faf
L9FCE			= $9fce
j_fileio		= $a100
j_readblock		= $a103
j_togglesnd		= $a109
virtues_and_stats	= $ab00
map_status		= $ac00
object_xpos		= $ac20
object_ypos		= $ac40
object_tile		= $ac60
currmap 		= $ae00
tempmap 		= $ae80
music_nop		= $af23
bmplineaddr_lo		= $e000
bmplineaddr_hi		= $e0c0
chrlineaddr_lo		= $e180
chrlineaddr_hi		= $e198
tile_color		= $e1b0


	.segment "SUBS"

j_waitkey:
	jmp waitkey

j_player_teleport:
	jmp player_teleport

j_move_east:
	jmp move_east

j_move_west:
	jmp move_west

j_move_south:
	jmp move_south

j_move_north:
	jmp move_north

j_drawinterface:
	jmp drawinterface

j_drawview:
	jmp drawview

j_update_britannia:
	jmp update_britannia

	nop
	nop
	nop
j_primm_xy:
	jmp primm_xy

j_primm:
	jmp primm

j_console_out:
	jmp console_out

j_clearbitmap:
	jmp clearbitmap

j_mulax:
	jmp mulax

j_get_stats_ptr:
	jmp get_stats_ptr

j_printname:
	jmp printname

j_printbcd:
	jmp printbcd

j_drawcursor:
	jmp drawcursor

j_drawcursor_xy:
	jmp drawcursor_xy

j_drawvert:
	jmp drawvert

j_drawhoriz:
	jmp drawhoriz

j_request_disk:
	jmp request_disk

j_update_status:
	jmp update_status

j_blocked_tile:
	jmp blocked_tile

j_update_view:
	jmp idle

j_rand:
	jmp rand

j_loadsector:
	jmp loadsector

j_playsfx:
	jmp playsfx

j_update_view_combat:
	jmp idle_combat

j_getnumber:
	jmp getnumber

j_getplayernum:
	jmp getplayernum

j_update_wind:
	jmp update_wind

j_animate_view:
	jmp animate_view

j_printdigit:
	jmp printdigit

j_clearstatwindow:
	jmp clearstatwindow

j_animate_creatures:
	jmp animate_creatures

j_centername:
	jmp centername

j_print_direction:
	jmp print_direction

j_clearview:
	jmp clearview

j_invertview:
	jmp invertview

j_centerstring:
	jmp centerstring

j_printstring:
	jmp printstring

j_gettile_bounds:
	jmp L9F00

j_gettile_britannia:
	jmp L9F26

j_gettile_opposite:
	jmp L9F54

j_gettile_currmap:
	jmp L9F78

j_gettile_tempmap:
	jmp L9F85

j_get_player_tile:
	jmp L9F8C

j_gettile_towne:
	jmp L9FAF

j_gettile_dungeon:
	jmp L9FCE

move_east:
	inc player_xpos
	inc tile_xpos
	lda tile_xpos
	cmp #$18
	bcc @notileborder
	jsr music_nop
@notileborder:
	cmp #$1b
	bcc movedone
	and #$0f
	sta tile_xpos
	jsr map_scroll_east
	inc map_x
	lda map_x
	and #$0f
	sta map_x
	jsr loadtiles_east
movedone:
	rts

move_west:
	dec player_xpos
	dec tile_xpos
	lda tile_xpos
	cmp #$08
	bcs @notileborder
	jsr music_nop
@notileborder:
	cmp #$05
	bcs movedone
	ora #$10
	sta tile_xpos
	jsr map_scroll_west
	dec map_x
	lda map_x
	and #$0f
	sta map_x
	jmp loadtiles_west

move_south:
	inc player_ypos
	inc tile_ypos
	lda tile_ypos
	cmp #$18
	bcc @notileborder
	jsr music_nop
@notileborder:
	cmp #$1b
	bcc @done
	and #$0f
	sta tile_ypos
	jsr map_scroll_south
	inc map_y
	lda map_y
	and #$0f
	sta map_y
	jsr loadtiles_south
@done:
	rts

move_north:
	dec player_ypos
	dec tile_ypos
	lda tile_ypos
	cmp #$08
	bcs @notileborder
	jsr music_nop
@notileborder:
	cmp #$05
	bcs @done
	ora #$10
	sta tile_ypos
	jsr map_scroll_north
	dec map_y
	lda map_y
	and #$0f
	sta map_y
	jsr loadtiles_north
@done:
	rts

map_scroll_east:
	ldx #$00
@scroll:
	lda $e900,x
	sta $e800,x
	lda $eb00,x
	sta $ea00,x
	inx
	bne @scroll
	rts

map_scroll_west:
	ldx #$00
@scroll:
	lda $e800,x
	sta $e900,x
	lda $ea00,x
	sta $eb00,x
	inx
	bne @scroll
	rts

map_scroll_south:
	ldx #$00
@scroll:
	lda $ea00,x
	sta $e800,x
	lda $eb00,x
	sta $e900,x
	inx
	bne @scroll
	rts

map_scroll_north:
	ldx #$00
@scroll:
	lda $e800,x
	sta $ea00,x
	lda $e900,x
	sta $eb00,x
	inx
	bne @scroll
	rts

loadtiles_east:
	lda #$01
	sta lt_rwflag
	clc
	lda map_x
	adc #$01
	and #$0f
	sta lt_x
	lda map_y
	sta lt_y
	lda #$e9
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_y
	adc #$01
	and #$0f
	sta lt_y
	lda #$eb
	sta lt_addr_hi
	jmp loadsector

loadtiles_west:
	lda #$01
	sta lt_rwflag
	clc
	lda map_x
	sta lt_x
	lda map_y
	sta lt_y
	lda #$e8
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_y
	adc #$01
	and #$0f
	sta lt_y
	lda #$ea
	sta lt_addr_hi
	jmp loadsector

loadtiles_south:
	lda #$01
	sta lt_rwflag
	clc
	lda map_y
	adc #$01
	and #$0f
	sta lt_y
	lda map_x
	sta lt_x
	lda #$ea
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_x
	adc #$01
	and #$0f
	sta lt_x
	lda #$eb
	sta lt_addr_hi
	jmp loadsector

loadtiles_north:
	lda #$01
	sta lt_rwflag
	clc
	lda map_y
	sta lt_y
	lda map_x
	sta lt_x
	lda #$e8
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_x
	adc #$01
	and #$0f
	sta lt_x
	lda #$e9
	sta lt_addr_hi
	jmp loadsector

player_teleport:
	lda player_xpos
	jsr div16
	sta map_x
	lda player_xpos
	and #$0f
	sta tile_xpos
	cmp #$08
	bcs @eastern
	clc
	adc #$10
	sta tile_xpos
	dec map_x
	lda map_x
	and #$0f
	sta map_x
@eastern:
	lda player_ypos
	jsr div16
	sta map_y
	lda player_ypos
	and #$0f
	sta tile_ypos
	cmp #$08
	bcs @southern
	clc
	adc #$10
	sta tile_ypos
	dec map_y
	lda map_y
	and #$0f
	sta map_y
@southern:
	lda #$01
	sta lt_rwflag
	lda map_x
	sta lt_x
	lda map_y
	sta lt_y
	lda #$e8
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_x
	adc #$01
	and #$0f
	sta lt_x
	lda #$e9
	sta lt_addr_hi
	jsr loadsector
	clc
	lda map_y
	adc #$01
	and #$0f
	sta lt_y
	lda #$eb
	sta lt_addr_hi
	jsr loadsector
	lda map_x
	sta lt_x
	lda #$ea
	sta lt_addr_hi
loadsector:
	lda lt_rwflag
	sta $a000
	lda #$01
	sta $a001
	lda #$00
	sta $a002
	lda lt_addr_hi
	sta $a003
	lda lt_y
	asl a
	asl a
	asl a
	asl a
	ora lt_x
	adc #$01
	sta $a004
	lda #$00
	adc #$00
	sta $a005
	jsr j_readblock
	bcs loadsector
	rts

waitkey:
	lda #$80
	sta idletimeout
@wait:
	jsr scankey
	jsr drawcursor
	jsr getkey
	bmi @gotkey
	jsr idle
	dec idletimeout
	bne @wait
	jsr clearcursor
	lda #$00
	rts

@gotkey:
	pha
	jsr clearcursor
	pla
	cmp #$00
	rts

idletimeout:
	.byte 0

idle:
	lda game_mode
	beq delay
	bmi idle_other
idle_britannia:
	cmp #$01
	bne idle_towne
	jsr update_wind
	jsr update_balloon
	jsr update_britannia
	rts

idle_towne:
	cmp #$02
	bne idle_dungeon
	jsr update_towne
	rts

idle_dungeon:
	cmp #$03
	bne idle_delay
	jsr scroll_tiles
	jsr animate_fields
	jsr L8C03
idle_delay:
	jmp delay

idle_other:
	cmp #$ff
	beq @animate
	jmp idle_combat

@animate:
	jmp animate_view

delay:
	ldx #$4b
	ldy #$00
@delay:
	dey
	bne @delay
	dex
	bne @delay
	rts

update_balloon:
	lda player_transport
	cmp #$18
	bne @done
	lda movement_mode
	beq @done
	dec movement_counter
	lda movement_counter
	and #$03
	bne @done
@east:
	ldx direction
	bne @south
	jmp move_east

@south:
	dex
	bne @west
	jmp move_south

@west:
	dex
	bne @north
	jmp move_west

@north:
	jmp move_north

@done:
	rts

movement_counter:
	.byte 0

animate_view:
	jsr scroll_tiles
	jsr animate_fields
	jmp drawview

idle_combat:
	jsr scroll_tiles
	jsr animate_fields
	ldx #$7f
@copy:
	lda tempmap,x
	sta currmap,x
	dex
	bpl @copy
	ldx #$0f
@nextmonster:
	ldy $ad10,x
	lda $9f49,y
	clc
	adc $ad00,x
	tay
	lda $ad50,x
	beq @next
	lda $ad70,x
	bne @dontanim
	lda $ad50,x
	cmp #$90
	bcs @checkmimic
	jsr rand
	and #$01
@settile:
	clc
	adc $ad50,x
	sta $ad60,x
	sta currmap,y
	jmp @next

@checkmimic:
	cmp #$ac
	bne @anim4
	lda $ad60,x
	cmp #$3c
	bne @anim4
	sta currmap,y
	jmp @next

@anim4:
	jsr rand
	and #$01
	beq @dontanim
	inc $ad60,x
	lda $ad60,x
	and #$03
	jmp @settile

@dontanim:
	lda $ad60,x
	sta currmap,y
@next:
	dex
	bpl @nextmonster
animateplayers:
	ldx party_size
@nextplayer:
	lda $ad9f,x
	beq @next
	ldy $ad8f,x
	lda $9f49,y
	clc
	adc $ad7f,x
	tay
	lda $ad9f,x
	cmp #$38
	beq @settile
	cpx $45
	bne @animate
	dec movement_counter
	lda movement_counter
	and #$03
	bne @animate
	lda #$7d
	jmp @settile

@animate:
	jsr rand
	and #$01
	clc
	adc $ad9f,x
@settile:
	sta currmap,y
@next:
	dex
	bne @nextplayer
	lda $adfd
	beq @done
	ldx $adff
	lda $9f49,x
	clc
	adc $adfe
	tay
	lda $adfd
	sta currmap,y
@done:
	jmp drawview

update_towne:
	jsr animate_creatures
	sec
	lda player_xpos
	sbc #$05
	sta $40
	sec
	lda player_ypos
	sbc #$05
	sta $41
	lda #$00
	sta $42
	sta $43
	tay
	tax
@nexttile:
	clc
	lda $40
	adc $42
	sta $44
	cmp #$20
	bcs @grass
	clc
	lda $41
	adc $43
	sta $45
	cmp #$20
	bcs @grass
	sta ptr2+1
	lda #$00
	lsr ptr2+1
	ror a
	lsr ptr2+1
	ror a
	lsr ptr2+1
	ror a
	adc $44
	sta ptr2
	clc
	lda ptr2+1
	adc #$e8
	sta ptr2+1
	lda (ptr2),y
	jmp @settile

@grass:
	lda #$04
@settile:
	sta tempmap,x
	inx
	inc $42
	lda $42
	cmp #$0b
	bne @nexttile
	sty $42
	inc $43
	lda $43
	cmp #$0b
	bne @nexttile
	jmp update_monsters

update_britannia:
	jsr animate_creatures
	jsr update_moons
	sec
	lda tile_xpos
	sbc #$05
	sta $40
	sec
	lda tile_ypos
	sbc #$05
	sta $41
	lda #$00
	sta $42
	sta $43
	tay
	tax
@copymap:
	clc
	lda $40
	adc $42
	sta $44
	clc
	lda $41
	adc $43
	sta $45
	jsr mul16
	sta ptr2
	lda $44
	and #$0f
	ora ptr2
	sta ptr2
	lda $45
	and #$10
	asl a
	ora $44
	jsr div16
	clc
	adc #$e8
	sta ptr2+1
	lda (ptr2),y
	sta tempmap,x
	inx
	inc $42
	lda $42
	cmp #$0b
	bne @copymap
	sty $42
	inc $43
	lda $43
	cmp #$0b
	bne @copymap
update_monsters:
	ldx #$1f
@nextmonster:
	lda map_status,x
	beq @nomonster
	lda object_xpos,x
	clc
	adc #$05
	sec
	sbc player_xpos
	cmp #$0b
	bcs @nomonster
	sta $44
	lda object_ypos,x
	clc
	adc #$05
	sec
	sbc player_ypos
	cmp #$0b
	bcs @nomonster
	sta $45
	ldy $45
	lda $9f49,y
	clc
	adc $44
	tay
	lda map_status,x
	sta tempmap,y
@nomonster:
	dex
	bpl @nextmonster
	lda moongate_tile
	beq @skipmoongates
	lda moongate_xpos
	clc
	adc #$05
	sec
	sbc player_xpos
	cmp #$0b
	bcs @skipmoongates
	sta $44
	lda moongate_ypos
	clc
	adc #$05
	sec
	sbc player_ypos
	cmp #$0b
	bcs @skipmoongates
	sta $45
	ldy $45
	lda $9f49,y
	clc
	adc $44
	tay
	lda moongate_tile
	sta tempmap,y
@skipmoongates:
	lda tempmap+49
	sta tile_north
	lda tempmap+71
	sta tile_south
	lda tempmap+61
	sta tile_east
	lda tempmap+59
	sta tile_west
	lda tempmap+60
	sta tile_under_player
	lda player_transport
	sta tempmap+60
	lda balloon_flying
	beq lineofsight
	ldx #$78
@copy:
	lda tempmap,x
	sta currmap,x
	dex
	bpl @copy
	jmp drawview

lineofsight:
	ldx #$78
	lda #$7e
@clear:
	sta currmap,x
	dex
	bpl @clear
	lda #$78
	sta $70
	lda #$0a
	sta $44
	sta $45
lospass1:
	lda $44
	sta $40
	lda $45
	sta $41
	lda $70
	sta $71
@nexttile:
	ldx $40
	ldy $41
	lda $71
	clc
	adc deltax,x
	clc
	adc deltay,y
	cmp #$3c
	beq @playertile
	sta $71
	tax
	lda tempmap,x
	cmp #$06
	beq @blocking
	cmp #$08
	beq @blocking
	cmp #$49
	beq @blocking
	cmp #$7e
	beq @blocking
	cmp #$7f
	beq @blocking
	lda $40
	tax
	clc
	adc deltax,x
	sta $40
	lda $41
	tax
	clc
	adc deltax,x
	sta $41
	jmp @nexttile

@playertile:
	ldx $70
	lda tempmap,x
	sta currmap,x
@blocking:
	dec $70
	dec $44
	bpl lospass1
	lda #$0a
	sta $44
	dec $45
	bpl lospass1
lospass2:
	lda #$78
	sta $70
	lda #$0a
	sta $44
	sta $45
@next:
	lda $44
	sta $40
	lda $45
	sta $41
	lda $70
	sta $71
	tax
	lda currmap,x
	cmp #$7e
	bne @blocking
@continue:
	ldx $40
	ldy $41
	lda distance,x
	cmp distance,y
	beq @diagonal
	bcc @vertical
	bcs @horizontal
@diagonal:
	lda $71
	clc
	adc deltax,x
	clc
	adc deltay,y
	jsr nexthoriz
	jsr nextvert
	jmp @checkblock

@horizontal:
	lda $71
	clc
	adc deltax,x
	jsr nexthoriz
	jmp @checkblock

@vertical:
	lda $71
	clc
	adc deltay,y
	jsr nextvert
@checkblock:
	cmp #$3c
	beq @playertile
	sta $71
	tax
	lda tempmap,x
	cmp #$06
	beq @blocking
	cmp #$08
	beq @blocking
	cmp #$49
	beq @blocking
	cmp #$7e
	beq @blocking
	cmp #$7f
	beq @blocking
	jmp @continue

@playertile:
	ldx $70
	lda tempmap,x
	sta currmap,x
@blocking:
	dec $70
	dec $44
	bpl @next
	lda #$0a
	sta $44
	dec $45
	bmi drawview
	jmp @next

drawview:
	lda ptr1
	pha
	lda ptr1+1
	pha
	lda ptr2
	pha
	lda ptr2+1
	pha
	lda $58
	pha
	lda $59
	pha
	lda #$00
	sta @mapptr
	lda #$29
	sta $58
	lda #$04
	sta $59
	ldy #$08
	lda bmplineaddr_lo,y
	sta ptr2
	lda bmplineaddr_hi,y
	sta ptr2+1
	lda ptr2
	clc
	adc #$08
	sta ptr2
	lda ptr2+1
	adc #$00
	sta ptr2+1
	lda #$00
	sta tilerow
@nextline:
	lda #$00
	sta tilenum
@nexttile:
	.byte $ac
@mapptr:
	.word $ae00

	tya
	pha
	jsr gettileaddr
	lda tilenum
	sec
	asl a
	tay
	pla
	tax
	lda tile_color,x
	sta ($58),y
	iny
	sta ($58),y
	pha
	tya
	clc
	adc #$27
	tay
	pla
	sta ($58),y
	iny
	sta ($58),y
	ldy #$0f
@drawupper:
	lda (ptr1),y
	sta (ptr2),y
	dey
	bpl @drawupper
	lda ptr1+1
	eor #$70
	sta ptr1+1
	lda ptr2
	pha
	clc
	adc #$40
	sta ptr2
	lda ptr2+1
	pha
	adc #$01
	sta ptr2+1
	ldy #$0f
@drawlower:
	lda (ptr1),y
	sta (ptr2),y
	dey
	bpl @drawlower
	lda ptr1+1
	eor #$70
	sta ptr1+1
	pla
	sta ptr2+1
	pla
	sta ptr2
	inc @mapptr
	lda ptr2
	clc
	adc #$10
	sta ptr2
	lda ptr2+1
	adc #$00
	sta ptr2+1
	inc tilenum
	lda tilenum
	cmp #$0b
	bne @nexttile
	lda $58
	clc
	adc #$50
	sta $58
	lda $59
	adc #$00
	sta $59
	lda ptr2
	clc
	adc #$d0
	sta ptr2
	lda ptr2+1
	adc #$01
	sta ptr2+1
	inc tilerow
	lda tilerow
	cmp #$0b
	beq @done
	jmp @nextline

@done:
	pla
	sta $59
	pla
	sta $58
	pla
	sta ptr2+1
	pla
	sta ptr2
	pla
	sta ptr1+1
	pla
	sta ptr1
	rts

tilenum:
	.byte 0
deltax:
	.byte 1, 1, 1, 1, 1, 0, <-1, <-1, <-1, <-1, <-1
deltay:
	.byte 11, 11, 11, 11, 11, 0, <-11, <-11, <-11, <-11, <-11
distance:
	.byte 5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5

nexthoriz:
	pha
	lda $40
	tax
	clc
	adc deltax,x
	sta $40
	pla
	rts

nextvert:
	pha
	lda $41
	tax
	clc
	adc deltax,x
	sta $41
	pla
	rts

animate_creatures:
	ldx #$00
@animate_next:
	lda object_tile,x
	beq @animend
	bpl @animate_nonmonster
	cmp #$90
	bcs @animate_monster
	cmp #$80
	beq @animdone
@animate_seamonster:
	jsr fastrand
	cmp #$c0
	bcs @animdone
	lda map_status,x
	eor #$01
	and #$01
	ora object_tile,x
	sta map_status,x
	jmp @animdone

@animate_monster:
	jsr fastrand
	cmp #$c0
	bcs @animdone
	lda map_status,x
	clc
	adc #$01
	and #$03
	ora object_tile,x
	sta map_status,x
	jmp @animdone

@animate_nonmonster:
	cmp #$50
	bcc @animate_player
	cmp #$60
	bcs @dontanim
@animate_npc:
	jmp @animate_seamonster

@animate_player:
	cmp #$20
	bcc @dontanim
	cmp #$30
	bcs @dontanim
	jmp @animate_seamonster

@dontanim:
	lda object_tile,x
	sta map_status,x
	jmp @animdone

@animend:
	lda #$00
	sta map_status,x
@animdone:
	inx
	cpx #$20
	bcc @animate_next
	jsr scroll_tiles
	jsr animate_fields
	jmp animate_flags

primm_xy:
	stx console_xpos
	sty console_ypos
primm:
	pla
	sta @primmaddr
	pla
	sta @primmaddr + 1
@next:
	inc @primmaddr
	bne @skip
	inc @primmaddr + 1
@skip:
@primmaddr	:= * + 1
	lda $ffff
	beq @done
	jsr console_out
	jmp @next

@done:
	lda @primmaddr + 1
	pha
	lda @primmaddr
	pha
	rts

console_out:
	cmp #$8d
	beq console_newline
	and #$7f
	ldx console_xpos
	cpx #$28
	bcc @noteol
	pha
	jsr console_newline
	pla
@noteol:
	jsr drawchar
	inc console_xpos
	rts

console_newline:
	lda #$18
	sta console_xpos
	inc console_ypos
	lda console_ypos
	cmp #$18
	bcc @notbottom
	dec console_ypos
	jsr console_scroll
@notbottom:
	rts

get_stats_ptr:
	lda currplayer
	sec
	sbc #$01
	jsr mul32
	sta ptr1
	lda #$aa
	sta ptr1+1
	rts

centername:
	jsr get_stats_ptr
	lda #$00
	sta zptmp1
@count:
	ldy zptmp1
	lda (ptr1),y
	beq @gotlen
	inc zptmp1
	lda zptmp1
	cmp #$0f
	bcc @count
@gotlen:
	lda #$0f
	sec
	sbc zptmp1
	lsr a
	clc
	adc console_xpos
	sta console_xpos
printname:
	jsr get_stats_ptr
	lda #$00
	sta zptmp1
@print:
	ldy zptmp1
	lda (ptr1),y
	beq @done
	jsr console_out
	inc zptmp1
	lda zptmp1
	cmp #$0f
	bcc @print
@done:
	rts

printname8:
	jsr get_stats_ptr
	lda #$00
	sta zptmp1
@print:
	ldy zptmp1
	lda (ptr1),y
	beq @done
	jsr console_out
	inc zptmp1
	lda zptmp1
	cmp #$08
	bcc @print
@done:
	rts

drawcursor_xy:
	stx console_xpos
	sty console_ypos
drawcursor:
	dec cursor_ctr
	lda cursor_ctr
	and #$7f
	ora #$7c
	bne dodrawcursor
clearcursor:
	lda #$20
dodrawcursor:
	jsr console_out
	dec console_xpos
	rts

cursor_ctr:
	.byte 0

printbcd:
	sta zptmp1
	jsr div16
	clc
	adc #$30
	jsr console_out
	lda zptmp1
	and #$0f
printdigit:
	clc
	adc #$30
	jmp console_out

clearstatwindow:
	jsr drawhoriz
	.byte $18, $00, $04, $05, $04, $05, $04, $05
	.byte $04, $05, $04, $05, $04, $05, $04, $05
	.byte $04, $ff

	ldx #$08
@clearstatline:
	lda bmplineaddr_lo,x
	sta ptr1
	lda bmplineaddr_hi,x
	sta ptr1+1
	lda ptr1
	clc
	adc #$c0
	sta ptr1
	lda ptr1+1
	adc #$00
	sta ptr1+1
	ldy #$00
@clear:
	lda #$00
	sta (ptr1),y
	iny
	cpy #$78
	bcc @clear
	txa
	clc
	adc #$08
	tax
	cpx #$48
	bcc @clearstatline
	rts

	.byte $cd


update_status:
	lda #$e5
	sta ptr1+1
	lda #$00
	sta ptr1
	ldx #$00
@next_virtue:
	lda virtues_and_stats,x
	beq @partial_avatar
	lda #$00
	beq @not_avatar
@partial_avatar:
	txa
	clc
	adc #$78
	tay
	lda (ptr1),y
@not_avatar:
	pha
	txa
	clc
	adc #$28
	tay
	pla
	sta (ptr1),y
	inx
	cpx #$08
	bne @next_virtue
	jsr stats_save_pos
	lda currplayer
	pha
	lda party_size
	sta currplayer
@nextplayer:
	ldx currplayer
	jsr get_stats_ptr
	lda currplayer
	sta console_ypos
	lda #$18
	sta console_xpos
	lda currplayer
	jsr printdigit
	lda #$ad
	jsr console_out
	jsr printname8
	lda #$23
	sta console_xpos
	jsr get_stats_ptr
	ldy #$18
	lda (ptr1),y
	jsr printdigit
	ldy #$19
	lda (ptr1),y
	jsr printbcd
	ldy #$12
	lda (ptr1),y
	jsr console_out
	jsr scankey
	dec currplayer
	bne @nextplayer
@printfood:
	ldx #$18
	ldy #$0a
	jsr primm_xy
	.byte "F:", 0

	ldy #$10
	lda virtues_and_stats,y
	jsr printbcd
	ldy #$11
	lda virtues_and_stats,y
	jsr printbcd
	lda #$a0
	jsr console_out
	lda magic_aura
	jsr console_out
	lda player_transport
	cmp #$14
	bcc @ship
	jsr primm
	.byte " G:", 0

	ldy #$13
	lda virtues_and_stats,y
	jsr printbcd
	ldy #$14
	lda virtues_and_stats,y
	jsr printbcd
	jmp @done

@ship:
	jsr primm
	.byte " SHP:", 0

	lda ship_hull
	jsr printbcd
@done:
	pla
	sta currplayer
	jmp stats_rest_pos

stats_saved_xpos:
	.byte 0
stats_saved_ypos:
	.byte 0

update_wind:
	jsr rand
	bne @nochange
	jsr rand
	jsr getsign
	clc
	adc direction
	and #$03
	sta direction
@nochange:
	jsr stats_save_pos
	lda #$17
	sta console_ypos
	lda #$06
	sta console_xpos
	jsr primm
	.byte $1e, "Wind ", 0

	ldx direction
	beq @west
	dex
	beq @north
	dex
	beq @east
	dex
	beq @south
	bne @done
@west:
	jsr printwest
	jmp @done

@north:
	jsr printnorth
	jmp @done

@east:
	jsr printeast
	jmp @done

@south:
	jsr printsouth
@done:
	lda #$1d
	jsr console_out
	jmp stats_rest_pos

print_direction:
	jsr stats_save_pos
	lda #$17
	sta console_ypos
	lda #$07
	sta console_xpos
	jsr primm
	.byte "Dir: ", 0

	ldx dng_direction
	beq @north
	dex
	beq @east
	dex
	beq @south
	bne @west
@north:
	jsr printnorth
	jmp @printlevel

@east:
	jsr printeast
	jmp @printlevel

@south:
	jsr printsouth
	jmp @printlevel

@west:
	jsr printwest
@printlevel:
	lda #$00
	sta console_ypos
	lda #$0b
	sta console_xpos
	lda #$cc
	jsr console_out
	lda dungeon_level
	clc
	adc #$01
	jsr printdigit
	jmp stats_rest_pos

printnorth:
	jsr primm
	.byte "North", 0

	rts

printsouth:
	jsr primm
	.byte "South", 0

	rts

printeast:
	jsr primm
	.byte " East", 0

	rts

printwest:
	jsr primm
	.byte " West", 0

	rts

getsign:
	cmp #$00
	beq @zero
	bmi @negative
	lda #$01
	rts

@negative:
	lda #$ff
@zero:
	rts

stats_save_pos:
	lda console_xpos
	sta stats_saved_xpos
	lda console_ypos
	sta stats_saved_ypos
	rts

stats_rest_pos:
	lda stats_saved_xpos
	sta console_xpos
	lda stats_saved_ypos
	sta console_ypos
	rts

getnumdel:
	dec console_xpos
getnumber:
	jsr waitkey
	sec
	sbc #$b0
	cmp #$0a
	bcs getnumber
	sta bcdnum
	sta hexnum
	jsr printdigit
@seconddigit:
	jsr waitkey
	cmp #$8d
	beq @done
	cmp #$94
	beq getnumdel
	sec
	sbc #$b0
	cmp #$0a
	bcs @seconddigit
	sta hexnum
	jsr printdigit
@notretordel:
	jsr waitkey
	cmp #$8d
	beq @convhex
	cmp #$94
	bne @notretordel
	dec console_xpos
	bpl @seconddigit
@convhex:
	lda bcdnum
	jsr mul16
	ora hexnum
	sta bcdnum
	ldx #$00
	sed
	sec
@count:
	sbc #$01
	bcc @counted
	inx
	bne @count
@counted:
	stx hexnum
	cld
@done:
	rts

getplayernum:
	jsr waitkey
	beq @gotnum
	sec
	sbc #$b0
	cmp #$09
	bcc @gotnum
	lda #$00
@gotnum:
	sta currplayer
	jsr printdigit
	jsr console_newline
	lda currplayer
	rts

blocked_tile:
	ldx #$28
@next:
	dex
	bmi @blocked
	cmp walkable_tiles,x
	bne @next
	rts

@blocked:
	lda #$ff
	rts

walkable_tiles:
	.byte $03, $04, $05, $06, $07, $09, $0a, $0b
	.byte $0c, $10, $11, $12, $13, $14, $15, $16
	.byte $17, $18, $19, $1a, $1b, $1c, $1d, $1e
	.byte $3c, $3e, $3f, $43, $44, $46, $47, $49
	.byte $4a, $4c, $4c, $4c, $8c, $8d, $8e, $8f

clearbitmap:
	lda #$00
	sta ptr1
	tay
	ldx #$20
	stx ptr1+1
@clear:
	sta (ptr1),y
	iny
	bne @clear
	inc ptr1+1
	dex
	bne @clear
	rts

clearchars:
	lda #$00
	sta ptr1
	lda #$04
	sta ptr1+1
	ldx #$04
	ldy #$00
	lda #$10
@clear:
	sta (ptr1),y
	iny
	bne @clear
	inc ptr1+1
	dex
	bne @clear
	rts

clearview:
	lda #$40
	sta ptr1
	lda #$21
	sta ptr1+1
	ldx #$01
@nextline:
	lda #$00
	ldy #$08
@clear:
	sta (ptr1),y
	iny
	cpy #$b8
	bne @clear
	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1+1
	adc #$01
	sta ptr1+1
	inx
	cpx #$17
	bne @nextline
	rts

invertview:
	lda #$40
	sta ptr1
	lda #$21
	sta ptr1+1
	ldx #$01
@nextline:
	ldy #$08
@invert:
	lda (ptr1),y
	eor #$ff
	sta (ptr1),y
	iny
	cpy #$b8
	bne @invert
	lda ptr1
	clc
	adc #$40
	sta ptr1
	lda ptr1+1
	adc #$01
	sta ptr1+1
	inx
	cpx #$17
	bne @nextline
	rts

mulax:
	sta zptmp1
	lda #$00
	cpx #$00
	beq @zero
@add:
	clc
	adc zptmp1
	dex
	bne @add
@zero:
	rts

	lda tile_ypos
	jsr mul16
	sta ptr2
	lda tile_xpos
	and #$0f
	ora ptr2
	sta ptr2
	lda tile_ypos
	and #$10
	asl a
	ora tile_xpos
	jsr div16
	clc
	adc #$e8
	sta ptr2+1
	rts

scroll_tiles:
	lda #$00
	jsr @save_and_scroll
	lda #$01
	jsr @save_and_scroll
	lda #$02
	jsr @save_and_scroll
	lda #$4c
	jmp @save_and_scroll

@save_and_scroll:
	tay
	txa
	pha
	lda ptr1
	pha
	lda ptr1+1
	pha
	jsr @scroll
	pla
	sta ptr1+1
	pla
	sta ptr1
	pla
	tax
	rts

@scroll:
	jsr gettileaddr
	jsr @shiftcolumn
	lda ptr1
	clc
	adc #$08
	sta ptr1
@shiftcolumn:
	ldy #$00
	lda (ptr1),y
	sta @savebyte
	iny
	ldx #$0f
@shift:
	lda (ptr1),y
	pha
	lda @savebyte
	sta (ptr1),y
	pla
	sta @savebyte
	iny
	cpy #$08
	bne @s
	ldy #$00
	lda ptr1+1
	eor #$70
	sta ptr1+1
@s:	dex
	bne @shift
	ldy #$00
	lda @savebyte
	sta (ptr1),y
	rts

@savebyte:
	.byte $22


gettileaddr:
	sty ptr1
	lda #$00
	sta ptr1+1
	asl ptr1
	rol ptr1+1
	asl ptr1
	rol ptr1+1
	asl ptr1
	rol ptr1+1
	asl ptr1
	rol ptr1+1
	lda ptr1+1
	clc
	adc #$b0
	sta ptr1+1
	rts

animate_fields:
	ldy #$44
	jsr gettileaddr
	jsr fillrand
	lda ptr1+1
	eor #$70
	sta ptr1+1
	jsr fillrand
	ldy #$4a
	jsr gettileaddr
	jmp randfire
	lda ptr1+1
	eor #$70
	sta ptr1+1
	jsr randfire
	rts

fillrand:
	ldy #$00
@fill:
	jsr fastrand
	sta (ptr1),y
	iny
	cpy #$40
	bne @fill
	rts

randfire:
	ldy #$0f
@rand:
	jsr fastrand
	and $b4a0,y
	eor $b4b0,y
	sta $b4b0,y
	jsr fastrand
	and $c4a0,y
	eor $c4b0,y
	sta $c4b0,y
	dey
	bpl @rand
	rts

	cpy #$08
	bne :+
	ldy #$00
	lda ptr1+1
	eor #$70
	sta ptr1+1
:	rts


animate_flags:
	jsr fastrand
	bmi @castle
	ldx $b0a3
	ldy $b0a4
	sty $b0a3
	stx $b0a4
@castle:
	jsr fastrand
	bmi @lbcastle
	ldx $b0b9
	ldy $b0ba
	sty $b0b9
	stx $b0ba
@lbcastle:
	jsr fastrand
	bmi @shipwest
	ldx $b0e1
	ldy $b0e2
	sty $b0e1
	stx $b0e2
@shipwest:
	jsr fastrand
	bmi @shipeast
	ldx $b102
	ldy $b103
	sty $b102
	stx $b103
	ldx $b10a
	ldy $b10b
	sty $b10a
	stx $b10b
@shipeast:
	jsr fastrand
	bmi @flagsdone
	ldx $b122
	ldy $b123
	sty $b122
	stx $b123
	ldx $b12a
	ldy $b12b
	sty $b12a
	stx $b12b
@flagsdone:
	rts

div32:
	lsr a
div16:
	lsr a
	lsr a
	lsr a
	lsr a
	rts

mul32:
	asl a
mul16:
	asl a
	asl a
	asl a
	asl a
	rts

scankey:
	lda $c6
	php
	lda $0277
	ora #$80
	plp
	beq @done
	cmp #$a0
	bne @notspace
	ldy #$00
	sty key_buf_len
@notspace:
	nop
	ldy key_buf_len
	cpy #$08
	bcs @done
	sta key_buf,y
	inc key_buf_len
	jsr clearkbd
@done:
	rts

clearkbd:
	pha
	lda #$00
	sta $c6
	pla
	rts

getkey:
	lda key_buf_len
	beq @empty
	lda key_buf
	pha
	dec key_buf_len
	beq @gotkey
	ldy #$00
@movebuf:
	lda key_buf+1,y
	sta key_buf,y
	iny
	cpy key_buf_len
	bcc @movebuf
@gotkey:
	pla
	cmp #$00
@empty:
	rts

rand:
	txa
	pha
	clc
	ldx #$0e
	lda rndf
@add:
	adc rnd0,x
	sta rnd0,x
	dex
	bpl @add
	ldx #$0f
@inc:
	inc rnd0,x
	bne @done
	dex
	bpl @inc
@done:
	pla
	tax
	lda rnd0
	rts

rnd0:
	.byte $64
rnd1:
	.byte $76
rnd2:
	.byte $85
rnd3:
	.byte $54, $f6, $5c, $76, $1f, $e7, $12, $a7
	.byte $6b, $93, $c4, $6e
rndf:
	.byte $1b

fastrand:
	lda rnd3
	adc rnd2
	sta rnd2
	eor rnd1
	sta rnd1
	adc rnd0
	sta rnd0
	sta rnd3
	rts

console_scroll:
	ldx #$60
doscroll:
	lda bmplineaddr_lo,x
	clc
	adc #$c0
	sta @scrolldst
	lda bmplineaddr_hi,x
	adc #$00
	sta @scrolldst+1
	lda bmplineaddr_lo+8,x
	clc
	adc #$c0
	sta @scrollsrc
	lda bmplineaddr_hi+8,x
	adc #$00
	sta @scrollsrc+1
	ldy #$00
@scroll:
@scrollsrc = * + 1
	lda $ffff,y
@scrolldst = * + 1
	sta $ffff,y

	iny
	bpl @scroll
	txa
	lsr a
	lsr a
	lsr a
	tay
	lda chrlineaddr_lo,y
	sta @scdst
	lda chrlineaddr_hi,y
	sta @scdst+1
	lda chrlineaddr_lo+1,y
	sta @scsrc
	lda chrlineaddr_hi+1,y
	sta @scsrc+1
	ldy #$18
@scrollchar:
@scsrc = * + 1
	lda $ffff,y
@scdst = * + 1
	sta $ffff,y

	iny
	cpy #$28
	bne @scrollchar
	txa
	clc
	adc #$08
	tax
	cpx #$b8
	bne doscroll
	jsr drawhoriz
	.byte $18, $17, $20, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $20, $20
	.byte $20, $20, $ff

	rts

drawchar:
	sta charptr
	lda console_ypos
	asl a
	asl a
	asl a
	sta charptr+1
	lda charptr
	jsr mul8
	sta @charsrc
	txa
	clc
	adc #$e4
	sta @charsrc+1
	ldy charptr+1
	lda bmplineaddr_lo,y
	sta @chardst
	lda bmplineaddr_hi,y
	sta @chardst+1
	lda console_xpos
	jsr mul8
	clc
	adc @chardst
	sta @chardst
	txa
	adc @chardst+1
	sta @chardst+1
	ldy #$07
@drawchar:
@charsrc = * + 1
	lda $ffff,y
@chardst = * + 1
	sta $ffff,y

	dey
	bpl @drawchar
	ldy console_ypos
	lda chrlineaddr_lo,y
	sta @charaddr
	lda chrlineaddr_hi,y
	sta @charaddr+1
	ldy charptr
	lda $e2b0,y
	ldy console_xpos
@charaddr = * + 1
	sta $ffff,y

	ldy #$00
	rts

mul8:
	pha
	lda #$00
	sta @msb
	pla
	asl a
	rol @msb
	asl a
	rol @msb
	asl a
	rol @msb
	ldx @msb
	rts

@msb:
	.byte $2c


drawvert:
	lda #$80
	sta draw_hvflag
	jmp dodrawvh

drawhoriz:
	lda #$00
	sta draw_hvflag
dodrawvh:
	lda console_xpos
	sta draw_savex
	lda console_ypos
	sta draw_savey
	pla
	sta ptr2
	pla
	sta ptr2+1
	jsr @next
	ldy #$00
	lda (ptr2),y
	sta console_xpos
	jsr @next
	lda (ptr2),y
	sta console_ypos
@draw:
	jsr @next
	lda (ptr2),y
	bmi @drawdone
	jsr drawchar
	bit draw_hvflag
	bmi @vert
	inc console_xpos
	jmp @draw

@vert:
	inc console_ypos
	jmp @draw

@drawdone:
	lda ptr2+1
	pha
	lda ptr2
	pha
	lda draw_savex
	sta console_xpos
	lda draw_savey
	sta console_ypos
	rts

@next:
	inc ptr2
	bne @gotnext
	inc ptr2+1
@gotnext:
	rts

draw_hvflag:
	.byte 0
draw_savex:
	.byte 0
draw_savey:
	.byte 0

drawinterface:
	jsr clearbitmap
	jsr clearchars
	jsr drawhoriz
	.byte $00, $00, $10, $05, $04, $05, $04, $05
	.byte $04, $05, $04, $05, $1e, $20, $20, $1d
	.byte $04, $05, $04, $05, $04, $05, $04, $05
	.byte $04, $01, $04, $05, $04, $05, $04, $05
	.byte $04, $05, $04, $05, $04, $05, $04, $05
	.byte $04, $13, $ff

	jsr drawvert
	.byte $00, $01, $0a, $0a, $0a, $0a, $0a, $0a
	.byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	.byte $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	.byte $14, $ff

	jsr drawhoriz
	.byte $01, $17, $03, $02, $03, $02, $03, $02
	.byte $03, $02, $03, $02, $03, $02, $03, $02
	.byte $03, $02, $03, $02, $03, $02, $03, $02
	.byte $ff

	jsr drawvert
	.byte $17, $01, $0d, $0d, $0d, $0d, $0d, $0d
	.byte $0d, $0d, $09, $0d, $09, $0d, $0d, $0d
	.byte $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	.byte $0b, $ff

	jsr drawvert
	.byte $27, $01, $09, $09, $09, $09, $09, $09
	.byte $09, $09, $01, $09, $05, $ff

	jsr drawhoriz
	.byte $18, $09, $06, $07, $06, $07, $06, $07
	.byte $06, $07, $06, $07, $06, $07, $06, $07
	.byte $06, $ff

	jsr drawhoriz
	.byte $18, $0b, $06, $07, $06, $07, $06, $07
	.byte $06, $07, $06, $07, $06, $07, $06, $07
	.byte $06, $ff

	rts

moon_gfx:
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $10, $20, $40, $40, $20, $10, $00
	.byte $00, $10, $30, $70, $70, $30, $10, $00
	.byte $00, $18, $38, $7c, $7c, $38, $18, $00
	.byte $00, $18, $3c, $7e, $7e, $3c, $18, $00
	.byte $00, $18, $1c, $3e, $3e, $1c, $18, $00
	.byte $00, $08, $0c, $0e, $0e, $0c, $08, $00
	.byte $00, $08, $04, $02, $02, $04, $08, $00

update_moons:
	txa
	pha
	clc
	lda moon_counter
	adc #$40
	sta moon_counter
	bne @noupdate
	inc moon_ctr_trammel
	inc moon_ctr_trammel
	lda moon_ctr_trammel
	and #$e0
	lsr a
	lsr a
	tay
	ldx #$00
@trammel:
	lda moon_gfx,y
	sta $2058,x
	iny
	inx
	cpx #$08
	bne @trammel
	clc
	lda moon_ctr_felucca
	adc #$06
	sta moon_ctr_felucca
	and #$e0
	lsr a
	lsr a
	tay
	pha
	ldx #$00
@felucca:
	lda moon_gfx,y
	sta $2060,x
	iny
	inx
	cpx #$08
	bne @felucca
	pla
	tay
@noupdate:
	pla
	tax
	lda moon_ctr_trammel
	jsr div32
	sta moon_phase_trammel
	lda moon_ctr_felucca
	jsr div32
	sta moon_phase_felucca
	lda moon_ctr_trammel
	and #$1f
	beq @moongate_appears
	cmp #$1e
	beq @moongate_disappears
	rts

@moongate_appears:
	jsr moongate_update
	lda $71
	clc
	adc #$40
	sta moongate_tile
	rts

@moongate_disappears:
	jsr moongate_update
	lda $71
	eor #$03
	clc
	adc #$40
	sta moongate_tile
	rts

moongate_update:
	lda moon_ctr_trammel
	and #$e0
	jsr div32
	tax
	lda moongate_xtab,x
	sta moongate_xpos
	lda moongate_ytab,x
	sta moongate_ypos
	lda moon_counter
	and #$c0
	rol a
	rol a
	rol a
	sta $71
	rts

moon_counter:
	.byte 0
moon_ctr_trammel:
	.byte 0
moon_ctr_felucca:
	.byte 0
moongate_xtab:
	.byte $e0, $60, $26, $32, $a6, $68, $17, $bb
moongate_ytab:
	.byte $85, $66, $e0, $25, $13, $c2, $7e, $a7

request_disk:
	sta reqdisk
@request:
	sta numdrives
	rts
	.byte $02
	beq @twodrives
	cmp #$04
	beq @twodrives
@onedrive:
	lda #$01
	sta currdrive
	lda reqdisk
	cmp currdisk_drive1
	beq @checkdisk
@askchange:
	jsr primm
	.byte $8d
	.byte "PLEASE PLACE THE", $8d
	.byte 0

	jsr askdisk
	jsr primm
	.byte " DISK", $8d
	.byte "INTO DEVICE ", 0

	lda currdrive
	clc
	adc #$07
	jsr printdigit
	jsr primm
	.byte $8d
	.byte "AND PRESS [F1]", $8d
	.byte 0

@wait:
	jsr waitkey
	cmp #$85
	bne @wait
	beq @checkdisk
@twodrives:
	lda numdrives
	cmp #$02
	bcc @onedrive
	lda #$02
	sta currdrive
	lda reqdisk
	cmp currdisk_drive2
	beq @checkdisk
	bne @askchange
@checkdisk:
	lda currdrive
	lda #$cc
	ldx #$00
	jsr j_fileio
	ldx currdrive
	lda diskid
	sta numdrives,x
	cmp reqdisk
	beq @done
	jmp @request

@done:
	rts

askdisk:
	ldx reqdisk
@program:
	dex
	bne @britannia
	jsr primm
	.byte "PROGRAM", 0

	rts

@britannia:
	dex
	bne @towne
	jsr primm
	.byte "BRITANNIA", 0

	rts

@towne:
	dex
	bne @underworld
	jsr primm
	.byte "TOWNE", 0

	rts

@underworld:
	jsr primm
	.byte "UNDERWORLD", 0

	rts

playsfx:
	jsr @play
	lda #$0f
	sta $d418
	rts

@play:
	asl a
	tay
	lda sfxtab+1,y
	pha
	lda sfxtab,y
	pha
	rts

sfxtab:
	.word sfx_walk-1
	.word sfx_error2-1
	.word sfx_error1-1
	.word sfx_ship_fire-1
	.word sfx_attack-1
	.word sfx_unknown-1
	.word sfx_player_hits-1
	.word sfx_monster_hits-1
	.word sfx_flee-1
	.word sfx_magic2-1
	.word sfx_magic1-1
	.word sfx_whirlpool-1
	.word sfx_storm-1

sfx_walk:
	ldy #$06
@repeat:
	jsr rand
	and #$3f
	ora #$20
	tax
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	dey
	bne @repeat
	rts

sfx_error2:
	ldy #$32
@delay:
	pha
	pla
	dex
	bne @delay
	jsr j_togglesnd
	dey
	bne @delay
	rts

sfx_error1:
	ldy #$32
@delay:
	nop
	nop
	dex
	bne @delay
	jsr j_togglesnd
	dey
	bne @delay
	jmp sfx_error2

sfx_ship_fire:
	ldx #$00
	stx zptmp1
@delay:
	inx
	bne @delay
	jsr j_togglesnd
	dec zptmp1
	ldx zptmp1
	bne @delay
	rts

sfx_attack:
	lda #$ff
	tax
	tay
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	dey
	tya
	tax
	bmi @delay
	rts

sfx_unknown:
	lda #$80
	tax
	tay
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	iny
	tya
	tax
	bmi @delay
	rts

sfx_player_hits:
	ldy #$ff
@repeat:
	jsr rand
	and #$7f
	tax
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	dey
	bne @repeat
	rts

sfx_monster_hits:
	ldy #$ff
@repeat:
	jsr rand
	ora #$80
	tax
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	dey
	bne @repeat
	rts

sfx_magic2:
	stx sfx_m2_ctr2
	lda #$01
	sta sfx_m2_ctr1
@1:	lda #$30
	sta $70
@2:	ldx sfx_m2_ctr2
@3:	dex
	bne @3
	jsr j_togglesnd
	ldx sfx_m2_ctr1
@4:	dex
	bne @4
	jsr j_togglesnd
	dec $70
	bne @2
	dec sfx_m2_ctr2
	inc sfx_m2_ctr1
	lda sfx_m2_ctr1
	cmp #$1b
	bne @1
@5:	lda #$30
	sta $70
@6:	ldx sfx_m2_ctr2
@7:	dex
	bne @7
	jsr j_togglesnd
	ldx sfx_m2_ctr1
@8:	dex
	bne @8
	jsr j_togglesnd
	dec $70
	bne @6
	dec sfx_m2_ctr1
	inc sfx_m2_ctr2
	lda sfx_m2_ctr1
	cmp #$00
	bne @5
	rts

sfx_m2_ctr1:
	brk
sfx_m2_ctr2:
	brk
sfx_flee:
	ldx #$7f
	stx zptmp1
@delay:
	dex
	bne @delay
	jsr j_togglesnd
	dec zptmp1
	ldx zptmp1
	bne @delay
	rts

sfx_magic1:
	stx $70
@again:
	jsr rand
	ldx #$28
@repeat:
	tay
@delay:
	dey
	bne @delay
	jsr j_togglesnd
	dex
	bne @repeat
	dec $70
	bne @again
	rts

sfx_whirlpool:
	lda #$40
@1:	ldy #$20
@2:	tax
@3:	pha
	pla
	dex
	bne @3
	jsr j_togglesnd
	dey
	bne @2
	clc
	adc #$01
	cmp #$c0
	bcc @1
	rts

sfx_storm:
	lda #$c0
@1:	ldy #$20
@2:	tax
@3:	pha
	pla
	dex
	bne @3
	jsr j_togglesnd
	dey
	bne @2
	sec
	sbc #$01
	cmp #$40
	bcs @1
	rts

centerstring:
	pha
	tay
	lda #$ba
	sta ptr1
	lda #$1b
	sta ptr1+1
	ldx #$00
	stx $58
@checkeos:
	lda (ptr1,x)
	bpl @endofstr
@next:
	jsr nextstrchar
	jmp @checkeos

@endofstr:
	dey
	beq @foundstr
	jmp @next

@foundstr:
	jsr nextstrchar
	ldx #$00
	lda (ptr1,x)
	bpl @lastchar
	inc $58
	jmp @foundstr

@lastchar:
	inc $58
	lda #$0f
	sec
	sbc $58
	lsr a
	clc
	adc console_xpos
	sta console_xpos
	pla
printstring:
	tay
	lda #$ba
	sta ptr1
	lda #$1b
	sta ptr1+1
	ldx #$00
@checkeos:
	lda (ptr1,x)
	bpl @endofstr
@next:
	jsr nextstrchar
	jmp @checkeos

@endofstr:
	dey
	beq @foundstr
	jmp @next

@foundstr:
	jsr nextstrchar
	ldx #$00
	lda (ptr1,x)
	bpl @lastchar
	jsr console_out
	jmp @foundstr

@lastchar:
	ora #$80
	jmp console_out

nextstrchar:
	inc ptr1
	bne @nomsb
	inc ptr1+1
@nomsb:
	rts

; String terminated by most significant bit in last character.
  .macro msbstring str
    .repeat (.strlen(str) - 1), I
	.byte .strat(str, I)
    .endrepeat
	.byte .strat(str, (.strlen(str) - 1)) ^ $80
  .endmacro


strings:
	.byte 0
	msbstring "Pirate"
	msbstring "Pirate"
	msbstring "Nixie"
	msbstring "Squid"
	msbstring "Serpent"
	msbstring "Seahorse"
	msbstring "Whirlpool"
	msbstring "Twister"
	msbstring "Rat"
	msbstring "Bat"
	msbstring "Spider"
	msbstring "Ghost"
	msbstring "Slime"
	msbstring "Troll"
	msbstring "Gremlin"
	msbstring "Mimic"
	msbstring "Reaper"
	msbstring "Insects"
	msbstring "Gazer"
	msbstring "Phantom"
	msbstring "Orc"
	msbstring "Skeleton"
	msbstring "Rogue"
	msbstring "Python"
	msbstring "Ettin"
	msbstring "Headless"
	msbstring "Cyclops"
	msbstring "Wisp"
	msbstring "Mage"
	msbstring "Liche"
	msbstring "Lava Lizard"
	msbstring "Zorn"
	msbstring "Daemon"
	msbstring "Hydra"
	msbstring "Dragon"
	msbstring "Balron"
	msbstring "Hands"
	msbstring "Staff"
	msbstring "Dagger"
	msbstring "Sling"
	msbstring "Mace"
	msbstring "Axe"
	msbstring "Sword"
	msbstring "Bow"
	msbstring "Crossbow"
	msbstring "Flaming Oil"
	msbstring "Halberd"
	msbstring "Magic Axe"
	msbstring "Magic Sword"
	msbstring "Magic Bow"
	msbstring "Magic Wand"
	msbstring "Mystic Sword"
	msbstring "Skin"
	msbstring "Cloth"
	msbstring "Leather"
	msbstring "Chain Mail"
	msbstring "Plate Mail"
	msbstring "Magic Chain"
	msbstring "Magic Plate"
	msbstring "Mystic Robe"
	msbstring "HND"
	msbstring "STF"
	msbstring "DAG"
	msbstring "SLN"
	msbstring "MAC"
	msbstring "AXE"
	msbstring "SWD"
	msbstring "BOW"
	msbstring "XBO"
	msbstring "OIL"
	msbstring "HAL"
	msbstring "+AX"
	msbstring "+SW"
	msbstring "+BO"
	msbstring "WND"
	msbstring "^SW"
	msbstring "Mage"
	msbstring "Bard"
	msbstring "Fighter"
	msbstring "Druid"
	msbstring "Tinker"
	msbstring "Paladin"
	msbstring "Ranger"
	msbstring "Shepherd"
	msbstring "Guard"
	msbstring "Merchant"
	msbstring "Bard"
	msbstring "Jester"
	msbstring "Beggar"
	msbstring "Child"
	msbstring "Bull"
	msbstring "Lord British"
	msbstring "Sulfur Ash"
	msbstring "Ginseng"
	msbstring "Garlic"
	msbstring "Spider Silk"
	msbstring "Blood Moss"
	msbstring "Black Pearl"
	msbstring "Nightshade"
	msbstring "Mandrake"
	msbstring "Awaken"
	msbstring "Blink"
	msbstring "Cure"
	msbstring "Dispel"
	msbstring "Energy"
	msbstring "Fireball"
	msbstring "Gate"
	msbstring "Heal"
	msbstring "Iceball"
	msbstring "Jinx"
	msbstring "Kill"
	msbstring "Light"
	msbstring "Magic Misl"
	msbstring "Negate"
	msbstring "Open"
	msbstring "Protection"
	msbstring "Quickness"
	msbstring "Resurrect"
	msbstring "Sleep"
	msbstring "Tremor"
	msbstring "Undead"
	msbstring "View"
	msbstring "Winds"
	msbstring "X-It"
	msbstring "Y-Up"
	msbstring "Z-Down"
	msbstring "Britannia"
	msbstring "The Lycaeum"
	msbstring "Empath Abbey"
	msbstring "Serpent's Hold"
	msbstring "Moonglow"
	msbstring "Britain"
	msbstring "Jhelom"
	msbstring "Yew"
	msbstring "Minoc"
	msbstring "Trinsic"
	msbstring "Skara Brae"
	msbstring "Magincia"
	msbstring "Paws"
	msbstring "Buccaneer's Den"
	msbstring "Vesper"
	msbstring "Cove"
	msbstring "Deceit"
	msbstring "Despise"
	msbstring "Destard"
	msbstring "Wrong"
	msbstring "Covetous"
	msbstring "Shame"
	msbstring "Hythloth"
	.byte "The Great", $8D
	msbstring "Stygian Abyss!"
	msbstring "Honesty"
	msbstring "Compassion"
	msbstring "Valor"
	msbstring "Justice"
	msbstring "Sacrifice"
	msbstring "Honor"
	msbstring "Spirituality"
	msbstring "Humility"
