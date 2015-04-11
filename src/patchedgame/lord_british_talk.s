	.include "uscii.i"


party_size		= $1f
player_has_spoken_to_lb	= $25
console_xpos		= $4e
currplayer		= $54
talk_zptmp		= $6a
ptr1			= $7e

j_waitkey		= $0800
j_primm_xy		= $081e
j_primm			= $0821
j_console_out		= $0824
j_get_stats_ptr		= $082d
j_printname		= $0830
j_update_status		= $0845
j_rand			= $084e
j_playsfx		= $0854
j_printdigit		= $0866
j_invertview		= $0878

j_fileio		= $a100
inbuf			= $af00
music_ctl		= $af20


	.segment "OVERLAY"

j_continue:
	jmp continue

talk_lord_british:
	pla
	sta $0c
	pla
	sta $0d
	lda player_has_spoken_to_lb
	bne @check_alive
	inc player_has_spoken_to_lb
	jmp lb_intro

@check_alive:
	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$45
	lda (ptr1),y
	cmp #$c4
	bne @alive
	lda #$c7
	sta (ptr1),y
	jsr j_printname
	jsr j_primm
	.byte "THOU SHALT", $8d
	.byte "LIVE AGAIN!", $8d
	.byte 0

	ldx #$14
	lda #$0a
	jsr j_playsfx
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr restore_party_hp
	jsr j_update_status
@alive:
	jsr j_primm
	.byte "Lord British", $8d
	.byte "says: Welcome", $8d
	.byte 0

	lda #$01
	sta currplayer
	jsr j_printname
	lda party_size
	cmp #$02
	bcc @alone
	beq @one_companion
	bcs @three_or_more
@alone:
	jsr j_primm
	.byte $8d
	.byte "my friend!", $8d
	.byte 0

	jmp check_xp

@one_companion:
	jsr j_primm
	.byte $8d
	.byte "and thee also", $8d
	.byte 0

	inc currplayer
	jsr j_printname
	jsr j_primm
	.byte "!", $8d
	.byte 0

	jmp check_xp

@three_or_more:
	jsr j_primm
	.byte $8d
	.byte "and thy worthy", $8d
	.byte "adventurers!", $8d
	.byte 0

check_xp:
	lda party_size
	sta currplayer
@next:
	jsr j_get_stats_ptr
	ldy #$1c
	lda (ptr1),y
	jsr decode_bcd_value
	ldx #$01
@sqrt:
	cmp #$00
	beq @check_level
	lsr a
	inx
	jmp @sqrt

@check_level:
	txa
	ldy #$1a
	cmp (ptr1),y
	beq @already_at_level
	sta (ptr1),y
	sta talk_zptmp
	ldy #$18
	sta (ptr1),y
	lda #$00
	iny
	sta (ptr1),y
	jsr j_get_stats_ptr
	ldy #$12
	lda #$c7
	sta (ptr1),y
	ldy #$15
@inc_stat:
	jsr j_rand
	and #$07
	sed
	sec
	adc (ptr1),y
	cld
	cmp #$51
	bcc @less_than_51
	lda #$50
@less_than_51:
	sta (ptr1),y
	dey
	cpy #$13
	bcs @inc_stat
	jsr print_newline
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "thou art now", $8d
	.byte "level ", 0

	lda talk_zptmp
	jsr j_printdigit
	jsr print_newline
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr j_update_status
@already_at_level:
	dec currplayer
	beq @what
	jmp @next

@what:
	jsr j_primm
	.byte $8d
	.byte "What would thou", $8d
	.byte "ask of me?", $8d
	.byte 0

	jmp main_prompt

continue:
	pla
	pla
next_question:
	lda #$01
	jsr music_ctl
	jsr j_primm
	.byte $8d
	.byte "What else?", $8d
	.byte 0

main_prompt:
	jsr get_input
	jsr check_keyword
	bpl jump_to_keyword
	jsr print_he_says
	jsr j_primm
	.byte "I cannot help", $8d
	.byte "thee with that.", $8d
	.byte 0

	jmp next_question

