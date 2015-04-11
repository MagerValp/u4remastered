	.include "uscii.i"


party_size		= $1f
player_has_spoken_to_lb	= $25
move_counter		= $2c
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
runes			= $ab0d
stones			= $ab0c
threepartkey		= $ab0f
virtues_and_stats	= $ab00
items			= $ab0e
inbuf			= $af00
music_ctl		= $af20



	.segment "OVERLAY"

lb_help:
	pla
	pla
	lda #$01
	jsr music_ctl
	lda move_counter
	ora move_counter+1
	bne check_companions
	lda move_counter+2
	and #$f0
	bne check_companions
	jmp help_early

check_companions:
	lda party_size
	cmp #$01
	bne check_runes
	jmp help_companions

check_runes:
	lda runes
	bne check_virtue
	jmp help_runes

check_virtue:
	ldx #$07
@next_virtue:
	lda virtues_and_stats,x
	beq check_stones
	dex
	bpl @next_virtue
	jmp help_virtues

check_stones:
	lda stones
	bne check_avatar
	jmp help_stones

check_avatar:
	ldx #$08
@next_virtue:
	dex
	bmi check_items
	lda virtues_and_stats,x
	beq @next_virtue
	jmp help_avatarhood

check_items:
	lda items
	and #$07
	cmp #$07
	beq check_threepartkey
	jmp help_items

check_threepartkey:
	lda threepartkey
	cmp #$07
	beq ready
	jmp help_threepartkey

ready:
	jmp help_ready

print_he_says:
	jsr j_primm
	.byte "He says:", $8d
	.byte 0

	rts

help_early:
	jsr print_he_says
	jsr j_primm
	.byte "To survive in", $8d
	.byte "this hostile", $8d
	.byte "land thou must", $8d
	.byte "first know", $8d
	.byte "thyself! Seek ye", $8d
	.byte "to master thy", $8d
	.byte "weapons and thy", $8d
	.byte "magical ability!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Take great care", $8d
	.byte "in these thy", $8d
	.byte "first travels", $8d
	.byte "in Britannia.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Until thou dost", $8d
	.byte "well know", $8d
	.byte "thyself travel", $8d
	.byte "not far from the", $8d
	.byte "safety of the", $8d
	.byte "townes!", $8d
	.byte 0

	jmp return_to_main_conversation

help_companions:
	jsr print_he_says
	jsr j_primm
	.byte "Travel not the", $8d
	.byte "open lands", $8d
	.byte "alone, there are", $8d
	.byte "many worthy", $8d
	.byte "people in the", $8d
	.byte "diverse townes", $8d
	.byte "whom it would be", $8d
	.byte "wise to ask to", $8d
	.byte "join thee!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Build thy party", $8d
	.byte "unto eight", $8d
	.byte "travellers, for", $8d
	.byte "only a true", $8d
	.byte "leader can win", $8d
	.byte "the quest!", $8d
	.byte 0

	jmp return_to_main_conversation

help_runes:
	jsr print_he_says
	jsr j_primm
	.byte "Learn ye the", $8d
	.byte "paths of virtue,", $8d
	.byte "seek to gain", $8d
	.byte "entry unto the", $8d
	.byte "eight shrines!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Find ye the", $8d
	.byte "runes, needed", $8d
	.byte "for entry into", $8d
	.byte "each shrine, and", $8d
	.byte "learn each chant", $8d
	.byte "or 'mantra' used", $8d
	.byte "to focus thy", $8d
	.byte "meditations.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Within the", $8d
	.byte "shrines thou", $8d
	.byte "shalt learn of", $8d
	.byte "the deeds which", $8d
	.byte "show thy inner", $8d
	.byte "virtue or vice!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Choose thy path", $8d
	.byte "wisely for all", $8d
	.byte "thy deeds of", $8d
	.byte "good or evil are", $8d
	.byte "remembered and", $8d
	.byte "can return to", $8d
	.byte "hinder thee!", $8d
	.byte 0

	jmp return_to_main_conversation

