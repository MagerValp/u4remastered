	.include "uscii.i"

;
; **** ZP ABSOLUTE ADDRESSES **** 
;
current_location = $1a
console_xpos = $4e
console_ypos = $4f
zptmp_item_type = $58
zptmp_display_pos = $59
zptmp_shop_num = $6a
zptmp_char_count = $6a
zptmp_inv_num = $70
zptmp_mismatches = $70
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
armour = $ab18
inbuf = $af00



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
	.byte "Want to buy", $8d
	.byte "or sell?", 0
	jsr input_char
	cmp #$c2
	beq @buy
	cmp #$d3
	bne @buy_or_sell
	jmp sell

@buy:
	jsr j_primm
	.byte $8d
	.byte "Well then,", $8d
	.byte 0
buy_menu:
	jsr j_primm
	.byte "we've got:", $8d
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
	beq @skip
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
	jsr print_newline
@skip:
	inc zptmp_inv_num
	lda zptmp_inv_num
	cmp #$04
	bcc @next_item

; prompt
	jsr j_primm
	.byte "What'll it be?", 0
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
	.byte "Do you want", $8d
	.byte "to buy it?", 0
:	jsr input_char
	beq :-
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
	.byte "Good bye.", $8d
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
	.byte "What you try'n", $8d
	.byte "to pull? You", $8d
	.byte "can't pay.", $8d
	.byte 0
	jmp bye

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
	lda armour,y
	adc #$01
	bcs :+
	sta armour,y
:	cld 
	jsr j_update_status
	clc 
	lda zptmp_shop_num
	adc #$07
	jsr print_string
	jsr j_primm
	.byte " says:", $8d
	.byte "Good choice!", $8d
	.byte "Anything else?", $8d
	.byte 0
	jmp buy_menu

sell:
	jsr j_primm
	.byte $8d
	.byte "What do you want", $8d
	.byte "to sell?", 0
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
	cmp #$08
	bcs @bye
	tay 
	lda armour,y
	bne @make_offer
	jsr j_primm
	.byte $8d
	.byte "Come on, you", $8d
	.byte "don't even own", $8d
	.byte "any! What else?", 0
	jmp sell_menu

@bye:
	jmp bye

@make_offer:
	lda zptmp_item_type
	asl 
	tay 
	lda price,y
	jsr decode_bcd_value
	lsr 
	jsr encode_bcd_value
	sta payment
	lda price + 1,y
	jsr decode_bcd_value
	lsr 
	jsr encode_bcd_value
	sta payment + 1
	jsr j_primm
	.byte $8d
	.byte "I'll give ya", $8d
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
	.byte "Harumph, what", $8d
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
	lda armour,y
	sbc #$01
	sta armour,y
	cld 
	jsr j_update_status
	jsr j_primm
	.byte "Good, what", $8d
	.byte "else?", 0
	jmp sell_menu

; map location to shop number
location_table:
	.byte $00,$00,$00,$00,$00,$01,$02,$00
	.byte $00,$03,$00,$00,$04,$05,$00,$00

inventory:
	.byte $01,$02,$03,$00
	.byte $03,$04,$05,$06
	.byte $01,$03,$05,$00
	.byte $01,$02,$00,$00
	.byte $01,$02,$03,$00

price:
	.byte $00,$00
	.byte $00,$50
	.byte $02,$00
	.byte $06,$00
	.byte $20,$00
	.byte $40,$00
	.byte $70,$00
	.byte $90,$00

print_newline:
	lda #$8d
	jsr j_console_out
	rts 

input_char:
	jsr j_waitkey
	beq input_char
	pha 
	jsr j_console_out
	jsr print_newline
	pla 
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
	.byte "Windsor Armour", 0
	.byte "Valiant's Armour", 0
	.byte "Duelling Armour", 0
	.byte "Light Armour", 0
	.byte "Basic Armour", 0
	.byte 0
	.byte "Jean", 0
	.byte "Valiant", 0
	.byte "Pierre", 0
	.byte "Limpy", 0
	.byte "Big John", 0
	.byte 0
	.byte "SKIN", 0
	.byte "CLOTH", 0
	.byte "LEATHER", 0
	.byte "CHAIN MAIL", 0
	.byte "PLATE MAIL", 0
	.byte "MAGIC CHAIN", 0
	.byte "MAGIC PLATE", 0
	.byte "MYSTIC ROBE", 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte "SKIN", $8d
	.byte 0
	.byte "Cloth armour is", $8d
	.byte "good for a tight", $8d
	.byte "budget, fairly", $8d
	.byte "priced at 50gp.", $8d
	.byte 0
	.byte "Leather armour", $8d
	.byte "is both supple", $8d
	.byte "and strong, and", $8d
	.byte "costs a mere", $8d
	.byte "200gp, a", $8d
	.byte "bargain!", $8d
	.byte 0
	.byte "Chain mail is", $8d
	.byte "the armour used", $8d
	.byte "by more warriors", $8d
	.byte "than all others.", $8d
	.byte "Ours costs 600gp", $8d
	.byte 0
	.byte "Full plate", $8d
	.byte "armour is the", $8d
	.byte "ultimate in non-", $8d
	.byte "magic armour,", $8d
	.byte "get yours", $8d
	.byte "for 2000gp.", $8d
	.byte 0
	.byte "Magic armour is", $8d
	.byte "rare and", $8d
	.byte "expensive. This", $8d
	.byte "chain sells for", $8d
	.byte "4000gp.", $8d
	.byte 0
	.byte "Magical plate", $8d
	.byte "armour is the", $8d
	.byte "best known", $8d
	.byte "protection, only", $8d
	.byte "we have it.", $8d
	.byte "Cost: 7000gp.", $8d
	.byte 0
	.byte "Mystic robes!", $8d
	.byte 0

;unused
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

encode_bcd_value:
	cmp #$00
	beq @done
	cmp #$63
	beq @max
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

display_owned:
	jsr j_clearstatwindow
	jsr save_console_xy
	ldx #$1b
	ldy #$00
	sty zptmp_item_type
	sty zptmp_display_pos
	jsr j_primm_xy
	.byte $1f,"ARMOUR",$1c,$00
@next_row:
	lda #$18
	sta console_xpos
	lda zptmp_display_pos
	sta console_ypos
	inc console_ypos
	lda zptmp_item_type
	beq @nothing
	clc 
	adc #$18
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
	adc #$0d
	jsr print_string
	inc zptmp_display_pos
@next_item:
	inc zptmp_item_type
	lda zptmp_item_type
	cmp #$08
	bcc @next_row
	jsr restore_console_xy
	rts 

@nothing:
	jsr j_primm
	.byte "A-NO ARMOUR", 0
	inc zptmp_display_pos
	jmp @next_item

;	.byte $ff,$fe,$ee,$f3,$ff,$ee,$6a,$ff
;	.byte $ff,$ee,$ee,$9d,$ff,$db,$4e,$ef
;	.byte $ff,$fe,$ee,$f2,$ff,$ee,$6e,$ff
;	.byte $ff,$ee,$fe,$9f,$ff,$da,$4e,$ef
;	.byte $ff,$fe,$ce,$f3,$ff,$ee,$68,$ff
;	.byte $ff,$ee,$ee,$9d,$ff,$db,$4e,$ef
;	.byte $ff,$fe,$ce,$f3,$ff,$ee,$6a,$ff
;	.byte $ff,$ee,$ee,$9d,$ff,$db,$4e,$ef
;	.byte $ff,$fe,$ce,$f3,$ff,$ee,$6a,$ff
;	.byte $ff,$ee,$ee,$9d,$ff