jump_to_keyword:
	asl a
	tay
	lda keyword_jumptable,y
	sta ptr1
	lda keyword_jumptable+1,y
	sta ptr1+1
	jmp (ptr1)

keyword_jumptable:
	.addr answer_bye
	.addr answer_bye
	.addr answer_name
	.addr answer_look
	.addr answer_job
	.addr answer_heal
	.addr answer_trut
	.addr answer_love
	.addr answer_cour
	.addr answer_hone
	.addr answer_comp
	.addr answer_valo
	.addr answer_just
	.addr answer_sacr
	.addr answer_hono
	.addr answer_spir
	.addr answer_humi
	.addr answer_prid
	.addr answer_avat
	.addr answer_ques
	.addr answer_brit
	.addr answer_ankh
	.addr answer_help
	.addr answer_abys
	.addr answer_mond
	.addr answer_mina
	.addr answer_exod
	.addr answer_virt

print_lb_says:
	jsr j_primm
	.byte $8d
	.byte "Lord British", $8d
	.byte "says: ", $8d
	.byte 0

	rts

print_he_says:
	jsr j_primm
	.byte $8d
	.byte "He says:", $8d
	.byte 0

	rts

print_he_asks:
	jsr j_primm
	.byte $8d
	.byte "He asks:", $8d
	.byte 0

print_newline:
	lda #$8d
	jsr j_console_out
	rts

ask_y_or_n:
	jsr get_input
	lda inbuf
	cmp #$d9
	beq @yes
	cmp #$ce
	beq @no
	jsr j_primm
	.byte $8d
	.byte "Yes or no:", $8d
	.byte 0

	rts

	jmp ask_y_or_n

@yes:
	lda #$00
	rts

@no:
	lda #$01
	rts

answer_bye:
	jsr print_lb_says
	jsr j_primm
	.byte "Fare thee", $8d
	.byte "well my friend", 0

	lda party_size
	cmp #$01
	bne @plural
	jsr j_primm
	.byte "!", $8d
	.byte 0

	jmp exit_conversation

@plural:
	jsr j_primm
	.byte "s!", $8d
	.byte 0

	jmp exit_conversation

answer_name:
	jsr print_he_says
	jsr j_primm
	.byte "My name is", $8d
	.byte "Lord British,", $8d
	.byte "sovereign of", $8d
	.byte "all Britannia!", $8d
	.byte 0

	jmp next_question

answer_look:
	jsr j_primm
	.byte "Thou seest the", $8d
	.byte "king with the", $8d
	.byte "royal sceptre.", $8d
	.byte 0

	jmp next_question

answer_job:
	jsr print_he_says
	jsr j_primm
	.byte "I rule all", $8d
	.byte "Britannia, and", $8d
	.byte "shall do my best", $8d
	.byte "to help thee!", $8d
	.byte 0

	jmp next_question

answer_heal:
	jsr print_he_says
	jsr j_primm
	.byte "I am well,", $8d
	.byte "thank ye.", $8d
	.byte 0

	jsr print_he_asks
	jsr j_primm
	.byte "Art thou well?", $8d
	.byte 0

	jsr ask_y_or_n
	bne @notwell
	jsr print_he_says
	jsr j_primm
	.byte "That is good.", $8d
	.byte 0

	jmp next_question

@notwell:
	jsr print_he_says
	jsr j_primm
	.byte "Let me heal", $8d
	.byte "thy wounds!", $8d
	.byte 0

	ldx #$14
	lda #$0a
	jsr j_playsfx
	jsr j_invertview
	lda #$09
	ldx #$c0
	jsr j_playsfx
	jsr j_invertview
	jsr restore_party_hp
	jsr j_update_status
	jmp next_question

