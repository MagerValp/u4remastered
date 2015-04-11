	.include "macro.i"
	.include "easyflash.i"

	.include "files/easyflash/efs.i"


	.export u4loader_run
	.export u4loader_load
	.export u4loader_save
	.export u4loader_readblock

	.export loader_init

	.export get_crunched_byte


	.importzp aptr
	.importzp currdisk

	.import u4loader_fileaddr
	.import u4loader_blocknum
	.import u4loader_filenum
	.import u4loader_iodone

	.import filemap_lo
	.import filemap_hi

	.import lzmv_unpack

	.import efs_bank

	.import efs_file_bank
	.import efs_offset_lo
	.import efs_offset_hi
	.import efs_length_lo
	.import efs_length_hi

	.import efsbank_start
	.import efsbank_end

	.import easyflash_prepare_write
	.import easyflash_setaddr
	.import easyflash_finish_write
	.import easyflash_write_data
	.import easyflash_write_byte
	.import easyflash_erase_sector

	.import easyflash_write_bank
	.import easyflash_write_addr
	.import easyflash_write_len


	.segment "LOADERA000"

crunched:	.res 1
bank:		.res 1
offset:		.res 2
length:		.res 2

loadcount:	.byte 1


	.segment "LOADER"

loader_init:
	clc
	rts

u4loader_run:
	jsr u4loader_load
	jmp (u4loader_fileaddr)

u4loader_load:
	lda loadcount		; skip loading the first file (title music)
	beq :+
	dec loadcount
	clc
	jmp u4loader_iodone
:
	lda u4loader_filenum	; 1a, 7e, 7f, and 80 are save files.
	cmp #$1a
	beq loadsavefile
	cmp #$7e
	bcc :+
	cmp #$81
	bcc loadsavefile
:
	ldx currdisk
	lda filemap_lo - 1,x
	sta filemap_ptr
	lda filemap_hi - 1,x
	sta filemap_ptr + 1

	lda u4loader_filenum	; $00-$1c, $40-$9f becomes $00-$7f.
	cmp #$40
	bcc :+
	sec
	sbc #$20
:	tax

	sei			; Disable IRQs.
	lda #$34		; Read filemap under $d000.
	sta $01

filemap_ptr = * + 1		; Get efs file number.
	lda $5e1f,x
	tax

	inc $01

	lda #gam_bank
	sta ef_bank
	jsr get_file_bank_offset_length

	lda #gam_bank		; Add to disk bank base.
	clc
	adc bank
	sta bank

	jsr efs_openfile

	jsr efs_readbyte
	sta aptr
	sta u4loader_fileaddr
	jsr efs_readbyte
	sta aptr + 1
	sta u4loader_fileaddr + 1

load_crunched_file:
	jsr lzmv_unpack
	clc
	jmp u4loader_iodone


loadsavefile:
	jsr set_savefile_addr_len

	jsr find_savefile
	bcc @found

	ldy #$1f		; Force "no active game".
	lda #0
:	sta (aptr),y
	dey
	bpl :-
	clc
	jmp u4loader_iodone

@found:
	jsr inc_efsptr_x
	jsr inc_efsptr_x
	jsr getbyte_inc
	sta length
	jsr getbyte_inc
	sta length + 1

	ldy #0
	sty @y
	cpy length + 1
	beq @loadlo
@loadhi:
	jsr getbyte_inc
	ldy @y
	sta (aptr),y
	inc @y
	bne @loadhi
	inc aptr + 1
	dec length + 1
	bne @loadhi

@loadlo:
	ldy @y
	cpy length
	beq @done
	jsr getbyte_inc
	ldy @y
	sta (aptr),y
	inc @y
	bne @loadlo

@done:
	clc
	jmp u4loader_iodone

@y:	.res 1


u4loader_readblock:
	lda u4loader_fileaddr
	sta aptr
	lda u4loader_fileaddr + 1
	sta aptr + 1

	ldy currdisk
	lda efs_bank - 1,y
	sta ef_bank

	ldx u4loader_blocknum
	dex
	jsr get_file_bank_offset_length
	lda #0			; Length is always < 256.
	sta length + 1

	ldy currdisk
	lda efs_bank - 1,y
	clc			; Add to disk bank base.
	adc bank
	sta bank

	jsr efs_openfile

	jmp load_crunched_file


efs_openfile:
	lda #EF_8K
	sta ef_control
	lda bank
	sta ef_bank
	lda offset + 1
	sta efsptr + 1
	rts


u4loader_save:
	; Locate the current file.
	jsr find_savefile
	bcs @save

	; If found, prepare for delete.
	stx easyflash_write_addr
	lda efsptr + 1
	sta easyflash_write_addr + 1
	lda bank
	sta easyflash_write_bank

	; Check if the flash is close to being full.
	cmp #$3f
	bcc @dontformat

	; Only check when quit & save tries to save the first file.
	lda u4loader_filenum
	cmp #$7f
	bne @dontformat

	; Erase sectors to make space for new save files.
	lda #sav_bank
	sta @erase_bank
	jsr @prepare_write
