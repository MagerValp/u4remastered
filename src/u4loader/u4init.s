	.include "kernal.i"
	.include "macro.i"


	.import trainer

	.import loader_init

	.import sndvolume

	.import __TELEPORT2_LOAD__
	.import __TELEPORT2_RUN__
	.import __TELEPORT2_SIZE__
	.import __TRAINERBALLOON_LOAD__
	.import __TRAINERBALLOON_RUN__
	.import __TRAINERBALLOON_SIZE__
	.import __BALLOONDESCEND_LOAD__
	.import __BALLOONDESCEND_RUN__
	.import __BALLOONDESCEND_SIZE__
	.import __LOOTDROP_LOAD__
	.import __LOOTDROP_RUN__
	.import __LOOTDROP_SIZE__
	.import __DRAWVIEW_LOAD__
	.import __DRAWVIEW_RUN__
	.import __DRAWVIEW_SIZE__
	.import __GETTILEADDR_LOAD__
	.import __GETTILEADDR_RUN__
	.import __GETTILEADDR_SIZE__
	.import __ANIMATEFLAGS_LOAD__
	.import __ANIMATEFLAGS_RUN__
	.import __ANIMATEFLAGS_SIZE__
	.import __DRAWVIEWTITLE_LOAD__
	.import __DRAWVIEWTITLE_RUN__
	.import __DRAWVIEWTITLE_SIZE__
	.import __FILLRAND_LOAD__
	.import __FILLRAND_RUN__
	.import __FILLRAND_SIZE__
	.import __LOWLOADER_LOAD__
	.import __LOWLOADER_RUN__
	.import __LOWLOADER_SIZE__

	.import supercpu_idle
	.import supercpu_idle_combat
	.import supercpu_playsfx
	.import supercpu_draw_lb_logo
	.import supercpu_fade_in_monsters
	.import supercpu_animate_monster1
;	.import supercpu_delay_checkkey
	.import fixed_getkey


src		 = $7e
dest		 = $7c


	.code

init:
	lda #$36
	sta $01

	jsr relocate

	jsr trainer

; black border + background
	ldx #0
	stx $d020
	stx $d021

; copy original load screen into render buffer
	;ldx #0
:	lda $9600,x
	sta $0400,x
	lda $9700,x
	sta $0500,x
	lda $9800,x
	sta $0600,x
	lda $9900,x
	sta $0700,x
; wipe the trainer font (why bother?)
	lda #1
	sta $d800,x
	sta $d900,x
	sta $da00,x
	sta $db00,x
	inx
	bne :-

	jsr loader_init
	bcc :+

	lda #2
@loader_fail:
	eor #8
	sta $d020
	jmp @loader_fail

:
	jsr patchcode

	ldx #<(bankcodeend - bankcode - 1)	; copy d000 jump table
:	lda bankcode,x
	sta $d000,x
	dex
	bpl :-

	ldx #$c0
	txs
	ldx #$17
	lda #0
:	sta $d400,x
	dex
	bpl :-
	lda #15
	sta $d418
	sta sndvolume
	lda #14
	sta $0286

	jsr $a10f		; setirqv
	lda #1
	sta $50
	sta $5f
	lda #0
	sta $38

	jsr $607a		; clear d800

	ldx #0
:	lda $9200,x
	sta $0400,x
	lda $9300,x
	sta $0500,x
	lda $9400,x
	sta $0600,x
	lda $9500,x
	sta $0700,x
	inx
	bne :-

	jmp $6016		; set bitmap mode, clear screen, start


retcode	= $0334

bankcode:
	.org $d000
j_unpackconv:
	jsr bank
	jsr bank

bank:
	php
	pha
	lda $01
	pha
	sei
	lda #$34
	sta $01
	.reloc
bankcodeend:


patchcode:
	bit $d0bc
	bmi :+

	ldax #patch_supercpu
	jsr patch
:
	ldax #patch_scankey
	jsr patch

	rts


patch:
	stax src
patchnext:
	jsr getbyte
	bne :+
	rts
