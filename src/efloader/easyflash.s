	.include "easyflash.i"


	.export easyflash_prepare_write
	.export easyflash_setaddr
	.export easyflash_finish_write
	.export easyflash_write_data
	.export easyflash_write_byte
	.export easyflash_erase_sector

	.export easyflash_write_bank
	.export easyflash_write_addr
	.export easyflash_write_len


	.importzp aptr


	.segment "LOADER"

easyflash_write_bank:	.res 1
easyflash_write_addr:	.res 2
easyflash_write_len:	.res 2


easyflash_prepare_write	= swap_in_easyapi

easyflash_setaddr:
	lda easyflash_write_bank
	jsr EAPISetBank

	lda #EF_MODE_LO
	ldx easyflash_write_addr
	ldy easyflash_write_addr + 1
	jmp EAPISetPtr


easyflash_finish_write	= swap_out_easyapi


easyflash_write_data:
	ldy #0
	ldx easyflash_write_len + 1
	beq @lo
:	lda (aptr),y
	jsr easyflash_write_byte
	iny
	bne :-
	inc aptr + 1
	dex
	bne :-
@lo:
	lda easyflash_write_len
	beq @done
:	lda (aptr),y
	jsr easyflash_write_byte
	iny
	cpy easyflash_write_len
	bne :-
@done:
	rts


swap_out_easyapi:
	sei
	dec $01

	ldx #0
:	lda easyapi_backup,x
	sta easyapi,x
	lda easyapi_backup + $100,x
	sta easyapi + $100,x
	lda easyapi_backup + $200,x
	sta easyapi + $200,x
	inx
	bne :-	

	inc $01
	cli
	rts


swap_in_easyapi:
	sei
	dec $01

	ldx #0
:	lda easyapi,x
	sta easyapi_backup,x
	lda easyapi + $100,x
	sta easyapi_backup + $100,x
	lda easyapi + $200,x
	sta easyapi_backup + $200,x
	inx
	bne :-
	jmp copy_from_cart


	.segment "LOWLOADER"

copy_from_cart:
	lda #$37
	sta $01
	lda #0
	sta ef_bank
	lda #EF_16K
	sta ef_control

:	lda easyapi_source,x
	sta easyapi,x
	lda easyapi_source + $100,x
	sta easyapi + $100,x
	lda easyapi_source + $200,x
	sta easyapi + $200,x
	inx
	bne :-

	jsr EAPIInit
kill:
	lda #EF_KILL
	sta ef_control
	lda #$35
	sta $01
	cli
	rts


easyflash_write_byte:
	sei
	pha
	lda #$37
	sta $01
	pla
	jsr EAPIWriteFlashInc
	jmp kill


easyflash_erase_sector:
	sei
	ldx #$37
	stx $01
	jsr EAPIEraseSector
	jmp kill


	.segment "EASYAPI"

easyapi:

EAPIInit = * + 20


	.segment "EASYAPISOURCE"

easyapi_source:


	.segment "EASYAPIBACKUP"

easyapi_backup:
