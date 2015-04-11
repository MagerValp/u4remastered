	.include "macro.i"


	.export text_init
	.export text_update


	.import screen


	.zeropage

screenptr:	.res 2
colorptr:	.res 2
textptr:	.res 2

	.data

currline:	.byte 5
counter:	.byte $ff
currpage:	.byte 0
pagedelay	= 150
pagedelayctr:	.byte pagedelay
clearcounter:	.byte 35


	.code

text_init:
	ldx #0
@clear:
	;lda #$63
	lda #$20
	sta screen,x
	sta screen + $0100,x
	sta screen + $0200,x
	sta screen + $0300,x
	lda #0
	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne @clear
	
	ldx currpage
	lda pagestart,x
	sta currline
setpage:
	lda pagetab_lo,x
	sta textptr
	lda pagetab_hi,x
	sta textptr + 1
	rts


text_update:
	lda currline
	cmp #19
	beq @pagedone

	inc counter
	lda counter
	and #$1f

	beq @newline

	cmp #fade_len
	bcc @fade

	rts

@pagedone:
	lda pagedelayctr
	beq @clearpage
	dec pagedelayctr
	rts

@fade:
	tax
	lda fade_in,x
	ldy #39
:	sta (colorptr),y
	dey
	bpl :-
	rts


@newline:
	ldy currline
	lda screenaddr_lo,y
	sta screenptr
	sta colorptr
	lda screenaddr_hi,y
	sta screenptr + 1
	eor #>(screen ^ $d800)
	sta colorptr + 1

	ldy #39
:	lda (textptr),y
	sta (screenptr),y
	lda #0
	sta (colorptr),y
	dey
	bpl :-

	inc currline

	lda textptr
	clc
	adc #40
	sta textptr
	bcc :+
	inc textptr + 1
:
	rts

@clearpage:
	ldy clearcounter
	bne @clear
	jmp @nextpage

@clear:
	lda #13
  .repeat 14, I
	sta $d800 + (I + 5) * 40,y
  .endrepeat

	lda #14
  .repeat 14, I
	sta $d801 + (I + 5) * 40,y
  .endrepeat

	lda #11
  .repeat 14, I
	sta $d802 + (I + 5) * 40,y
  .endrepeat

	lda #6
  .repeat 14, I
	sta $d803 + (I + 5) * 40,y
  .endrepeat

	lda #$20
  .repeat 14, I
	sta screen + 4 + (I + 5) * 40,y
  .endrepeat

	dec clearcounter
	rts

@nextpage:
	lda #35
	sta clearcounter

	lda #pagedelay
	sta pagedelayctr

	ldx currpage
	inx
	cpx #num_pages
	bne :+
	ldx #0
:	stx currpage
	lda pagestart,x
	sta currline
	jmp setpage


	.data

pagetab_lo:
	.byte <page0
	.byte <page1
	.byte <page2
	.byte <page3
pagetab_hi:
	.byte >page0
	.byte >page1
	.byte >page2
	.byte >page3
num_pages = <(* - pagetab_hi)

pagestart:
	.byte 5
	.byte 7
	.byte 7
	.byte 9

page0:
	screencode "                                        "
	screencode "                                        "
	screencode "        Ultima IV Remastered v2.1       "
	screencode "                                        "
	screencode "      (C) 1985 Origin Systems, Inc.     "
	screencode "                                        "
	screencode "              Released by               "
	screencode "            GENESIS PROJECT             "
	screencode "               2015-04-09               "
	screencode "                                        "
	screencode "                                        "
	screencode "     Cracked and fixed by MagerValp     "
	screencode "       Graphics remade by Mermaid       "
	screencode "                                        "

page1:
	screencode "      Enjoy this remastered port of     "
	screencode "             Ultima IV with:            "
	screencode "                                        "
	screencode "      * Graphics update                 "
	screencode "      * Dialogue overhaul               "
	screencode "      * Game bugfixed and enhanced      "
	screencode "      * IFFL & EasyFlash versions       "
	screencode "      * Save game editor                "
	screencode "      * Comprehensive trainer           "
	screencode "                                        "
	screencode "                                        "
	screencode "                                        "

page2:
	screencode "        We send our love to:            "
	screencode "                                        "
	screencode "          Triad                         "
	screencode "           F4CG & Atlantis              "
	screencode "            Nostalgia                   "
	screencode "             Mayday!                    "
	screencode "              Alpha Flight              "
	screencode "               Hokuto Force             "
	screencode "                Excess                  "
	screencode "                                        "
	screencode "                                        "
	screencode "                                        "

page3:
	screencode "             Intro Credits:             "
	screencode "                                        "
	screencode "           Code by MagerValp            "
	screencode "            Music by Stinsen            "
	screencode "                                        "
	screencode "                                        "
	screencode "       Special thanks to Hedning &      "
	screencode "       C64PP for support.               "
	screencode "                                        "
	screencode "                                        "


fade_in:
	.byte 0, 9, 2, 8, 12, 10, 15, 7, 1
fade_len = <(* - fade_in)


screenaddr_lo:
  .repeat 25, I
	.byte <(screen + I * 40)
  .endrepeat

screenaddr_hi:
  .repeat 25, I
	.byte >(screen + I * 40)
  .endrepeat
