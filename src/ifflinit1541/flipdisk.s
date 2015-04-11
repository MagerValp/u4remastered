	.include "macro.i"
	.include "drivetype.i"
	.include "uscii.i"


	.export flipdisk


	.import iffl_scan
	.import loader_drivetype

	.import game_startup_patch


primm_xy	= $081e


	.code

flipdisk:
	lda loader_drivetype
	cmp #drivetype_1541
	beq @scan
	cmp #drivetype_1570
	beq @scan

	jmp game_startup_patch

@scan:
	jsr @clear_bitmap
	
	;ldx #0
	lda #$10
:	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne :-

	ldx #$3f
	lda #$00
:	sta $3f00,x
	dex
	bpl :-


	ldx #4
	ldy #10
	jsr primm_xy
	.byte "Insert play disk and press space", 0

        ldx #4
        ldy #14
        jsr primm_xy
        .byte "Note to emulator users: The .d81", 0
        ldx #4
        ldy #15
        jsr primm_xy
        .byte "and .crt versions load faster.", 0

	lda #0	      	   		; wait for keypress
	sta $c6
:	cmp $c6
	beq :-
	sta $c6

	jsr @clear_bitmap

	ldx #60				; wait a few frames to avoid
@wait:					; IFFL scan hang
	lda $a2
:	cmp $a2
	beq :-
	dex
	bne @wait

	ldx #12
	ldy #12
	jsr primm_xy
	.byte " Scanning files ", 0

	ldx #0
	ldy #0
	jsr primm_xy
	.byte "$MTDG", 0
	ldx #5*8 - 1
:	lda $2000,x
	sta $3f18,x
	lda #0
	sta $2000,x
	dex
	bpl :-

	jsr iffl_scan			; scan play disk IFFL files

;	ldx #12
;	ldy #12
;	jsr primm_xy
;	.byte " Journey onward ", 0

	jmp game_startup_patch

@clear_bitmap:
	ldy #$20			; clear bitmap screen
	sty @clear + 1
	dey
	ldx #0
	txa
@clear = * + 1
:	sta $2000,x
	inx
	bne :-
	inc @clear + 1
	dey
	bne :-
	rts
