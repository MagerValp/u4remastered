	.include "uscii.i"

;
; **** ZP ABSOLUTE ADDRESSES **** 
;
;tile_xpos = $12
;tile_ypos = $13
current_location = $1a
console_xpos = $4e
console_ypos = $4f
;currplayer = $54
;hexnum = $56
;bcdnum = $57
zptmp_item_type = $58
zptmp_display_pos = $59
;zptmp1 = $5a
zptmp_char_count = $6a
zptmp_shop_num = $6a
zptmp_inv_num = $70
zptmp_mismatches = $70
;ptr2 = $7c
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
j_primm_xy = $081e
j_primm = $0821
j_console_out = $0824
j_printbcd = $0833
j_update_status = $0845
j_printdigit = $0866
j_clearstatwindow = $0869
stats = $ab00
;stats + 1 = $ab01
weapons = $ab20
inbuf = $af00
shop_price_carry = $8700



	.segment "OVERLAY"

	jsr j_primm
	.byte $8d
	.byte "Welcome to", $8d
	.byte 0
	ldx current_location
	dex 
	lda location_table,x
	sta zptmp_shop_num
	dec zptmp_shop_num
	jsr print_string
	jsr print_newline
@buy_or_sell:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$07
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "Welcome friend,", $8d
	.byte "art thou here to", $8d
	.byte 0
	jsr j_primm
	.byte "buy or sell?", 0
	jsr input_char
	cmp #$c2
	beq @buy
	cmp #$d3
	bne @buy_or_sell
	jmp sell

@buy:
	jsr j_primm
	.byte $8d
	.byte "Very good,", $8d
	.byte 0
buy_menu:
	jsr j_primm
	.byte "we have:", $8d
	.byte "A-NOTHING", $8d
	.byte 0
	lda #$00
	sta zptmp_inv_num
@next_item:
	lda zptmp_shop_num
	asl 
	asl 
	adc zptmp_inv_num
	tay 
	lda inventory,y
	sta zptmp_item_type
	clc 
	adc #$c1
	jsr j_console_out
	lda #$ad
	jsr j_console_out
	lda zptmp_item_type
	clc 
	adc #$0d
	jsr print_string
	jsr j_primm
	.byte "s", $8d
	.byte 0
	inc zptmp_inv_num
	lda zptmp_inv_num
	cmp #$04
	bcc @next_item

; prompt
	jsr j_primm
	.byte "Your interest?", 0
	jsr display_owned
	jsr input_char
	pha 
	jsr j_clearstatwindow
	jsr j_update_status
	pla 
	sec 
	sbc #$c1
	bne :+
	jmp bye
:	sta zptmp_item_type
	jsr print_newline
	lda #$03
	sta zptmp_inv_num
@find_stock:
	lda zptmp_shop_num
	asl 
	asl 
	adc zptmp_inv_num
	tay 
	lda inventory,y
	cmp zptmp_item_type
	beq @found
	dec zptmp_inv_num
	bpl @find_stock
	jmp buy_menu

@found:
	lda zptmp_item_type
	clc 
	adc #$1d
	jsr print_string
@ask_buy:
	jsr j_primm
	.byte $8d
	.byte "Would you like", $8d
	.byte "to buy one?", 0
	jsr input_char
	pha 
	jsr print_newline
	pla 
	cmp #$d9
	beq try_spend
	cmp #$ce
	bne @ask_buy
	jsr j_primm
	.byte "Too bad.", $8d
	.byte 0
@more:
	jsr j_primm
	.byte "Anything else?", 0
	jsr input_char
	cmp #$d9
	bne :+
	jmp buy_menu
:	cmp #$ce
	bne @more
bye:
	jsr print_newline
	clc 
	lda zptmp_shop_num
	adc #$07
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "Fare thee well!", $8d
	.byte 0
	rts 