help_virtues:
	jsr print_he_says
	jsr j_primm
	.byte "Visit the seer", $8d
	.byte "Hawkwind often", $8d
	.byte "and use his", $8d
	.byte "wisdom to help", $8d
	.byte "thee prove thy", $8d
	.byte "virtue.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "When thou art", $8d
	.byte "ready, Hawkwind", $8d
	.byte "will advise", $8d
	.byte "thee to seek", $8d
	.byte "the elevation", $8d
	.byte "unto partial", $8d
	.byte "avatarhood in a", $8d
	.byte "virtue.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Seek ye to", $8d
	.byte "become a partial", $8d
	.byte "avatar in all", $8d
	.byte "eight virtues,", $8d
	.byte "for only then", $8d
	.byte "shalt thou be", $8d
	.byte "ready to seek", $8d
	.byte "the codex!", $8d
	.byte 0

	jmp return_to_main_conversation

help_stones:
	jsr print_he_says
	jsr j_primm
	.byte "Go ye now into", $8d
	.byte "the depths of", $8d
	.byte "the dungeons,", $8d
	.byte "therein recover", $8d
	.byte "the 8 coloured", $8d
	.byte "stones from the", $8d
	.byte "altar pedestals", $8d
	.byte "in the halls", $8d
	.byte "of the dungeons.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Find the uses of", $8d
	.byte "these stones for", $8d
	.byte "they can help", $8d
	.byte "thee in the", $8d
	.byte "abyss!", $8d
	.byte 0

	jmp return_to_main_conversation

help_avatarhood:
	jsr print_he_says
	jsr j_primm
	.byte "Thou art doing", $8d
	.byte "very well indeed", $8d
	.byte "on the path to", $8d
	.byte "avatarhood!", $8d
	.byte "Strive ye to", $8d
	.byte "achieve the", $8d
	.byte "elevation in all", $8d
	.byte "eight virtues!", $8d
	.byte 0

	jmp return_to_main_conversation

help_items:
	jsr print_he_says
	jsr j_primm
	.byte "Find ye the", $8d
	.byte "bell, book and", $8d
	.byte "candle! With", $8d
	.byte "these three", $8d
	.byte "things, one may", $8d
	.byte "enter The Great", $8d
	.byte "Stygian Abyss!", $8d
	.byte 0

	jmp return_to_main_conversation

help_threepartkey:
	jsr print_he_says
	jsr j_primm
	.byte "Before thou dost", $8d
	.byte "enter the abyss", $8d
	.byte "thou shalt need", $8d
	.byte "the key of three", $8d
	.byte "parts, and the", $8d
	.byte "word of passage.", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Then might thou", $8d
	.byte "enter the", $8d
	.byte "chamber of The", $8d
	.byte "Codex of", $8d
	.byte "Ultimate Wisdom!", $8d
	.byte 0

	jmp return_to_main_conversation

help_ready:
	jsr print_he_says
	jsr j_primm
	.byte "Thou dost now", $8d
	.byte "seem ready to", $8d
	.byte "make the final", $8d
	.byte "journey into the", $8d
	.byte "dark abyss!", $8d
	.byte "Go only with a", $8d
	.byte "party of eight!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "Good luck, and", $8d
	.byte "may the powers", $8d
	.byte "of good watch", $8d
	.byte "over thee on", $8d
	.byte "this thy most", $8d
	.byte "perilous", $8d
	.byte "endeavour!", $8d
	.byte 0

	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "The hearts and", $8d
	.byte "souls of all", $8d
	.byte "Britannia go", $8d
	.byte "with thee now.", $8d
	.byte "Take care,", $8d
	.byte "my friend.", $8d
	.byte 0

	jmp return_to_main_conversation

return_to_main_conversation:
	;lda #$00
	;jsr music_ctl
	lda #$d2
	ldx #$87
	jsr j_fileio
