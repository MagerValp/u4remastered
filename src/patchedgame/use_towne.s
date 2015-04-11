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

@have_bell:
	jmp print_no_effect

use_book:
	lda items
	and #$02
	bne @have_book
	jmp print_none_owned

@have_book:
	jmp print_no_effect

use_candle:
	lda items
	and #$01
	bne @have_candle
	jmp print_none_owned

@have_candle:
	jmp print_no_effect

use_key:
	lda threepartkey
	bne @have_key
	jmp print_none_owned

@have_key:
	jmp print_no_effect

use_horn:
	lda horn
	bne @have_horn
	jmp print_none_owned

@have_horn:
	jmp print_no_effect

use_wheel:
	lda wheel
	bne @have_wheel
	jmp print_none_owned

@have_wheel:
	jmp print_no_effect

use_skull:
	lda skull
	cmp #$01
	beq @have_skull
	jmp print_none_owned

@have_skull:
	jsr j_primm
	.byte $8d
	.byte "You hold the", $8d
	.byte "evil skull of", $8d
	.byte "Mondain the", $8d
	.byte "wizard aloft....", $8d
	.byte 0

	ldx #$1f
@clear:
	lda #$00
	ldy object_tile,x
	cpy #$5e
	beq @lord_british
	sta object_tile,x
	sta map_status,x
	sta $acc0,x
	sta $ace0,x
	jmp @skip

@lord_british:
	lda #$ff
	sta $acc0,x
@skip:
	dex
	bpl @clear
	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
	jsr j_invertview
	jsr shake_screen
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
	jsr j_togglesnd
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
	jsr j_togglesnd
@skip:
	inx
	cpx #$ae
	bcc @next
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
	.byte "THOU HAST LOST", $8d
	.byte "AN EIGHTH!", $8d
	.byte 0

	lda #$99
	ldy $59
	jmp @continue

@_garbage:
	.byte	$CE,$8D,$C9,$CE,$D4,$CF,$A0,$D4 ; 8ABE	NMINTO T
	.byte	$C8,$C5,$A0,$C1,$C2,$D9,$D3,$D3 ; 8AC6	HE ABYSS
	.byte	$A1,$8D,$00,$A9,$FF,$8D,$17,$AB ; 8ACE	!M.).MW+
	.byte	$A9,$07,$85,$6A,$A0,$6A,$A9,$10 ; 8AD6	)GEj j)P
	.byte	$20,$04,$8C,$C6,$6A,$10,$F5,$20 ; 8ADE	 DLFjPu 
	.byte	$86,$8B,$20,$78,$08,$20,$86,$8B ; 8AE6	FK xH FK
	.byte	$20,$78,$08,$20,$86,$8B,$60,$A9 ; 8AEE	 xH FK`)
	.byte	$BF,$20,$24,$08,$A9,$00,$85,$6A ; 8AF6	? $H).Ej
	.byte	$20,$00,$08,$C9,$8D,$F0,$2C,$C9 ; 8AFE	 .HIMp,I
	.byte	$94,$F0,$16,$C9,$A0,$90,$F1,$A6 ; 8B06	TpVI Pq&
	.byte	$6A,$9D,$00,$AF,$20,$24,$08,$E6 ; 8B0E	j]./ $Hf
	.byte	$6A,$A5,$6A,$C9,$0F,$90,$E1,$B0 ; 8B16	j%jIOPa0
	.byte	$12,$A5,$6A,$F0,$DB,$C6,$6A,$C6 ; 8B1E	R%jp[FjF
	.byte	$4E,$A9,$A0,$20,$24,$08,$C6,$4E ; 8B26	N)  $HFN
	.byte	$4C,$FE,$8A,$A6,$6A,$A9,$A0,$9D ; 8B2E	L~J&j) ]
	.byte	$00,$AF,$E8,$E0,$06,$90,$F8,$A9 ; 8B36	./h`FPx)
	.byte	$8D,$20,$24,$08,$60,$A9,$07,$85 ; 8B3E	M $H`)GE
	.byte	$6A,$A5,$6A,$0A,$0A,$A8,$A2,$00 ; 8B46	j%jJJ(".
	.byte	$B9,$66,$8B,$DD,$00,$AF,$D0,$09 ; 8B4E	9fK]./PI
	.byte	$C8,$E8,$E0,$04,$90,$F2,$A5,$6A ; 8B56	Hh`DPr%j
	.byte	$60,$C6,$6A,$10,$E4,$A5,$6A,$60 ; 8B5E	`FjPd%j`
	.byte	$D3,$D4,$CF,$CE,$C2,$C5,$CC,$CC ; 8B66	STONBELL
	.byte	$C2,$CF,$CF,$CB,$C3,$C1,$CE,$C4 ; 8B6E	BOOKCAND
	.byte	$CB,$C5,$D9,$A0,$C8,$CF,$D2,$CE ; 8B76	KEY HORN
	.byte	$D7,$C8,$C5,$C5,$D3,$CB,$D5,$CC ; 8B7E	WHEESKUL
	.byte	$A9,$06,$20,$54,$08,$20,$D3,$8B ; 8B86	)F TH SK
	.byte	$20,$A4,$8B,$20,$D3,$8B,$20,$A4 ; 8B8E	 $K SK $
	.byte	$8B,$20,$D3,$8B,$20,$A4,$8B,$20 ; 8B96	K SK $K 
	.byte	$D3,$8B,$20,$A4,$8B,$60,$A2,$AE ; 8B9E	SK $K`".
	.byte	$BD,$09,$E0,$85,$7E,$BD,$C9,$E0 ; 8BA6	=I`E~=I`
	.byte	$85,$7F,$BD,$07,$E0,$85,$7C,$BD ; 8BAE	E.=G`E|=
	.byte	$C7,$E0,$85,$7D,$A0,$B0,$B1,$7C ; 8BB6	G`E} 01|
	.byte	$91,$7E,$98,$38,$E9,$08,$A8,$D0 ; 8BBE	Q~X8iH(P
	.byte	$F5,$20,$4E,$08,$30,$03,$2C,$09 ; 8BC6	u NH0C,I
	.byte	$A1,$CA,$D0,$D4,$60,$A2,$00,$BD ; 8BCE	!JPT`".=
	.byte	$08,$E0,$85,$7E,$BD,$C8,$E0,$85 ; 8BD6	H`E~=H`E
	.byte	$7F,$BD,$0A,$E0,$85,$7C,$BD,$CA ; 8BDE	.=J`E|=J
	.byte	$E0,$85,$7D,$A0,$B0,$B1,$7C,$91 ; 8BE6	`E} 01|Q
	.byte	$7E,$98,$38,$E9,$08,$A8,$D0,$F5 ; 8BEE	~X8iH(Pu
	.byte	$20,$4E,$08,$30,$03,$2C,$09,$A1 ; 8BF6	 NH0C,I!
	.byte	$E8,$E0,$AE,$90,$D2,$60,$85,$59 ; 8BFE	h`.PR`EY
	.byte	$F8,$18,$B9,$00,$AB,$F0,$06,$65 ; 8C06	xX9.+pFe
	.byte	$59,$90,$02,$A9,$99,$99,$00,$AB ; 8C0E	YPB)YY.+
	.byte	$D8,$60,$85,$5A,$84,$59,$B9,$00 ; 8C16	X`EZDY9.
	.byte	$AB,$F0,$0F,$F8,$38,$E5,$5A,$F0 ; 8C1E	+pOx8eZp
	.byte	$02,$B0,$02,$A9,$01,$99,$00,$AB ; 8C26	B0B)AY.+
	.byte	$D8,$60,$20,$21,$08,$8D,$D4,$C8 ; 8C2E	X` !HMTH
	.byte	$CF,$D5,$A0,$C8,$C1,$D3,$D4,$A0 ; 8C36	OU HAST 
	.byte	$CC,$CF,$D3,$D4,$8D,$C1,$CE,$A0 ; 8C3E	LOSTMAN 
	.byte	$C5,$C9,$C7,$C8,$D4,$C8,$A1,$8D ; 8C46	EIGHTH!M
	.byte	$00,$A9,$99,$A4,$59,$4C,$21,$8C ; 8C4E	.)Y$YL!L
	.byte	$00,$20,$54,$08,$20,$23,$83,$A5 ; 8C56	. TH #C%
	.byte	$24,$F0,$06,$20,$9D,$44,$20,$4B ; 8C5E	$pF ]D K
	.byte	$08,$20,$9D,$44,$4C,$2E,$62,$A9 ; 8C66	H ]DL.b)
	.byte	$10,$85,$1E,$20,$AF,$45,$20,$23 ; 8C6E	PE^ /E #
	.byte	$83,$4C,$2E,$62,$20,$B9,$45,$20 ; 8C76	CL.b 9E 
	.byte	$23,$83,$A5,$4C,$20,$B9,$46,$10 ; 8C7E	#C%L 9FP
	.byte	$03,$4C,$EE,$41,$A9,$00,$20,$96 ; 8C86	CLnA). V
	.byte	$6A,$F0,$06,$20,$74,$41,$4C,$2E ; 8C8E	jpF tAL.
	.byte	$62,$20,$09,$08,$4C,$2E,$62,$A5 ; 8C96	b IHL.b%
	.byte	$4C,$20,$48,$08,$10,$05,$68,$68 ; 8C9E	L HHPEhh
	.byte	$4C,$EE,$41,$A5,$4C,$20,$84,$46 ; 8CA6	LnA%L DF
	.byte	$F0,$06,$20,$74,$41,$4C,$D4,$44 ; 8CAE	pF tALTD
	.byte	$A9,$00,$20,$54,$08,$A5,$1B,$C9 ; 8CB6	). TH%[I
	.byte	$01,$D0,$08,$20,$09,$08,$A5,$4C ; 8CBE	APH IH%L
	.byte	$4C,$76,$86,$C6,$10,$A5,$10,$10 ; 8CC6	LvFFP%PP
	.byte	$05,$68,$68,$4C,$1D,$46,$60,$A5 ; 8CCE	EhhL]F`%
	.byte	$1B,$C9,$03,$D0,$1F,$20,$AF,$45 ; 8CD6	[ICP_ /E
	.byte	$20,$21,$08,$F2,$E9,$E7,$E8,$F4 ; 8CDE	 !Hright
	.byte	$8D,$00,$18,$A5,$20,$69,$01,$29 ; 8CE6	M.X% iA)
	.byte	$03,$85,$20,$20,$00,$8C,$20,$72 ; 8CEE	CE  .L r
	.byte	$08,$4C,$7B,$40,$A5,$1E,$C9,$18 ; 8CF6	HL{@%^IX
	.byte	$D0,$03,$F9,$A0,$ED,$E1,$F9,$A0 ; 8CFE	PCy may 
	.byte	$E2,$E5,$8D,$EC,$EF,$F3,$F4,$A0 ; 8D06	beMlost 
	.byte	$E6,$EF,$F2,$E5,$F6,$E5,$F2,$AE ; 8D0E	forever.
	.byte	$00,$20,$7D,$91,$20,$21,$08,$8D ; 8D16	. }Q !HM
	.byte	$8D,$D2,$E5,$F4,$F5,$F2,$EE,$A0 ; 8D1E	MReturn 
	.byte	$EE,$EF,$F7,$A0,$F5,$EE,$F4,$EF ; 8D26	now unto
	.byte	$8D,$F4,$E8,$E9,$EE,$E5,$A0,$EF ; 8D2E	Mthine o
	.byte	$F7,$EE,$A0,$F7,$EF,$F2,$EC,$E4 ; 8D36	wn world
	.byte	$AC,$8D,$EC,$E9,$F6,$E5,$A0,$F4 ; 8D3E	,Mlive t
	.byte	$E8,$E5,$F2,$E5,$A0,$E1,$F3,$A0 ; 8D46	here as 
	.byte	$E1,$EE,$8D,$E5,$F8,$E1,$ED,$F0 ; 8D4E	anMexamp
	.byte	$EC,$E5,$A0,$F4,$EF,$A0,$F4,$E8 ; 8D56	le to th
	.byte	$F9,$8D,$F0,$E5,$EF,$F0,$EC,$E5 ; 8D5E	yMpeople
	.byte	$AC,$A0,$E1,$F3,$A0,$EF,$F5,$F2 ; 8D66	, as our
	.byte	$8D,$ED,$E5,$ED,$EF,$F2,$F9,$A0 ; 8D6E	Mmemory 
	.byte	$EF,$E6,$A0,$F4,$E8,$F9,$8D,$E7 ; 8D76	of thyMg
	.byte	$E1,$EC,$EC,$E1,$EE,$F4,$A0,$E4 ; 8D7E	allant d
	.byte	$E5,$E5,$E4,$F3,$8D,$F3,$E5,$F2 ; 8D86	eedsMser
	.byte	$F6,$E5,$F3,$A0,$F5,$F3,$AE,$00 ; 8D8E	ves us..
	.byte	$20,$7D,$91,$20,$75,$08,$20,$CF ; 8D96	 }Q uH O
	.byte	$92,$20,$21,$08,$8D,$8D,$C1,$F3 ; 8D9E	R !HMMAs
	.byte	$A0,$F4,$E8,$E5,$A0,$F3,$EF,$F5 ; 8DA6	 the sou
	.byte	$EE,$E4,$A0,$EF,$E6,$8D,$F4,$E8 ; 8DAE	nd ofMth
	.byte	$E5,$A0,$F6,$EF,$E9,$E3,$E5,$A0 ; 8DB6	e voice 
	.byte	$F4,$F2,$E1,$E9,$EC,$F3,$8D,$EF ; 8DBE	trailsMo
	.byte	$E6,$E6,$AC,$A0,$E4,$E1,$F2,$EB ; 8DC6	ff, dark
	.byte	$EE,$E5,$F3,$F3,$8D,$F3,$E5,$E5 ; 8DCE	nessMsee
	.byte	$ED,$F3,$A0,$F4,$EF,$A0,$F2,$E9 ; 8DD6	ms to ri
	.byte	$F3,$E5,$8D,$E1,$F2,$EF,$F5,$EE ; 8DDE	seMaroun
	.byte	$E4,$A0,$F9,$EF,$F5,$AE,$8D,$D4 ; 8DE6	d you.MT
	.byte	$E8,$E5,$F2,$E5,$A0,$E9,$F3,$A0 ; 8DEE	here is 
	.byte	$E1,$8D,$ED,$EF,$ED,$E5,$EE,$F4 ; 8DF6	aMmoment
	.byte	$A0,$EF 			; 8DFE	 o