try_spend:
	lda zptmp_item_type
	asl 
	tay 
	lda price,y
	sta payment
	lda price + 1,y
	sta payment + 1
	ldy #$13     ;gold
	sed 
	sec 
	lda stats + 1,y
	sbc payment + 1
	lda stats,y
	sbc payment
	cld 
	bcs do_spend
	jsr j_primm
	.byte $8d
	.byte "I fear you", $8d
	.byte "have not the", $8d
	.byte "funds, perhaps", $8d
	.byte "something else.", $8d
	.byte 0
	jmp buy_menu

payment:
	.byte $00,$00

do_spend:
	sed 
	sec 
	lda stats + 1,y
	sbc payment + 1
	sta stats + 1,y
	lda stats,y
	sbc payment
	sta stats,y
	clc 
	ldy zptmp_item_type
	lda weapons,y
	adc #$01
	bcs :+
	sta weapons,y
:	cld 
	jsr j_update_status
	clc 
	lda zptmp_shop_num
	adc #$07
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "A fine choice!", $8d
	.byte "Anything else?", $8d
	.byte 0
	jmp buy_menu

sell:
	jsr j_primm
	.byte $8d
	.byte "Excellent, what", $8d
	.byte "wouldst thou", $8d
	.byte "like to sell?", 0
sell_menu:
	jsr display_owned
	jsr input_char
	pha 
	jsr j_clearstatwindow
	jsr j_update_status
	pla 
	sec 
	sbc #$c1
	sta zptmp_item_type
	beq @bye
	cmp #$10
	bcs @bye
	tay 
	lda weapons,y
	bne @make_offer
	jsr j_primm
	.byte $8d
	.byte "Thou dost not", $8d
	.byte "own that.", $8d
	.byte "What else might", $8d
	.byte "you sell?", 0
	jmp sell_menu

@bye:
	jmp bye

; PRICE_FIX: mace costs 100, sell for 50 not 0
@make_offer:
	lda zptmp_item_type
	asl 
	tay 
	lda price,y
	jsr decode_bcd_value
	lsr 
	php      ;PRICE_FIX
	jsr encode_bcd_value
	sta payment
	lda price + 1,y
	jsr decode_bcd_value
	plp      ;PRICE_FIX
	bcc :+   ;PRICE_FIX
	adc shop_price_carry  ;PRICE_FIX add 100
:	lsr 
	jsr encode_bcd_value
	sta payment + 1
	jsr j_primm
	.byte $8d
	.byte "I will give you", $8d
	.byte 0
	lda payment
	beq :+
	jsr j_printbcd
:	lda payment + 1
	jsr j_printbcd
	jsr j_primm
	.byte "gp for that.", $8d
	.byte 0
	lda zptmp_item_type
	clc 
	adc #$0d
	jsr print_string
	jsr print_newline
@confirm:
	jsr j_primm
	.byte "Deal?", 0
	jsr input_char
	cmp #$d9
	beq @sell_item
	cmp #$ce
	bne @confirm
	jsr j_primm
	.byte "Hmmph, what", $8d
	.byte "else then?", 0
	jmp sell_menu

@sell_item:
	sed 
	clc 
	ldy #$13
	lda stats + 1,y
	adc payment + 1
	sta stats + 1,y
	lda stats,y
	adc payment
	sta stats,y
	bcc @skip_overflow
	lda #$99
	sta stats,y
	sta stats + 1,y
@skip_overflow:
	sec 
	ldy zptmp_item_type
	lda weapons,y
	sbc #$01
	sta weapons,y
	cld 
	jsr j_update_status
	jsr j_primm
	.byte "Fine, what", $8d
	.byte "else?", 0
	jmp sell_menu

; map location to shop number
location_table:
	.byte $00,$00,$00,$00,$00,$01,$02,$00
	.byte $03,$04,$00,$00,$00,$05,$06,$00

