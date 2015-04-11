	.include "macro.i"
	.include "easyflash.i"


	.import cartridge_start

	.import __BOOTSTRAP_LOAD__
	.import __BOOTSTRAP_RUN__
	.import __BOOTSTRAP_SIZE__


	.segment "ULTIMAXVEC"

vec_nmi:	.addr ux_rti
vec_res:	.addr ux_res
vec_irq:
ux_rti:
	rti
	rti


	.segment "ULTIMAX"

ux_res:
	sei
	ldx #$ff
	txs
	cld

	lda #8
	sta $d016

@wait:
	sta $0100,x
	inx
	bne @wait

	ldx #<__BOOTSTRAP_SIZE__ - 1
@copy:
	lda __BOOTSTRAP_LOAD__,x
	sta __BOOTSTRAP_RUN__,x
	dex
	bpl @copy

	jmp bootstrap


	.segment "BOOTSTRAP"

bootstrap:
        lda #EF_16K | EF_LED
        sta ef_control

	;ldx #$ff
	stx $dc02
	inx
	stx $dc03

	lda #$7f
	sta $dc00
	lda $dc01

	stx $dc02
	stx $dc00

	and #$e0		; Check Stop/Q/C=.
	cmp #$e0
	beq @start

	lda #EF_KILL
	sta ef_control
	jmp (vec_res)

@start:
	jmp cartridge_start
