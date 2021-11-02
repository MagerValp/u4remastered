	.include "uscii.i"


current_location	= $1a
party_size		= $1f
last_humility_check	= $27
move_counter		= $2c
console_xpos		= $4e
currplayer		= $54
bcdnum			= $57
towne_virtue		= $55
zptmp1			= $5a
lt_x			= $61
monster_type		= $66
ptr2			= $7c
ptr1			= $7e


j_waitkey		= $0800
j_primm 		= $0821
j_console_out		= $0824
j_get_stats_ptr 	= $082d
j_update_status 	= $0845
j_update_view		= $084b
j_rand			= $084e
j_getnumber		= $085a
j_clearstatwindow	= $0869

party_stats		= $aa00

game_stats		= $ab00
gold			= $ab13

map_status		= $ac00
object_tile		= $ac60

inbuffer		= $af00


	.segment "DIALOG"

dialog_strings:			.res $f5
dialog_keyword_1:		.res 4
dialog_keyword_2:		.res 4
dialog_question_trigger:	.res 1
dialog_humility:		.res 1
dialog_turns_away_prob:		.res 1


	.segment "TALK"

talk:
	ldx	#$03
@copy_keywords:
	lda	dialog_keyword_1,x
	ora	#$80
	sta	keyword_1,x
	lda	dialog_keyword_2,x
	ora	#$80
	sta	keyword_2,x
	dex
	bpl	@copy_keywords
	ldx	$6A
	lda	object_tile,x
	sta	monster_type
	jsr	j_primm
	.byte $8d
	.byte "You meet", $8d
	.byte 0

	lda	#$03
	jsr	print_string
	lda	#$8D
	jsr	j_console_out
	jsr	j_rand
	cmp	dialog_turns_away_prob
	bcc	maybe_fight
	jsr	j_rand
	bmi	talk_prompt
	lda	#$8D
	jsr	j_console_out
print_name:
	jsr	pronoun_says
	jsr	j_primm
	.byte " I am", $8d
	.byte 0

	lda	#$01
	jsr	print_string
	lda #$ae
	jsr j_console_out
	lda	#$8D
	jsr	j_console_out
	jmp	talk_prompt

maybe_fight:
	sta	$58
	lda	dialog_turns_away_prob
	sec
	sbc	$58
	cmp	#$40
	bcs	@fight
	jmp	pronoun_turns_away

@fight:
	jmp	start_combat

; dead code, unused in original game
;	jsr	pronoun_says_newline
;	jsr	j_primm
;	.byte "Go away!", $8d
;	.byte 0

talk_prompt:
	jsr	j_primm
	.byte $8d
	.byte "Your interest:", $8d
	.byte 0

	jsr	get_input
	lda	#$8D
	jsr	j_console_out
	jsr	j_rand
	cmp	dialog_turns_away_prob
	bcs	@check_input
	sta	$58
	sec
	lda	dialog_turns_away_prob
	sbc	$58
	cmp	#$80
	bcs	@fight
	jmp	pronoun_turns_away

@fight:
	jmp	start_combat

@check_input:
	jsr	compare_keywords
	bpl	@found_keyword
	jsr	pronoun_says
	jsr	j_primm
	.byte " That,", $8d
	.byte "I cannot help", $8d
	.byte "thee with.", $8d
	.byte 0

	jmp	check_question_trigger

@found_keyword:
	cmp	#$00
	beq	@bye
	cmp	#$09
	bne	@name
@bye:
	jsr	pronoun_says
	jsr	j_primm
	.byte " Bye.", $8d
	.byte 0

	jmp	talk_done

@name:
	cmp	#$01
	bne	@look
	jmp	print_name

@look:
	cmp	#$02
	bne	@join
	jsr	j_primm
	.byte "You see a", $8d
	.byte 0

	lda	#$03
	jmp	print_response_newline

@join:
	cmp	#$07
	bne	@give
	jmp	check_join