inventory:
	.byte $01,$02,$03,$06
	.byte $05,$06,$08,$0a
	.byte $04,$0a,$0b,$0c
	.byte $04,$05,$06,$07
	.byte $08,$09,$0d,$0e
	.byte $02,$03,$07,$09

price:
	.byte $00,$00
	.byte $00,$20
	.byte $00,$02
	.byte $00,$25
	.byte $01,$00
	.byte $02,$25
	.byte $03,$00
	.byte $02,$50
	.byte $06,$00
	.byte $00,$05
	.byte $03,$50
	.byte $15,$00
	.byte $25,$00
	.byte $20,$00
	.byte $50,$00
	.byte $70,$00

input_char:
	jsr j_waitkey
	beq input_char
	pha 
	jsr j_console_out
	lda #$8d
	jsr j_console_out
	pla 
	rts 

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
	.byte "Windsor Weaponry", 0
	.byte "Willard's", $8d
	.byte "Weaponry", 0
	.byte "The Iron Works", 0
	.byte "Duelling Weapons", 0
	.byte "Hook's Arms", 0
	.byte "Village Arms", 0
	.byte "Winston", 0
	.byte "Willard", 0
	.byte "Peter", 0
	.byte "Jumar", 0
	.byte "Hook", 0
	.byte "Wendy", 0
	.byte "HANDS", 0
	.byte "STAFF", 0
	.byte "DAGGER", 0
	.byte "SLING", 0
	.byte "MACE", 0
	.byte "AXE", 0
	.byte "SWORD", 0
	.byte "BOW", 0
	.byte "CROSSBOW", 0
	.byte "FLAMING OIL", 0
	.byte "HALBERD", 0
	.byte "MAGIC AXE", 0
	.byte "MAGIC SWORD", 0
	.byte "MAGIC BOW", 0
	.byte "MAGIC WAND", 0
	.byte "MYSTIC SWORD", 0
	.byte "HANDS", $8d
	.byte 0
	.byte "We are the only", $8d
	.byte "staff makers in", $8d
	.byte "Britannia, yet", $8d
	.byte "sell them for", $8d
	.byte "only 20gp.", $8d
	.byte 0
	.byte "We sell the", $8d
	.byte "most deadly of", $8d
	.byte "daggers, a", $8d
	.byte "bargain at", $8d
	.byte "only 2gp each.", $8d
	.byte 0
	.byte "Our slings are", $8d
	.byte "made from only", $8d
	.byte "the finest gut", $8d
	.byte "and leather,", $8d
	.byte "'tis yours", $8d
	.byte "for 25gp.", $8d
	.byte 0
	.byte "These maces have", $8d
	.byte "a hardened shaft", $8d
	.byte "and a 5lb head,", $8d
	.byte "fairly priced", $8d
	.byte "at 100gp.", $8d
	.byte 0
	.byte "Notice the fine", $8d
	.byte "workmanship on", $8d
	.byte "this axe, you'll", $8d
	.byte "agree 225gp is", $8d
	.byte "a good price.", $8d
	.byte 0
	.byte "The fine work", $8d
	.byte "on these swords", $8d
	.byte "will be the", $8d
	.byte "dread of thy", $8d
	.byte "Foes, for 300gp.", $8d
	.byte 0
	.byte "Our bows are", $8d
	.byte "made of finest", $8d
	.byte "yew, and the", $8d
	.byte "arrows willow, a", $8d
	.byte "steal at 250gp.", $8d
	.byte 0
	.byte "Crossbows made", $8d
	.byte "by Iolo the Bard", $8d
	.byte "are the finest", $8d
	.byte "in the world,", $8d
	.byte "yours for 600gp.", $8d
	.byte 0
	.byte "Flasks of oil", $8d
	.byte "make great", $8d
	.byte "weapons and", $8d
	.byte "create a wall", $8d
	.byte "of fire too,", $8d
	.byte "5gp each.", $8d
	.byte 0
	.byte "A halberd is", $8d
	.byte "a mighty weapon", $8d
	.byte "to attack over", $8d
	.byte "obstacles; a", $8d
	.byte "must and", $8d
	.byte "only 350gp.", $8d
	.byte 0
	.byte "This magical axe", $8d
	.byte "can be thrown at", $8d
	.byte "thy enemy and", $8d
	.byte "will then", $8d
	.byte "return, all for", $8d
	.byte "1500gp.", $8d
	.byte 0
	.byte "Magical swords", $8d
	.byte "such as these", $8d
	.byte "are rare indeed!", $8d
	.byte "I will part with", $8d
	.byte "one for 2500gp.", $8d
	.byte 0
	.byte "A magical bow", $8d
	.byte "will keep thy", $8d
	.byte "enemies far away", $8d
	.byte "or dead! A", $8d
	.byte "must for 2000gp!", $8d
	.byte 0
	.byte "This magic wand", $8d
	.byte "casts mighty", $8d
	.byte "blue bolts to", $8d
	.byte "strike down thy", $8d
	.byte "foes, 5000gp.", $8d
	.byte 0
	.byte "Mystic swords", $8d
	.byte "are an unknown", $8d
	.byte 0
	.byte "HND", 0
	.byte "STF", 0
	.byte "DAG", 0
	.byte "SLN", 0
	.byte "MAC", 0
	.byte "AXE", 0
	.byte "SWD", 0
	.byte "BOW", 0
	.byte "XBO", 0
	.byte "OIL", 0
	.byte "HAL", 0
	.byte "+AX", 0
	.byte "+SW", 0
	.byte "+BO", 0
	.byte "WND", 0
	.byte "^SW", 0

