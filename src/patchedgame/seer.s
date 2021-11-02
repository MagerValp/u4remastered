	.include "uscii.i"

;
; **** ZP ABSOLUTE ADDRESSES **** 
;
last_meditated = $29
move_counter_2 = $2e
console_xpos = $4e
currplayer = $54
zptemp = $6a
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
j_primm = $0821
j_console_out = $0824
j_get_stats_ptr = $082d
j_printname = $0830
stats = $ab00
stat_spirit = $ab06
inbuf = $af00



	.segment "OVERLAY"

	lda #$01
	sta currplayer
	jsr j_get_stats_ptr
	ldy #$12
	lda (ptr1),y
	cmp #$c7     ;(g)ood
	beq welcome
	cmp #$d0     ;(p)oisoned
	beq welcome
	jsr j_primm
	.byte $8d
	.byte "The seer says:", $8d
	.byte "I will speak", $8d
	.byte "only with", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "Return when", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "is revived!", $8d
	.byte 0
	rts 

welcome:
	jsr j_primm
	.byte $8d
	.byte "Welcome,", $8d
	.byte 0
	jsr j_printname
	jsr j_primm
	.byte $8d
	.byte "I am Hawkwind,", $8d
	.byte "seer of souls.", $8d
	.byte "I see that which", $8d
	.byte "is within thee", $8d
	.byte "and drives thee", $8d
	.byte "to deeds of good", $8d
	.byte "or evil...", $8d
	.byte 0
	jsr j_waitkey
	jsr j_primm
	.byte $8d
	.byte "For what path", $8d
	.byte "dost thou seek", $8d
	.byte "enlightenment?", $8d
	.byte 0
	jmp input_word

ask_again:
	jsr j_primm
	.byte $8d
	.byte "Hawkwind asks:", $8d
	.byte "What other path", $8d
	.byte "seeks clarity?", $8d
	.byte 0
input_word:
	jsr get_input
	jsr check_inline_keyword
	.byte "    ", 0
	beq @bye
	jsr check_inline_keyword
	.byte "BYE", 0
	beq @bye
	jsr check_inline_keyword
	.byte "NONE", 0
	beq @bye
	jsr find_token
	bpl @found
	jsr j_primm
	.byte $8d
	.byte "He says:", $8d
	.byte "That is not a", $8d
	.byte "subject for", $8d
	.byte "enlightenment.", $8d
	.byte 0
	jmp ask_again

@found:
	jmp check_avatar

@bye:
	jsr j_primm
	.byte $8d
	.byte "Hawkwind says:", $8d
	.byte "Fare thee well", $8d
	.byte "and may thou", $8d
	.byte "complete the", $8d
	.byte "Quest of", $8d
	.byte "the Avatar!", $8d
	.byte 0
	lda move_counter_2
	cmp last_meditated
	beq @done
	sta last_meditated
	sed 
	clc 
	lda stat_spirit
	beq @skip
	adc #$03
	bcc @skip
	lda #$99
@skip:
	sta stat_spirit
	cld 
@done:
	rts 

check_avatar:
	jsr print_newline
	ldy zptemp
	lda stats,y
	bne lookup_advice
	jsr j_primm
	.byte "He says:", $8d
	.byte "Thou hast become", $8d
	.byte "a partial Avatar", $8d
	.byte "in that", $8d
	.byte "attribute. Thou", $8d
	.byte "need not my", $8d
	.byte "insights.", $8d
	.byte 0
	jmp ask_again

lookup_advice:
	ldy zptemp
	lda stats,y
	tax 
	lda #$01
	cpx #$20
	bcc print_advice
	lda #$09
	cpx #$40
	bcc print_advice
	lda #$11
	cpx #$60
	bcc print_advice
	lda #$19
	cpx #$99
	bcc print_advice
	lda #$21