answer_trut:
	jsr print_he_says
	jsr j_primm
	.byte "Many truths can", $8d
	.byte "be learned at", $8d
	.byte "The Lycaeum. It", $8d
	.byte "lies on the", $8d
	.byte "northwestern", $8d
	.byte "shore of Verity", $8d
	.byte "Isle!", $8d
	.byte 0

	jmp next_question

answer_love:
	jsr print_he_says
	jsr j_primm
	.byte "Look for the", $8d
	.byte "meaning of love", $8d
	.byte "at Empath Abbey.", $8d
	.byte "The abbey sits", $8d
	.byte "on the western", $8d
	.byte "edge of The Deep", $8d
	.byte "Forest!", $8d
	.byte 0

	jmp next_question

answer_cour:
	jsr print_he_says
	jsr j_primm
	.byte "Serpent Castle", $8d
	.byte "on The Isle of", $8d
	.byte "Deeds is where", $8d
	.byte "courage should", $8d
	.byte "be sought!", $8d
	.byte 0

	jmp next_question

answer_hone:
	jsr print_he_says
	jsr j_primm
	.byte "The fair towne", $8d
	.byte "of Moonglow on", $8d
	.byte "Verity Isle, is", $8d
	.byte "where the virtue", $8d
	.byte "of honesty", $8d
	.byte "thrives!", $8d
	.byte 0

	jmp next_question

answer_comp:
	jsr print_he_says
	jsr j_primm
	.byte "The bards in the", $8d
	.byte "towne of Britain", $8d
	.byte "are well versed", $8d
	.byte "in the virtue of", $8d
	.byte "compassion!", $8d
	.byte 0

	jmp next_question

answer_valo:
	jsr print_he_says
	jsr j_primm
	.byte "Many valiant", $8d
	.byte "fighters come", $8d
	.byte "from Jhelom,", $8d
	.byte "in The Valarian", $8d
	.byte "Isles!", $8d
	.byte 0

	jmp next_question

answer_just:
	jsr print_he_says
	jsr j_primm
	.byte "In the city of", $8d
	.byte "Yew, in The Deep", $8d
	.byte "Forest, justice", $8d
	.byte "is served!", $8d
	.byte 0

	jmp next_question

answer_sacr:
	jsr print_he_says
	jsr j_primm
	.byte "Minoc, towne of", $8d
	.byte "self-sacrifice,", $8d
	.byte "lies on the", $8d
	.byte "eastern shores", $8d
	.byte "of Lost Hope", $8d
	.byte "Bay!", $8d
	.byte 0

	jmp next_question

answer_hono:
	jsr print_he_says
	jsr j_primm
	.byte "The paladins who", $8d
	.byte "strive for honor", $8d
	.byte "are oft seen in", $8d
	.byte "Trinsic, north", $8d
	.byte "of The Cape of", $8d
	.byte "Heroes!", $8d
	.byte 0

	jmp next_question

answer_spir:
	jsr print_he_says
	jsr j_primm
	.byte "In Skara Brae", $8d
	.byte "the spiritual", $8d
	.byte "path is taught,", $8d
	.byte "find it on an", $8d
	.byte "isle near", $8d
	.byte "Spiritwood!", $8d
	.byte 0

	jmp next_question

answer_humi:
	jsr print_he_says
	jsr j_primm
	.byte "Humility is the", $8d
	.byte "foundation of", $8d
	.byte "virtue! The", $8d
	.byte "ruins of proud", $8d
	.byte "Magincia are a", $8d
	.byte "testimony unto", $8d
	.byte "the virtue of", $8d
	.byte "humility!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Find the ruins", $8d
	.byte "of Magincia far", $8d
	.byte "off the shores", $8d
	.byte "of Britannia,", $8d
	.byte "on a small isle", $8d
	.byte "in the vast", $8d
	.byte "ocean!", $8d
	.byte 0

	jmp next_question

