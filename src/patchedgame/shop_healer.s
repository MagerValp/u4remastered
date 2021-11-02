	.include "uscii.i"

;
; **** ZP ABSOLUTE ADDRESSES **** 
;
current_location = $1a
party_size = $1f
currplayer = $54
zptmp_cost = $58
zptmp_virtue1 = $59
zptmp_virtue2 = $5a
zptmp_shop_num = $6a
zptmp_timer = $6a
zptmp_row_count = $70
ptr1 = $7e
;ptr1 + 1 = $7f
;
; **** ZP POINTERS **** 
;
;ptr1 = $7e
;
; **** USER LABELS **** 
;
j_waitkey = $0800
j_primm = $0821
j_console_out = $0824
j_get_stats_ptr = $082d
j_update_status = $0845
j_update_view = $084b
j_playsfx = $0854
j_getplayernum = $085d
stats = $ab00
gold_hi = $ab13
bmplineaddr_lo = $e000
bmplineaddr_hi = $e0c0



	.segment "OVERLAY"

	jsr j_primm
	.byte $8d
	.byte "Welcome unto", $8d
	.byte 0
	ldx current_location
	dex 
	lda location_table,x
	sta zptmp_shop_num
	dec zptmp_shop_num
	jsr print_string
	jsr print_newline
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$0b
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "Peace and joy be", $8d
	.byte "with you friend.", $8d
	.byte "Are you in need", $8d
	.byte "of help?", 0
	jsr input_char
	cmp #$d9
	beq menu
	jmp try_donate

menu:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$0b
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "We can perform:", $8d
	.byte "A-Curing", $8d
	.byte "B-Healing", $8d
	.byte "C-Resurrection", $8d
	.byte "Your need:", 0
	jsr input_char
	cmp #$c1
	bne :+
	jmp ask_cure
:	cmp #$c2
	bne :+
	jmp ask_heal
:	cmp #$c3
	bne :+
	jmp ask_resurrect
:	jmp try_donate

ask_cure:
	jsr ask_which_player
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$d0
	beq is_poisoned
	jsr j_primm
	.byte $8d
	.byte "Thou suffers not", $8d
	.byte "from poison!", $8d
	.byte 0
	jmp ask_more

is_poisoned:
	jsr j_primm
	.byte $8d
	.byte "A curing will", $8d
	.byte "cost thee 100gp.", $8d
	.byte 0
	lda gold_hi
	beq @no_money
	jmp try_cure

@no_money:
	jsr j_primm
	.byte $8d
	.byte "I see by thy", $8d
	.byte "purse that thou", $8d
	.byte "hast not enough", $8d
	.byte "gold.", 0
	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "I will", $8d
	.byte "cure thee for", $8d
	.byte "free, but give", $8d
	.byte "unto others when", $8d
	.byte "ever thou may!", $8d
	.byte 0
	jmp do_cure

try_cure:
	lda #$01
	jsr ask_pay
do_cure:
	jsr j_get_stats_ptr
	ldy #$12
	lda #$c7     ;(g)ood
	sta (ptr1),y
	jsr special_fx
	jsr j_update_status
	jmp ask_more

ask_heal:
	jsr ask_which_player
	jsr j_primm
	.byte $8d
	.byte "A healing will", $8d
	.byte "cost thee 200gp.", $8d
	.byte 0
	lda gold_hi
	cmp #$02
	bcs try_heal
	jmp cannot_afford

try_heal:
	lda #$02
	jsr ask_pay
	jsr j_get_stats_ptr
	ldy #$1a
	lda (ptr1),y
	ldy #$18
	sta (ptr1),y
	ldy #$1b
	lda (ptr1),y
	ldy #$19
	sta (ptr1),y
	jsr special_fx
	jsr j_update_status
	jmp ask_more

ask_resurrect:
	jsr ask_which_player
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c4
	beq is_dead
	jsr j_primm
	.byte $8d
	.byte "Thou art not", $8d
	.byte "dead fool!", $8d
	.byte 0
	jmp ask_more

is_dead:
	jsr j_primm
	.byte $8d
	.byte "Resurrection", $8d
	.byte "will cost thee", $8d
	.byte "300gp.", $8d
	.byte 0
	lda gold_hi
	cmp #$03
	bcs do_resurrect
cannot_afford:
	jsr j_primm
	.byte $8d
	.byte "I see by thy", $8d
	.byte "purse that thou", $8d
	.byte "hast not enough", $8d
	.byte "gold. I cannot", $8d
	.byte "aid thee.", $8d
	.byte 0
	jmp ask_more

do_resurrect:
	lda #$03
	jsr ask_pay
	jsr j_get_stats_ptr
	ldy #$12
	lda #$c7     ;(g)ood
	sta (ptr1),y
	jsr special_fx
	jsr j_update_status
	jmp ask_more

ask_which_player:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$0b
	jsr print_string
	jsr j_primm
	.byte " asks:", $8d
	.byte "Who is in need?", 0
	jsr j_getplayernum
	bne @validate
	jsr j_primm
	.byte $8d
	.byte "No one?", $8d
	.byte 0
	pla 
	pla 
	jmp ask_more

@validate:
	cmp party_size
	bcc @valid
	beq @valid
	jmp ask_which_player

@valid:
	rts 

ask_more:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$0b
	jsr print_string
	jsr j_primm
	.byte " asks:", $8d
	.byte "Do you need", $8d
	.byte "more help?", 0
	jsr input_char
	cmp #$d9
	bne try_donate
	jmp menu

try_donate:
	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$18
	lda (ptr1),y
	cmp #$04
	bcs ask_donate
bye:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$0b
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "May thy life", $8d
	.byte "be guarded by", $8d
	.byte "the powers of", $8d
	.byte "good.", $8d
	.byte 0
	rts 