; unused
get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta zptmp_char_count
@get_char:
	jsr j_waitkey
	cmp #$8d
	beq @got_input
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @get_char
	ldx zptmp_char_count
	sta inbuf,x
	jsr j_console_out
	inc zptmp_char_count
	lda zptmp_char_count
	cmp #$0f
	bcc @get_char
	bcs @got_input
@backspace:
	lda zptmp_char_count
	beq @get_char
	dec zptmp_char_count
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @get_char

@got_input:
	ldx zptmp_char_count
	lda #$a0
@pad_spaces:
	sta inbuf,x
	inx 
	cpx #$06
	bcc @pad_spaces
	lda #$8d
	jsr j_console_out
	rts 

; unused
check_inline_keyword:
	pla 
	sta ptr1
	pla 
	sta ptr1 + 1
	ldy #$00
	sty zptmp_mismatches
	ldx #$ff
@next:
	inx 
	inc ptr1
	bne :+
	inc ptr1 + 1
:	lda (ptr1),y
	beq @done
	cmp inbuf,x
	beq @next
	inc zptmp_mismatches
	jmp @next
@done:
	lda ptr1 + 1
	pha 
	lda ptr1
	pha 
	lda zptmp_mismatches
	rts 

display_owned:
	jsr j_clearstatwindow
	jsr save_console_xy
	ldx #$1b
	ldy #$00
	sty zptmp_item_type
	sty zptmp_display_pos
	jsr j_primm_xy
	.byte $1f,"WEAPONS",$1d,$00
@next_row:
	lda zptmp_display_pos
	and #$08
	clc 
	adc #$18
	sta console_xpos
	lda zptmp_display_pos
	and #$07
	sta console_ypos
	inc console_ypos
	lda zptmp_item_type
	beq @nothing
	clc 
	adc #$20
	tay 
	lda stats,y
	beq @next_item
	pha 
	lda zptmp_item_type
	clc 
	adc #$c1
	jsr j_console_out
	pla 
	cmp #$10
	bcs @two_digit
	pha 
	lda #$ad
	jsr j_console_out
	pla 
	jsr j_printdigit
	jmp :+
@two_digit:
	jsr j_printbcd