print_advice:
	clc 
	adc zptemp
	jsr print_string
	ldy zptemp
	lda stats,y
	cmp #$99
	bne @done
	jsr j_primm
	.byte $8d
	.byte "Go to the shrine", $8d
	.byte "and meditate for", $8d
	.byte "three cycles!", $8d
	.byte 0
	jsr j_waitkey
@done:
	jmp ask_again

tokens:
	.byte "HONE"
	.byte "COMP"
	.byte "VALO"
	.byte "JUST"
	.byte "SACR"
	.byte "HONO"
	.byte "SPIR"
	.byte "HUMI"
	.byte 0,0,0,0

find_token:
	lda #$00
	sta zptemp
@compare_token:
	lda zptemp
	asl 
	asl 
	tay 
	ldx #$00
@next_char:
	lda tokens,y
	beq @not_found
	cmp inbuf,x
	bne @next_token
	iny 
	inx 
	cpx #$04
	bcc @next_char
	lda zptemp
	rts 

@next_token:
	inc zptemp
	jmp @compare_token

@not_found:
	lda #$ff
	sta zptemp
	rts 

get_input:
	lda #$bf
	jsr j_console_out
	lda #$00
	sta zptemp
@get_char:
	jsr j_waitkey
	cmp #$8d
	beq @got_input
	cmp #$94
	beq @backspace
	cmp #$a0
	bcc @get_char
	ldx zptemp
	sta inbuf,x
	jsr j_console_out
	inc zptemp
	lda zptemp
	cmp #$0f
	bcc @get_char
	bcs @got_input
@backspace:
	lda zptemp
	beq @get_char
	dec zptemp
	dec console_xpos
	lda #$a0
	jsr j_console_out
	dec console_xpos
	jmp @get_char

@got_input:
	ldx zptemp
	lda #$a0