:
	sta patchlen

	jsr getbyte
	sta dest
	jsr getbyte
	sta dest + 1

	ldy #0
:	lda (src),y
	sta (dest),y
	iny
patchlen = * + 1
	cpy #$ff
	bne :-

	lda patchlen
	clc
	adc src
	sta src
	bcc :+
	inc src + 1
:	jmp patchnext


getbyte:
	ldy #0
	lda (src),y
	php
	inc src
	bne :+
	inc src + 1
:	plp
	rts


patch_supercpu:
	.byte 6
	.addr $0ad4
	.byte $4c
	.addr supercpu_idle
	.byte $ea, $ea, $ea

	.byte 2
	.addr $0858
	.addr supercpu_idle_combat

	.byte 2
	.addr $19e6
	.addr supercpu_playsfx

	.byte 3
	.addr $66bd
	.byte $20
	.addr supercpu_animate_monster1

;	.byte 3
;	.addr $6253
;	.byte $4c
;	.addr supercpu_delay_checkkey

	.byte 2
	.addr $6032
	.addr supercpu_draw_lb_logo

	.byte 2
	.addr $605c
	.addr supercpu_fade_in_monsters

	.byte 0


patch_scankey:
	.byte 7
	.addr $1580
	.byte $20
	.addr fixed_getkey
	.byte $09, $80
	.byte $c9, $80

	.byte 1
	.addr $159d
	.byte $2c

	.byte 0


relocate:
	ldy relocation_index

	lda relocation_tab,y
	sta src
	lda relocation_tab + 1,y
	sta src + 1
	
	lda relocation_tab + 2,y
	sta dest
	lda relocation_tab + 3,y
	sta dest + 1
	
	lda relocation_tab + 4,y
	ldx relocation_tab + 5,y
	jsr memcpy
	
	dec relocation_counter
	beq @done
	lda relocation_index
	clc
	adc #6
	sta relocation_index
	bne relocate
@done:
	rts

relocation_tab:
	.addr __TELEPORT2_LOAD__
	.addr __TELEPORT2_RUN__
	.addr __TELEPORT2_SIZE__

	.addr __TRAINERBALLOON_LOAD__
	.addr __TRAINERBALLOON_RUN__
	.addr __TRAINERBALLOON_SIZE__

	.addr __BALLOONDESCEND_LOAD__
	.addr __BALLOONDESCEND_RUN__
	.addr __BALLOONDESCEND_SIZE__

	.addr __LOOTDROP_LOAD__
	.addr __LOOTDROP_RUN__
	.addr __LOOTDROP_SIZE__

	.addr __DRAWVIEW_LOAD__
	.addr __DRAWVIEW_RUN__
	.addr __DRAWVIEW_SIZE__

	.addr __GETTILEADDR_LOAD__
	.addr __GETTILEADDR_RUN__
	.addr __GETTILEADDR_SIZE__

	.addr __ANIMATEFLAGS_LOAD__
	.addr __ANIMATEFLAGS_RUN__
	.addr __ANIMATEFLAGS_SIZE__

	.addr __DRAWVIEWTITLE_LOAD__
	.addr __DRAWVIEWTITLE_RUN__
	.addr __DRAWVIEWTITLE_SIZE__

	.addr __FILLRAND_LOAD__
	.addr __FILLRAND_RUN__
	.addr __FILLRAND_SIZE__

	.addr __LOWLOADER_LOAD__
	.addr __LOWLOADER_RUN__
	.addr __LOWLOADER_SIZE__
relocation_counter:
	.byte <((* - relocation_tab) / 6)
relocation_index:
	.byte 0

memcpy:
	stax len
	ldy #0
	cpx #0
	beq @donehi

:	lda (src),y
	sta (dest),y
	iny
	bne :-
	inc src+1
	inc dest+1
	dex
	bne :-
@donehi:

	ldx len
	beq @donelo

:	lda (src),y
	sta (dest),y
	iny
	dex
	bne :-
@donelo:
	rts

len:	.res 2