answer_prid:
	jsr print_he_says
	jsr j_primm
	.byte "Of the eight", $8d
	.byte "combinations of", $8d
	.byte "truth, love and", $8d
	.byte "courage, that", $8d
	.byte "which contains", $8d
	.byte "neither truth,", $8d
	.byte "love nor courage", $8d
	.byte "is pride.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Pride being not", $8d
	.byte "a virtue must be", $8d
	.byte "shunned in favor", $8d
	.byte "of humility, the", $8d
	.byte "virtue which is", $8d
	.byte "the antithesis", $8d
	.byte "of pride!", $8d
	.byte 0

	jmp next_question

answer_avat:
	jsr print_lb_says
	jsr j_primm
	.byte "To be an avatar", $8d
	.byte "is to be the", $8d
	.byte "embodiment of", $8d
	.byte "the eight", $8d
	.byte "virtues.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "It is to live a", $8d
	.byte "life constantly", $8d
	.byte "and forever in", $8d
	.byte "the quest to", $8d
	.byte "better thyself", $8d
	.byte "and the world in", $8d
	.byte "which we live.", $8d
	.byte 0

	jmp next_question

answer_ques:
	jsr print_lb_says
	jsr j_primm
	.byte "The quest of", $8d
	.byte "the avatar is", $8d
	.byte "is to know and", $8d
	.byte "become the", $8d
	.byte "embodiment of", $8d
	.byte "the eight", $8d
	.byte "virtues of", $8d
	.byte "goodness!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "It is known that", $8d
	.byte "all who take on", $8d
	.byte "this quest must", $8d
	.byte "prove themselves", $8d
	.byte "by conquering", $8d
	.byte "the abyss and", $8d
	.byte "viewing The", $8d
	.byte "Codex of", $8d
	.byte "Ultimate Wisdom!", $8d
	.byte 0

	jmp next_question

answer_brit:
	jsr print_he_says
	jsr j_primm
	.byte "Even though the", $8d
	.byte "great evil lords", $8d
	.byte "have been routed", $8d
	.byte "evil yet remains", $8d
	.byte "in Britannia.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "If but one soul", $8d
	.byte "could complete", $8d
	.byte "the quest of the", $8d
	.byte "avatar, our", $8d
	.byte "people would", $8d
	.byte "have a new hope,", $8d
	.byte "a new goal for", $8d
	.byte "life.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "There would be a", $8d
	.byte "shining example", $8d
	.byte "that there is", $8d
	.byte "more to life", $8d
	.byte "than the endless", $8d
	.byte "struggle for", $8d
	.byte "possessions", $8d
	.byte "and gold!", $8d
	.byte 0

	jmp next_question

answer_ankh:
	jsr print_he_says
	jsr j_primm
	.byte "The ankh is the", $8d
	.byte "symbol of one", $8d
	.byte "who strives for", $8d
	.byte "virtue, keep it", $8d
	.byte "with thee at", $8d
	.byte "times for by", $8d
	.byte "this mark thou", $8d
	.byte "shalt be known!", $8d
	.byte 0

	jmp next_question

answer_help:
	;lda #$00
	;jsr music_ctl
	lda #$d2
	ldx #$88
	jsr j_fileio
answer_abys:
	jsr print_he_says
	jsr j_primm
	.byte "The Great", $8d
	.byte "Stygian Abyss", $8d
	.byte "is the darkest", $8d
	.byte "pocket of evil", $8d
	.byte "remaining in", $8d
	.byte "britannia!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "It is said that", $8d
	.byte "in the deepest", $8d
	.byte "recesses of the", $8d
	.byte "abyss is the", $8d
	.byte "chamber of the", $8d
	.byte "codex!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "It is also said", $8d
	.byte "that only one of", $8d
	.byte "highest virtue", $8d
	.byte "may enter this", $8d
	.byte "chamber, one", $8d
	.byte "such as an", $8d
	.byte "avatar!!!", $8d
	.byte 0

	jmp next_question

answer_mond:
	jsr print_he_says
	jsr j_primm
	.byte "Mondain is dead!", $8d
	.byte 0

	jmp next_question

answer_mina:
	jsr print_he_says
	jsr j_primm
	.byte "Minax is dead!", $8d
	.byte 0

	jmp next_question