@pad_spaces:
	sta inbuf,x
	inx 
	cpx #$06
	bcc @pad_spaces
	lda #$8d
	jsr j_console_out
	rts 

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
	.byte "Thou art a thief", $8d
	.byte "and a scoundrel.", $8d
	.byte "Thou may not", $8d
	.byte "ever become an", $8d
	.byte "Avatar!", $8d
	.byte 0
	.byte "Thou art a cold", $8d
	.byte "and cruel brute.", $8d
	.byte "Thou shouldst go", $8d
	.byte "to prison for", $8d
	.byte "thy crimes!", $8d
	.byte 0
	.byte "Thou art a", $8d
	.byte "coward, thou", $8d
	.byte "dost flee from", $8d
	.byte "the hint of", $8d
	.byte "danger!", $8d
	.byte 0
	.byte "Thou art an", $8d
	.byte "unjust wretch.", $8d
	.byte "thou art a", $8d
	.byte "fulsome meddler!", $8d
	.byte 0
	.byte "Thou art a", $8d
	.byte "self-serving", $8d
	.byte "tufthunter, thou", $8d
	.byte "deserveth not", $8d
	.byte "my help, yet I", $8d
	.byte "grant it!", $8d
	.byte 0
	.byte "Thou art a cad", $8d
	.byte "and a bounder.", $8d
	.byte "Thy presence is", $8d
	.byte "an affront, thou", $8d
	.byte "art low as a", $8d
	.byte "slug!", $8d
	.byte 0
	.byte "Thy spirit is", $8d
	.byte "weak and feeble.", $8d
	.byte "Thou dost not", $8d
	.byte "strive for", $8d
	.byte "perfection!", $8d
	.byte 0
	.byte "Thou art proud", $8d
	.byte "and vain,", $8d
	.byte "all other virtue", $8d
	.byte "in thee is", $8d
	.byte "a loss!", $8d
	.byte 0
	.byte "Thou art not", $8d
	.byte "an honest soul,", $8d
	.byte "thou must live", $8d
	.byte "a more honest", $8d
	.byte "life to be", $8d
	.byte "an Avatar!", $8d
	.byte 0
	.byte "Thou dost kill", $8d
	.byte "where there is", $8d
	.byte "no need and give", $8d
	.byte "too little unto", $8d
	.byte "others!", $8d
	.byte 0
	.byte "Thou dost not", $8d
	.byte "display a great", $8d
	.byte "deal of valor,", $8d
	.byte "thou dost flee", $8d
	.byte "before the need!", $8d
	.byte 0
	.byte "Thou art cruel", $8d
	.byte "and unjust, in", $8d
	.byte "time thou wilt", $8d
	.byte "suffer for thy", $8d
	.byte "crimes!", $8d
	.byte 0
	.byte "Thou dost need", $8d
	.byte "to think more", $8d
	.byte "of the life of", $8d
	.byte "others and less", $8d
	.byte "of thy own!", $8d
	.byte 0
	.byte "Thou dost not", $8d
	.byte "fight with honor", $8d
	.byte "but with malice", $8d
	.byte "and deceit!", $8d
	.byte 0
	.byte "Thou dost not", $8d
	.byte "take the time to", $8d
	.byte "care about thy", $8d
	.byte "inner being, a", $8d
	.byte "must to be an", $8d
	.byte "Avatar!", $8d
	.byte 0
	.byte "Thou art too", $8d
	.byte "proud of thy", $8d
	.byte "little deeds,", $8d
	.byte "humility is the", $8d
	.byte "root of all", $8d
	.byte "virtue!", $8d
	.byte 0
	.byte "Thou hast made", $8d
	.byte "little progress", $8d
	.byte "on the paths", $8d
	.byte "of honesty,", $8d
	.byte "strive to prove", $8d
	.byte "thy worth!", $8d
	.byte 0
	.byte "Thou hast not", $8d
	.byte "shown thy", $8d
	.byte "compassion well.", $8d
	.byte "Be more kind", $8d
	.byte "unto others!", $8d
	.byte 0
	.byte "Thou art not yet", $8d
	.byte "a valiant", $8d
	.byte "warrior, fight", $8d
	.byte "to defeate evil", $8d
	.byte "and prove", $8d
	.byte "thyself!", $8d
	.byte 0
	.byte "Thou hast not", $8d
	.byte "proven thyself", $8d
	.byte "to be just.", $8d
	.byte "Strive to do", $8d
	.byte "justice unto", $8d
	.byte "all things!", $8d
	.byte 0
	.byte "Thy sacrifice", $8d
	.byte "is small.", $8d
	.byte "Give of thy", $8d
	.byte "life's blood so", $8d
	.byte "that others may", $8d
	.byte "live.", $8d
	.byte 0
	.byte "Thou dost need", $8d
	.byte "to show thyself", $8d
	.byte "to be more", $8d
	.byte "honorable, the", $8d
	.byte "path lies before", $8d
	.byte "thee!", $8d
	.byte 0
	.byte "Strive to know", $8d
	.byte "and master more", $8d
	.byte "of thine inner", $8d
	.byte "being.", $8d
	.byte "Meditation", $8d
	.byte "lights the path!", $8d
	.byte 0
	.byte "Thy progress on", $8d
	.byte "this path is", $8d
	.byte "most uncertain.", $8d
	.byte "Without humility", $8d
	.byte "thou art", $8d
	.byte "empty!", $8d
	.byte 0
	.byte "Thou dost seem", $8d
	.byte "to be an honest", $8d
	.byte "soul, continued", $8d
	.byte "honesty will", $8d
	.byte "reward thee!", $8d
	.byte 0
	.byte "Thou dost show", $8d
	.byte "thy compassion", $8d
	.byte "well, continued", $8d
	.byte "goodwill should", $8d
	.byte "be thy guide!", $8d
	.byte 0
	.byte "Thou art showing", $8d
	.byte "valor in the", $8d
	.byte "face of danger.", $8d
	.byte "Strive to become", $8d
	.byte "yet more so!", $8d
	.byte 0
	.byte "Thou dost seem", $8d
	.byte "fair and just.", $8d
	.byte "Strive to uphold", $8d
	.byte "justice even", $8d
	.byte "more sternly!", $8d
	.byte 0
	.byte "Thou art giving", $8d
	.byte "of thyself in", $8d
	.byte "some ways, seek", $8d
	.byte "ye now to find", $8d
	.byte "yet more!", $8d
	.byte 0
	.byte "Thou dost seem", $8d
	.byte "to be honorable", $8d
	.byte "in nature, seek", $8d
	.byte "to bring honor", $8d
	.byte "upon others as", $8d
	.byte "well!", $8d
	.byte 0
	.byte "Thou art doing", $8d
	.byte "well on the path", $8d
	.byte "to inner sight.", $8d
	.byte "Continue to seek", $8d
	.byte "the inner light!", $8d
	.byte 0
	.byte "Thou dost seem", $8d
	.byte "a humble soul.", $8d
	.byte "Thou art setting", $8d
	.byte "strong stones to", $8d
	.byte "build virtues", $8d
	.byte "upon!", $8d
	.byte 0
	.byte "Thou art truly", $8d
	.byte "an honest soul.", $8d
	.byte "Seek ye now to", $8d
	.byte "reach elevation!", $8d
	.byte 0
	.byte "Compassion is", $8d
	.byte "a virtue that", $8d
	.byte "thou hast shown", $8d
	.byte "well. Seek ye", $8d
	.byte "now elevation!", $8d
	.byte 0
	.byte "Thou art a truly", $8d
	.byte "valiant warrior.", $8d
	.byte "Seek ye now", $8d
	.byte "elevation in the", $8d
	.byte "virtue of valor!", $8d
	.byte 0
	.byte "Thou art just", $8d
	.byte "and fair. Seek", $8d
	.byte "ye now the", $8d
	.byte "elevation!", $8d
	.byte 0
	.byte "Thou art giving", $8d
	.byte "and good. Thy", $8d
	.byte "self-sacrifice", $8d
	.byte "is great. Seek", $8d
	.byte "now elevation!", $8d
	.byte 0
	.byte "Thou hast proven", $8d
	.byte "thyself to be", $8d
	.byte "honorable, seek", $8d
	.byte "ye now for the", $8d
	.byte "elevation!", $8d
	.byte 0
	.byte "Spirituality", $8d
	.byte "is in thy", $8d
	.byte "nature. Seek ye", $8d
	.byte "now the", $8d
	.byte "elevation!", $8d
	.byte 0
	.byte "Thy humility", $8d
	.byte "shines bright", $8d
	.byte "upon thy being.", $8d
	.byte "Seek ye now for", $8d
	.byte "elevation!", $8d
	.byte 0

; Garbage leftover in sector at end of file

;	.byte $04,$05,$04,$05,$04,$05,$04,$05
;	.byte $04,$05,$04,$05,$04,$13,$ff,$20
;	.byte $e5,$16,$00,$01,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
;	.byte $0a,$0a,$14,$ff,$20,$ed,$16,$01
;	.byte $17,$03,$02,$03,$02,$03,$02,$03
;	.byte $02,$03,$02,$03,$02,$03,$02,$03
;	.byte $02,$03,$02,$03,$02,$03,$02,$ff
;	.byte $20,$e5,$16,$17,$01,$0d,$0d,$0d
;	.byte $0d,$0d,$0d,$0d,$0d,$09,$0d,$09
;	.byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
;	.byte $0d,$0d,$0d,$0b,$ff,$20,$e5,$16
;	.byte $27,$01,$09,$09,$09,$09,$09,$09
;	.byte $09,$09,$01,$09,$05,$ff,$20,$ed
;	.byte $16,$18,$09,$06,$07,$06,$07,$06
;	.byte $07,$06,$07,$06,$07,$06,$07,$06
;	.byte $07,$06,$ff,$20,$ed,$16,$18,$0b
;	.byte $06,$07,$06,$07,$06,$07,$06,$07
