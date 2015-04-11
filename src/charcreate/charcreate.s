	.import drawcard_d800


  .macro slice_of_151 START, END
	.incbin "files/patched/151.prg", 2 + START - $6400, END - START
  .endmacro


	.segment "PART1"

	slice_of_151 $6400, $6723


	.segment "APPEAR"

temp_y		= $7b
ptr2		= $7c
ptr1		= $7e
sprindex	= ptr1

bmplineaddr_lo	= $e000
bmplineaddr_hi	= $e0c0

j_togglesnd	= $a109


play_moongate_sound:
	sta $d07a

	ldy	#$28				; 6723	(
	jsr	j_togglesnd			; 6725
@a:	ldx	temp_y				; 6728
@b:	dex					; 672A
	bne	@b				; 672B
	jsr	j_togglesnd			; 672D
	dey					; 6730
	bne	@a				; 6731

	sta $d07b
	rts

	.res 6

	.assert * = $6740, error, "moongate_appear must start at $6740"

moongate_appear:
	ldx #sprconf_size - 1
:	lda sprconf,x
	dex
	ldy sprconf,x
	sta $d000,y
	dex
	bpl :-
	stx $07f9
	dex
	stx $07f8

	ldx #$51
	stx sprindex
	
	lda #$45
	sta temp_y

@draw:
	jsr play_moongate_sound

	ldx sprindex
	cpx #$3f
	bne :+
	dex
:
	ldy #3
	lda #$55
:	sta $3f80,x
	dex
	bmi @done
	dey
	bne :-
	stx sprindex
	
	dec temp_y
	bne @draw
@done:
	rts

sprconf:
	.byte <$d000, 102
	.byte <$d002, 102
	.byte <$d001, 86 + 15
	.byte <$d003, 107 + 15
	.byte <$d010, 0
	.byte <$d017, 0
	.byte <$d01b, 0
	.byte <$d01d, 0
	.byte <$d01c, 0
	.byte <$d01b, 0	; 3
	.byte <$d015, 3
;	.byte <$d025, 1
;	.byte <$d026, 14
	.byte <$d027, 6
	.byte <$d028, 6
sprconf_size = * - sprconf


	.segment "PART2"

	slice_of_151 $6799, $6830


	.segment "DISAPPEAR"

rasterirq:
	pha					; 6830
	lda	#$01				; 6831	A
	and	$D019				; 6833
	beq	@notrasterirq			; 6836
	lda	irqline 			; 6838
	bne	@skipwait			; 683B
@waitline:
	lda	$D012				; 683D
	cmp	#$C3				; 6840	C
	bcc	@waitline			; 6842
@skipwait:
	lda	$D016				; 6844
	and	#$EF				; 6847	o
	ora	mcflag				; 6849
	sta	$D016				; 684C
	lda	irqline 			; 684F
	sta	$D012				; 6852
	lda	mcflag				; 6855
	eor	#$10				; 6858	P
	sta	mcflag				; 685A
	lda	irqline 			; 685D
	eor	#$B0				; 6860	0
	sta	irqline 			; 6862
	lda	#$01				; 6865	A
	;sta	$D019				; 6867
	jmp irq_continue
@notrasterirq:
	pla					; 686A
	jmp	(irqvector)			; 686B

mcflag:
	.byte	$C7				; 686E	G
irqline:
	.byte	$B8				; 686F	8

irqvector:
	.addr	$B7C7				; 6870


moongate_disappear:
	ldx #0
	stx sprindex
	
	lda #$2b
	sta temp_y

@clear:
	jsr play_moongate_sound

	ldx sprindex
	cpx #$3f
	bne :+
	inx
:
	ldy #3
	lda #0
:	sta $3f80,x
	inx
	dey
	bne :-
	stx sprindex
	
	inc temp_y
	lda temp_y
	cmp #$46
	bne @clear

	lda #0
	sta $d015

	rts


	.segment "PART3"

	slice_of_151 $68a6, $6b71


	.segment "CARDPATCH"

	jsr drawcard_d800


	.segment "PART4"

	slice_of_151 $6b74, $6bf2


	.segment "COPYPATCH"

	jsr imagefade
	nop


	.segment "PART5"

	slice_of_151 $6bf6, $96e6


	.segment "MOONGATEIRQ"

irq_counter:
	.res 1

irq_continue:
	inc irq_counter
	lda irq_counter
	lsr
	eor $d000
	and #1
	eor $d000
	sta $d000
	sta $d002
	
	lda #1
	sta $d019
	pla
	jmp (irqvector)


	.segment "IMAGEFADE"

imagefade:
	lda #0
	sta $42
	tay
	ldx #39
@clear:
	lda irq_counter
:	cmp irq_counter
	beq :-
	lda #0
  .repeat 18, I
	sta $0400 + I * 40,x
	sta $d800 + I * 40,x
  .endrepeat
  .repeat 18, I
	sta $0400 + I * 40,y
	sta $d800 + I * 40,y
  .endrepeat
	dex
	iny
	cpy #20
	beq @done
	jmp @clear
@done:
	rts
