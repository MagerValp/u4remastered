	.include "macro.i"

	
	.export init
	.export is_pal


	.import basicstub
	.import basiclen
	.import programstub
	
	.import fadebasic
	

	.code

init:
	; Restore basic startup for main program.
	ldx #<basiclen - 1
:	lda programstub,x
	sta basicstub,x
	dex
	bpl :-

	lda #$7f
	sta $dc0d
	bit $dc0d
	sta $dc00
	
	lda #$35
	sta $01

	ldx #0
	stx $d015
pal_ntsc:
	lda $d012
:	cmp $d012
	beq :-
	bmi pal_ntsc
	cmp #$37
	beq :+
	dex
:	stx is_pal


	lda #$fe
@sync:
	cmp $d012	; 4
	bne @sync	; 2
	
	ldy #9		; 2
:	dey		; 
	bne :-		; 9 * 5 - 1
	
	lda is_pal	; 4
	bne :+		; 2/3
:	bne :+		; 2/3
:
	lda #$fe	; 2
	cmp $d012	; 4
	bne @sync	; 3
	
	nop
	nop
	nop
	nop
	nop
	
	nop
	nop
	nop
	nop
	nop
	
	
	;ldy #0
	sty $dc05	; 4
	
	lda is_pal	; 4
	and #2		; 2
	clc		; 2
	adc #62		; 2
	sta $dc04	; 4
	
	lda #$11	; 2
	sta $dc0e	; 4
	
	.assert * = fadebasic, error, "fadebasic must be linked immediately after init"
	;jmp fadebasic


	.data

; $00	PAL
; $ff	NTSC
is_pal:		.res 1


;	.segment "FFF"
;
;	.res 1