@give:
	cmp	#$08
	bne	@keyword
	jmp	check_give

@keyword:
	jsr	pronoun_says_newline
	lda	$6A
	clc
	adc	#$01
print_response_newline:
	jsr	print_string
	lda	#$8D
	jsr	j_console_out
	jmp	check_question_trigger

check_question_trigger:
	lda	$6A
	cmp	dialog_question_trigger
	beq	ask_question
	jmp	talk_prompt

ask_question:
	jsr	j_waitkey
	lda	#$8D
	jsr	j_console_out
	lda	#$02
	jsr	print_string
	jsr	j_primm
	.byte " asks:", $8d
	.byte 0

	lda	#$08
	jsr	print_string
@get_response:
	jsr	j_primm
	.byte $8d
	.byte $8d
	.byte "You respond:", $8d
	.byte 0

	jsr	get_input
	lda	#$8D
	jsr	j_console_out
	lda	inbuffer
	cmp	#$CE
	beq	@no
	cmp	#$D9
	bne	@yes_or_no
	jsr	subtract_humility
	jsr	pronoun_says_newline
	lda	#$09
	sta	$6A
	jmp	print_response_newline

@no:
	jsr	add_humility
	jsr	pronoun_says_newline
	lda	#$0A
	sta	$6A
	jmp	print_response_newline

@yes_or_no:
	jsr	pronoun_says_newline
	jsr	j_primm
	.byte "Yes, or no:", 0

	jmp	@get_response

pronoun_turns_away:
	lda	#$02
	jsr	print_string
	jsr	j_primm
	.byte " turns away!", $8d
	.byte $8d
	.byte 0

	jmp	talk_done

start_combat:
	lda	#$02
	jsr	print_string
	jsr	j_primm
	.byte " says:", $8d
	.byte "En garde! Fool!", $8d
	.byte 0

	ldx	$6A
	lda	#$FF
	sta	$ACC0,x
	jmp	talk_done

pronoun_says:
	lda	#$02
	jsr	print_string
	jsr	j_primm
	.byte " says:", 0

	rts

pronoun_says_newline:
	jsr	pronoun_says
	lda	#$8D
	jsr	j_console_out
	rts

get_input:
	lda	#$BF				; ?
	jsr	j_console_out
	lda	#$00
	sta	input_ctr
@get_char:
	jsr	j_waitkey
	cmp	#$8D
	beq	@got_input
	cmp	#$94
	beq	@backspace
	cmp	#$A0
	bcc	@get_char
	ldx	input_ctr
	sta	inbuffer,x
	jsr	j_console_out
	inc	input_ctr
	lda	input_ctr
	cmp	#$0F
	bcc	@get_char
	bcs	@got_input
@backspace:
	lda	input_ctr
	beq	@get_char
	dec	input_ctr
	dec	console_xpos
	lda	#$A0
	jsr	j_console_out
	dec	console_xpos
	jmp	@get_char

@got_input:
	ldx	input_ctr
	lda	#$A0
@pad_spaces:
	sta	inbuffer,x
	inx
	cpx	#$06
	bcc	@pad_spaces
	lda	#$8D
	jsr	j_console_out
	rts

input_ctr:
	.byte 0

compare_keywords:
	lda	#$09
	sta	$6A
@next:
	lda	$6A
	asl	a
	asl	a
	tay
	ldx	#$00
@compare:
	lda	keywords,y
	cmp	inbuffer,x
	bne	@nomatch
	iny
	inx
	cpx	#$04
	bcc	@compare
	lda	$6A
	rts

@nomatch:
	dec	$6A
	bpl	@next
	lda	$6A
	rts

keywords:
	.byte "BYE "
@name:
	.byte "NAME"
@look:
	.byte "LOOK"
@job:
	.byte "JOB "
@heal:
	.byte "HEAL"
keyword_1:
	.byte "    "