answer_exod:
	jsr print_he_says
	jsr j_primm
	.byte "Exodus is dead!", $8d
	.byte 0

	jmp next_question

answer_virt:
	jsr print_he_says
	jsr j_primm
	.byte "The eight", $8d
	.byte "virtues of the", $8d
	.byte "avatar are:", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte "Honesty,", $8d
	.byte "compassion,", $8d
	.byte "valor,", $8d
	.byte "justice,", $8d
	.byte "sacrifice,", $8d
	.byte "honor,", $8d
	.byte "spirituality,", $8d
	.byte "and humility!", $8d
	.byte 0

	jmp next_question

lb_intro:
	jsr j_primm
	.byte "Lord British", $8d
	.byte "rises and says", $8d
	.byte "at long last!", $8d
	.byte 0

	lda #$01
	sta currplayer
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "thou hast come!", $8d
	.byte "We have waited", $8d
	.byte "such a long,", $8d
	.byte "long time...", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Lord British", $8d
	.byte "sits and says:", $8d
	.byte "A new age is", $8d
	.byte "upon Britannia.", $8d
	.byte "The great evil", $8d
	.byte "lords are gone", $8d
	.byte "but our people", $8d
	.byte "lack direction", $8d
	.byte "and purpose in", $8d
	.byte "their lives...", 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte $8d
	.byte "A champion of", $8d
	.byte "virtue is called", $8d
	.byte "for. Thou may be", $8d
	.byte "this champion,", $8d
	.byte "but only time", $8d
	.byte "shall tell. I", $8d
	.byte "will aid thee", $8d
	.byte "any way that I", $8d
	.byte "can!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "How may I", $8d
	.byte "help thee?", $8d
	.byte 0

	jmp main_prompt

keywords:
	.byte "    "
	.byte "BYE "
	.byte "NAME"
	.byte "LOOK"
	.byte "JOB "
	.byte "HEAL"
	.byte "TRUT"
	.byte "LOVE"
	.byte "COUR"
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte "PRID"
	.byte "AVAT"
	.byte "QUES"
	.byte "BRIT"
	.byte "ANKH"
	.byte "HELP"
	.byte "ABYS"
	.byte "MOND"
	.byte "MINA"
	.byte "EXOD"
	.byte "VIRT"
	.byte 0, 0, 0, 0

check_keyword:
	lda #$00
	sta talk_zptmp
@check:
	lda talk_zptmp
	asl a
	asl a
	tay
	ldx #$00
@compare:
	lda keywords,y
	beq @nomatch
	cmp inbuf,x
	bne @next
	iny
	inx
	cpx #$04
	bcc @compare
	lda talk_zptmp
	rts

@next:
	inc talk_zptmp
	jmp @check

@nomatch:
	lda #$ff
	rts

get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta talk_zptmp
@getkey:
	jsr j_waitkey
	cmp #$8d
	beq @enter
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @getkey
	ldx talk_zptmp
	sta inbuf,x
	jsr j_console_out
	inc talk_zptmp
	lda talk_zptmp
	cmp #$0f
	bcc @getkey
	bcs @enter
@backspace:
	lda talk_zptmp
	beq @getkey
	dec talk_zptmp
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @getkey

@enter:
	ldx talk_zptmp
	lda #$a0
@padspace:
	sta inbuf,x
	inx
	cpx #$06
	bcc @padspace
	lda #$8d
	jsr j_console_out
	rts

restore_party_hp:
	lda party_size
	sta currplayer
@next:
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c4
	beq @dead
	lda #$c7
	sta (ptr1),y
	ldy #$1a
	lda (ptr1),y
	ldy #$18
	sta (ptr1),y
	ldy #$1b
	lda (ptr1),y
	ldy #$19
	sta (ptr1),y
@dead:
	dec currplayer
	bne @next
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

exit_conversation:
	lda $0d
	pha
	lda $0c
	pha
	rts