@erase:
	lda @erase_bank
	ldy #>efsbank_start
	jsr easyflash_erase_sector

	lda @erase_bank
	clc
	adc #8
	cmp #$40
	bcs @save
	sta @erase_bank
	bcc @erase

@dontformat:
	; Delete it.
	jsr @prepare_write
	jsr easyflash_setaddr
	lda #0
	jsr easyflash_write_byte

@save:
	; Find start of free space.
	lda u4loader_filenum
	pha
	lda #$ff
	sta u4loader_filenum
	jsr find_savefile
	pla
	sta u4loader_filenum
	bcc :+

	; Flash full, should never happen.
	lda #15
	sta $d020
	jmp *
:

	stx easyflash_write_addr
	lda efsptr + 1
	sta easyflash_write_addr + 1
	lda bank
	sta easyflash_write_bank

	jsr @prepare_write

	jsr easyflash_setaddr

	jsr set_savefile_addr_len

	; Write file header.
	lda u4loader_filenum
	jsr easyflash_write_byte
	lda #$ff
	jsr easyflash_write_byte
	lda easyflash_write_len
	jsr easyflash_write_byte
	lda easyflash_write_len + 1
	jsr easyflash_write_byte

	; Write file contents.
	jsr easyflash_write_data

	jsr @finish_write

	clc
	jmp u4loader_iodone

@erase_bank:
	.res 1

@prepare_write:
	lda @prepared
	bmi :+
	jsr easyflash_prepare_write
	dec @prepared
:	rts

@finish_write:
	lda @prepared
	beq :+
	jsr easyflash_finish_write
	lda #0
	sta @prepared
:	rts

@prepared:
	.byte 0


set_savefile_addr_len:
	lda u4loader_filenum
	cmp #$1a
	beq @s1a
	cmp #$80
	beq @s80
; 7e/7f
	ldax #$0100
	stax easyflash_write_len
	ldax #$ac00
	jmp @setaddr
@s80:
	ldax #$0200
	stax easyflash_write_len
	ldax #$aa00
	jmp @setaddr
@s1a:
	ldax #$0020
	stax easyflash_write_len
	ldax #$0010
	;jmp @setaddr
@setaddr:
	stax u4loader_fileaddr
	stax aptr
	rts


find_savefile:
	ldx #sav_bank
	stx bank
	stx ef_bank
	ldx #EF_8K
	stx ef_control
	ldx #>efsbank_start
	stx efsptr + 1
	ldx #<efsbank_start
	stx offset
@check_file:
	jsr getbyte
	cpy u4loader_filenum
	beq @found
	cpy #$ff
	beq @file_not_found

	jsr inc_efsptr_x
	jsr inc_efsptr_x
	jsr getbyte_inc
	sta length
	jsr getbyte_inc
	sta length + 1

	cmp #0
	beq :+
@skippage:
	jsr inc_efsptr_page
	dec length + 1
	bne @skippage
:	txa
	clc
	adc length
	tax
	bcc @check_file
	jsr inc_efsptr_page
	jmp @check_file

@found:
	tya
	clc
	rts

@file_not_found:
	tya
	sec
	rts


getbyte_inc:
	jsr getbyte
	tya
inc_efsptr_x:
	inx
	bne :+
inc_efsptr_page:
	inc efsptr + 1
	ldy efsptr + 1
	cpy #>efsbank_end
	bcc :+

	ldy #>efsbank_start
	sty efsptr + 1
	inc bank
	lda bank
	sta ef_bank
:
	rts


get_crunched_byte:
	sty @gcb_y
	jsr efs_readbyte
@gcb_y = * + 1
	ldy #$1f
	rts

efs_readbyte:
	ldx offset
	jsr getbyte

	inc offset
	bne :+
	inc efsptr + 1
	lda efsptr + 1
	cmp #>efsbank_end
	bne :+

	lda #>efsbank_start
	sta efsptr + 1
	inc bank
	lda bank
	sta ef_bank
:
	tya
	clc
	rts

@efs_eof:
	lda #EF_KILL
	sta ef_control
	sec
	rts


	.segment "LOWLOADER"

get_file_bank_offset_length:
	sei
	lda #EF_8K		; Enable cartridge to read efs tables.
	sta ef_control
	lda #$37
	sta $01

	lda efs_file_bank,x	; Get bank and file offset.
	sta bank
	lda efs_offset_lo,x
	sta offset
	lda efs_offset_hi,x
	sta offset + 1
	lda efs_length_lo,x
	sta length
	lda efs_length_hi,x
	sta length + 1

	lda #$35
	sta $01
	lda #EF_KILL
	sta ef_control
	cli
	rts


getbyte:
	sei
	lda #$37
	sta $01
efsptr = * + 1
	ldy efsbank_start,x
	lda #$35
	sta $01
	cli
	rts