keyword_2:
	.byte "    "
@join:
	.byte "JOIN"
@give:
	.byte "GIVE"

	.byte "    "

print_string:
	tax
	lda #<dialog_strings
	sta ptr1
	lda #>dialog_strings
	sta ptr1 + 1
@next:
	dex
	beq @print
	ldy #0
@check:
	lda (ptr1),y
	bpl @eos
	iny
	bne @check
@eos:
	tya
	sec
	adc ptr1
	sta ptr1
	bne @next
@print:
	ldy #0
	lda (ptr1),y
	bpl @last
	jsr j_console_out
	inc ptr1
	bne @print
@last:
	ora #$80
	jmp j_console_out


check_join:
	lda	lt_x
	bne	@cant_join
	lda	current_location
	sec
	sbc	#$05
	cmp	#$08
	bcs	@cant_join
	sta	towne_virtue
	lda	#$01
	sta	currplayer
	jsr	j_get_stats_ptr
	ldy	#$11
	lda	(ptr1),y
	cmp	towne_virtue
	beq	@cant_join
	ldx	towne_virtue
	lda	game_stats,x
	beq	@part_avatar
	cmp	#$40
	bcc	@decline
@part_avatar:
	lda	party_size
	cmp	party_stats + 26
	bcs	@not_enough_xp
	jmp	accept_join

@cant_join:
	jsr	pronoun_says_newline
	jsr	j_primm
	.byte "I cannot", $8d
	.byte "join thee.", $8d
	.byte 0

	jmp	talk_prompt

@decline:
	stx	$58
@print_decline:
	jsr	pronoun_says_newline
	jsr	j_primm
	.byte "Thou art not", $8d
	.byte 0

	jsr	decline_reason
	jsr	j_primm
	.byte $8d
	.byte "enough for me", $8d
	.byte "to join thee.", $8d
	.byte 0

	jmp	talk_prompt

@not_enough_xp:
	lda	#$08
	sta	$58
	jmp	@print_decline

accept_join:
	jsr	pronoun_says_newline
	jsr	j_primm
	.byte "I am honored", $8d
	.byte "to join thee!", $8d
	.byte 0

	ldx	#$1F
	lda	#$00
	sta	object_tile,x
	sta	map_status,x
	sta	$ACC0,x
	sta	$ACE0,x
	jsr	j_update_view
	lda	#$08
	sta	currplayer
@next:
	jsr	j_get_stats_ptr
	ldy	#$11
	lda	(ptr1),y
	cmp	towne_virtue
	beq	@found_slot
	dec	currplayer
	bpl	@next
	jmp	@done

@found_slot:
	jsr	j_get_stats_ptr
	lda	ptr1
	sta	ptr2
	lda	ptr1 + 1
	sta	ptr2 + 1
	inc	party_size
	lda	party_size
	sta	currplayer
	jsr	j_get_stats_ptr
	ldy	#$1F
@move:
	lda	(ptr1),y
	pha
	lda	(ptr2),y
	sta	(ptr1),y
	pla
	sta	(ptr2),y
	dey
	bpl	@move
	jsr	j_clearstatwindow
	jsr	j_update_status
@done:
	jmp	talk_done

check_give:
	lda	monster_type
	cmp	#$58
	beq	@how_much
	jsr	pronoun_says
	jsr	j_primm
	.byte " I do", $8d
	.byte "not need thy", $8d
	.byte "gold, keep it!", $8d
	.byte 0

	jmp	check_question_trigger

@how_much:
	jsr	j_primm
	.byte "How much-", 0

	jsr	j_getnumber
	lda	#$8D
	jsr	j_console_out
	lda	bcdnum
	bne	@give_amount
	jmp	check_question_trigger

@give_amount:
	jsr	subtract_gold
	bpl	@has_gold
	jsr	j_primm
	.byte $8d
	.byte "Thou hast not", $8d
	.byte "that much gold!", $8d
	.byte 0

	jmp	check_question_trigger