ask_donate:
	jsr j_primm
	.byte $8d
	.byte "Art thou willing", $8d
	.byte "to give 100pts", $8d
	.byte "of thy blood to", $8d
	.byte "aid others?", 0
	jsr input_char
	cmp #$ce
	beq no_donate
	cmp #$d9
	beq yes_donate
	jmp ask_donate

no_donate:
	ldy #$04
	lda #$05
	jsr deduct_virtue
	jmp bye

yes_donate:
	ldy #$04     ;sacrifice
	lda #$05
	jsr accrue_virtue
	jsr j_primm
	.byte $8d
	.byte "Thou art a", $8d
	.byte "great help, we", $8d
	.byte "are in dire", $8d
	.byte "need!", $8d
	.byte 0
	jsr j_get_stats_ptr
	ldy #$18
	lda (ptr1),y
	sec 
	sed 
	sbc #$01
	cld 
	sta (ptr1),y
	lda #$0a
	sta zptmp_timer
:	jsr j_update_view
	dec zptmp_timer
	bne :-
	jmp bye

ask_pay:
	sta zptmp_cost
	jsr j_primm
	.byte $8d
	.byte "Wilt thou pay?", 0
	jsr input_char
	cmp #$d9
	beq deduct_gold
	pla 
	pla 
	jsr j_primm
	.byte $8d
	.byte "Then I cannot", $8d
	.byte "aid thee.", $8d
	.byte 0
	jmp ask_more

deduct_gold:
	sed 
	sec 
	lda gold_hi
	sbc zptmp_cost
	sta gold_hi
	cld 
	rts 

special_fx:
	jsr invertview
	jsr invert_player
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr invert_player
	jsr invertview
	rts 

	.byte 0
location_table:
	.byte $01,$02,$03,$04,$05,$06,$07,$08
	.byte $00,$00,$09,$00,$00,$00,$00,$0a
	.byte $25,$40,$35,$20,$30

input_char:
	jsr j_waitkey
	beq input_char
	pha 
	jsr j_console_out
	lda #$8d
	jsr j_console_out
	pla 
	rts 

; unused
encode_bcd_value:
	cmp #$00
	beq @done
	cmp #$63
	bcs @max
	sed 
	tax 
	lda #$00
@dec:
	clc 
	adc #$01
	dex 
	bne @dec
	beq @done
@max:
	lda #$99
@done:
	cld 
	rts 

; unused
decode_bcd_value:
	cmp #$00
	beq @done
	ldx #$00
	sed 
@inc:
	inx 
	sec 
	sbc #$01
	bne @inc
	txa 
	cld 
@done:
	rts 

print_newline:
	lda #$8d
	jsr j_console_out
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

string_table:
	.byte 0
	.byte "The Royal Healer", 0
	.byte "The Truth Healer", 0
	.byte "The Love Healer", 0
	.byte "Courage Healer", 0
	.byte "The Healer", 0
	.byte "Wound Healing", 0
	.byte "Heal and Health", 0
	.byte "Just Healing", 0
	.byte "The Mystic Heal", 0
	.byte "The Healer Shop", 0
	.byte "Pendragon", 0
	.byte "Starfire", 0
	.byte "Salle'", 0
	.byte "Windwalker", 0
	.byte "Harmony", 0
	.byte "Celest", 0
	.byte "Triplet", 0
	.byte "Justin", 0
	.byte "Spiran", 0
	.byte "Quat", 0

; unused
invert_all_players:
	lda party_size
	sta currplayer
@next:
	jsr invert_player
	dec currplayer
	bne @next
	rts 

invert_player:
	lda currplayer
	asl 
	asl 
	asl 
	tax 
	lda bmplineaddr_lo,x
	clc 
	adc #$c0
	sta ptr1
	lda bmplineaddr_hi,x
	adc #$00
	sta ptr1 + 1
	ldy #$00
@next:
	lda (ptr1),y
	eor #$ff
	sta (ptr1),y
	iny 
	cpy #$78
	bne @next
	rts 

invertview:
	lda #$16
	sta zptmp_row_count
	lda bmplineaddr_lo + 8
	clc 
	adc #$08
	sta ptr1
	lda bmplineaddr_hi + 8  ; BUG FIX, was bmplineaddr_lo in original
	adc #$00
	sta ptr1 + 1
@nextline:
	ldy #$00
@invert:
	lda (ptr1),y
	eor #$ff
	sta (ptr1),y
	iny 
	cpy #$b0
	bne @invert
	lda ptr1
	clc 
	adc #$40
	sta ptr1
	lda ptr1 + 1
	adc #$01
	sta ptr1 + 1
	dec zptmp_row_count
	bne @nextline
	rts 

accrue_virtue:
	sta zptmp_virtue1
	sed 
	clc 
	lda stats,y
	beq @skip
	adc zptmp_virtue1
	bcc @skip
	lda #$99
@skip:
	sta stats,y
	cld 
	rts 

deduct_virtue:
	sta zptmp_virtue2
	sty zptmp_virtue1
	lda stats,y
	beq lost_an_eighth
lost_rts:
	sed 
	sec 
	sbc zptmp_virtue2
	beq @underflow
	bcs :+
@underflow:
	lda #$01
:	sta stats,y
	cld 
	rts 

lost_an_eighth:
	jsr j_primm
	.byte $8d
	.byte "Thou hast lost", $8d
	.byte "an eighth!", $8d
	.byte 0
	ldy zptmp_virtue1
	lda #$99
	jmp lost_rts

; Garbage leftover in sector at end of file

;	.byte $d7,$c1,$d3,$a0,$d4,$c8,$c5,$8d
;	.byte $cf,$cc,$c4