:	lda #$ad
	jsr j_console_out
	lda zptmp_item_type
	clc 
	adc #$2d
	jsr print_string
	inc zptmp_display_pos
@next_item:
	inc zptmp_item_type
	lda zptmp_item_type
	cmp #$10
	bcc @next_row
	jsr restore_console_xy
	rts 

@nothing:
	jsr j_primm
	.byte "A-HANDS", 0
	inc zptmp_display_pos
	jmp @next_item

save_console_xy:
	lda console_xpos
	sta prev_console_x
	lda console_ypos
	sta prev_console_y
	rts 

restore_console_xy:
	lda prev_console_x
	sta console_xpos
	lda prev_console_y
	sta console_ypos
	rts 

prev_console_x:
	.byte 0
prev_console_y:
	.byte 0

; Garbage leftover in sector at end of file

;	lda bcdnum
;	jsr e1560
;	ora hexnum
;	sta bcdnum
;	ldx #$00
;	sed 
;	sec 
;b931f:
;	sbc #$01
;	bcc b9326
;	inx 
;	bne b931f
;b9326:
;	stx hexnum
;	cld 
;	rts 
;
;	jsr e0aad
;	beq b9338
;	sec 
;	sbc #$b0
;	cmp #$09
;	bcc b9338
;	lda #$00
;b9338:
;	sta currplayer
;	jsr e10dc
;	jsr e1041
;	lda currplayer
;	rts 
;
;	ldx #$28
;b9345:
;	dex 
;	bmi b934e
;	cmp f1351,x
;	bne b9345
;	rts 
;
;b934e:
;	lda #$ff
;	rts 
;
;	.byte $03,$04,$05,$06,$07,$09,$0a,$0b
;	.byte $0c,$10,$11,$12,$13,$14,$15,$16
;	.byte $17,$18,$19,$1a,$1b,$1c,$1d,$1e
;	.byte $3c,$3e,$3f,$43,$44,$46,$47,$49
;	.byte $4a,$4c,$4c,$4c,$8c,$8d,$8e,$8f
;	lda #$00
;	sta ptr1
;	tay 
;	ldx #$20
;	stx ptr1 + 1
;b9382:
;	sta (ptr1),y
;	iny 
;	bne b9382
;	inc ptr1 + 1
;	dex 
;	bne b9382
;	rts 
;
;	lda #<p2a00
;	sta ptr1
;	lda #>p2a00
;	sta ptr1 + 1
;	ldx #$01
;b9397:
;	lda #$00
;	ldy #$08
;b939b:
;	sta (ptr1),y
;	iny 
;	cpy #$b8
;	bne b939b
;	lda ptr1
;	clc 
;	adc #$40
;	sta ptr1
;	lda ptr1 + 1
;	adc #$01
;	sta ptr1 + 1
;	inx 
;	cpx #$17
;	bne b9397
;	rts 
;
;	lda #<p2a00
;	sta ptr1
;	lda #>p2a00
;	sta ptr1 + 1
;	ldx #$01
;b93bf:
;	ldy #$08
;b93c1:
;	lda (ptr1),y
;	eor #$ff
;	sta (ptr1),y
;	iny 
;	cpy #$b8
;	bne b93c1
;	lda ptr1
;	clc 
;	adc #$40
;	sta ptr1
;	lda ptr1 + 1
;	adc #$01
;	sta ptr1 + 1
;	inx 
;	cpx #$17
;	bne b93bf
;	rts 
;
;	sta zptmp1
;	lda #$00
;	cpx #$00
;	beq b93ed
;b93e7:
;	clc 
;	adc zptmp1
;	dex 
;	bne b93e7
;b93ed:
;	rts 
;
;	lda tile_ypos
;	jsr e1560
;	sta ptr2
;	lda tile_xpos
;	and #$0f
;	ora ptr2
;	sta ptr2
;	lda tile_ypos
;	and #$00