@has_gold:
	jsr	give_gold_add_virtue
	lda	#$8D
	jsr	j_console_out
	jsr	pronoun_says
	jsr	j_primm
	.byte " Oh,", $8d
	.byte "thank thee!", $8d
	.byte "I shall never", $8d
	.byte "forget thy", $8d
	.byte "kindness!", $8d
	.byte 0

	jmp	check_question_trigger

give_gold_add_virtue:
	lda	gold + 1
	ora	gold
	bne	@has_gold_left
	lda	#$03
	ldy	#$04  ; cycle 1 at shrine of SACRIFICE recommends this action. Original code awarded HONOR (#$05).
	jsr	add_virtue
@has_gold_left:
	lda	move_counter + 3
	and	#$F0
	cmp	last_humility_check
	beq	@too_soon
	sta	last_humility_check
	lda	#$02
	ldy	#$01
	jsr	add_virtue
@too_soon:
	rts

decline_reason:
	ldx	$58
	bne	@compassionate
	jsr	j_primm
	.byte "honest", 0

	rts

@compassionate:
	dex
	bne	@valiant
	jsr	j_primm
	.byte "compassionate", 0

	rts

@valiant:
	dex
	bne	@just
	jsr	j_primm
	.byte "valiant", 0

	rts

@just:
	dex
	bne	@sacrificial
	jsr	j_primm
	.byte "just", 0

	rts

@sacrificial:
	dex
	bne	@honorable
	jsr	j_primm
	.byte "sacrificial", 0

	rts

@honorable:
	dex
	bne	@spiritual
	jsr	j_primm
	.byte "honorable", 0

	rts

@spiritual:
	dex
	bne	@humble
	jsr	j_primm
	.byte "spiritual", 0

	rts

@humble:
	dex
	bne	@experienced
	jsr	j_primm
	.byte "humble", 0

	rts  ; BUG FIX, this was missing in original code

@experienced:
	jsr	j_primm
	.byte "experienced", 0

	rts

subtract_humility:
	lda	dialog_humility
	cmp	#$01
	bne	@not_humility
	lda	#$05
	ldy	#$07
	jsr	subtract_virtue
	lda	move_counter + 3
	and	#$F0
	sta	last_humility_check
@not_humility:
	rts

add_humility:
	lda	dialog_humility
	cmp	#$01
	bne	@not_humility
	lda	move_counter + 3
	and	#$F0
	cmp	last_humility_check
	beq	@not_humility
	sta	last_humility_check
	lda	#$0A
	ldy	#$07
	jsr	add_virtue
@not_humility:
	rts

subtract_gold:
	sed
	sec
	lda	gold + 1
	sbc	bcdnum
	sta	gold + 1
	lda	gold
	sbc	#$00
	bcc	@underflow
	sta	gold
	cld
	jsr	j_update_status
	lda	#$00
	rts

@underflow:
	clc
	lda	gold + 1
	adc	bcdnum
	sta	gold + 1
	cld
	lda	#$FF
	rts

add_virtue:
	sta	$59
	sed
	clc
	lda	game_stats,y
	beq	@overflow
	adc	$59
	bcc	@overflow
	lda	#$99
@overflow:
	sta	game_stats,y
	cld
	rts

subtract_virtue:
	sta	zptmp1
	sty	$59
	lda	game_stats,y
	beq	@lost_an_eigth
@set_virtue:
	sed
	sec
	sbc	zptmp1
	bcs	@underflow
	bne	@underflow
	lda	#$01
@underflow:
	sta	game_stats,y
	cld
	rts

@lost_an_eigth:
	jsr	j_primm
	.byte $8d
	.byte "Thou hast lost", $8d
	.byte "an eighth!", $8d
	.byte 0

	ldy	$59
	lda	#$99
	jmp	@set_virtue

talk_done:
	rts
