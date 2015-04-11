	.export iffl_scan


	.import loader_send
	.import loader_recv

	.import loader_drivetype

	.import map_iffl_len
	.import tlk_iffl_len
	.import dng_iffl_len
	.import gam_iffl_len

	.import iffl_track
	.import map_track
	.import tlk_track
	.import dng_track
	.import gam_track

	.import iffl_sector
	.import map_sector
	.import tlk_sector
	.import dng_sector
	.import gam_sector

	.import iffl_offset
	.import map_offset
	.import tlk_offset
	.import dng_offset
	.import gam_offset


	.include "files/iffl/iffl_file_count.i"


	.ifdef DEBUG

;DEBUGSCANNER	= 1

	.endif

	.bss

ifflnum:	.res 1

buf_track:	.res $100
buf_sector:	.res $100
buf_offset:	.res $100

buf		= $9e00

t_starttrack	= $0100
t_startsector	= $0110


	.code

iffl_scan:
	.ifdef DEBUGSCANNER
	dec $d021
	.endif

	ldx #$0f
	lda #0
:	sta t_starttrack,x
	sta t_startsector,x
	dex
	bpl :-

;	ldx #4
;:	lda activity,x
;	and #$3f
;	sta $07e3,x
;	dex
;	bpl :-

	jsr readdir
	lda #$20
	bit $d011
	beq :+
	lda #$10
	sta $07e3
:	lda #1
	sta $dbe3

	ldy #0
@next:
	.ifdef DEBUGSCANNER
	dec $d021
	.endif

	sty ifflnum
	jsr scanfile
	bcs @skipcopy

	ldx #3
@white:
	lda #$20
	bit $d011
	beq @text
	lda #$10
	sta $07e4,x
@text:
	lda #1
	sta $dbe4,x
	dex
	bpl @white

	ldy ifflnum

	lda ttab_lo,y
	sta ttabptr
	lda ttab_hi,y
	sta ttabptr + 1

	lda stab_lo,y
	sta stabptr
	lda stab_hi,y
	sta stabptr + 1

	lda otab_lo,y
	sta otabptr
	lda otab_hi,y
	sta otabptr + 1

	lda numfiles,y
	sta copycount

	jsr copytables

@skipcopy:
	ldy ifflnum
	iny
	cpy #4
	bne @next

	clc
	rts


copytables:
	jsr ramd000

	ldx #0
:
	lda buf_track,x
ttabptr = * + 1
	sta $5e1f,x

	lda buf_sector,x
stabptr = * + 1
	sta $5e1f,x

	lda buf_offset,x
otabptr = * + 1
	sta $5e1f,x

	inx
copycount = * + 1
	cpx #$5e
	bne :-

	jmp restore01


ramd000:
	sei
	lda $01
	sta save01
	lda #$34
	sta $01
	rts

restore01:
save01 = * + 1
	lda #$00
	sta $01
	cli
	rts


	.bss

fcount:		.res 1
fnum:		.res 1
flongshort:	.res 1

track:		.res 1
sector:		.res 1
offset:		.res 2


	.code

; scan IFFL files
scanfile:
	lda t_starttrack,y
	bne :+
	sec				; file not found, don't scan
	rts
:	sta track
	lda t_startsector,y
	sta sector

	lda numfiles,y
	sta fcount

	lda t_filelen_lo,y
	sta flenptr
	lda t_filelen_hi,y
	sta flenptr + 1

	lda t_longshort,y
	sta flongshort

	lda #0
	sta offset
	sta offset + 1

	lda #0
	sta fnum
@next:
	ldx ifflnum			; flash status indicator
	lda #$20
	bit $d011
	beq @text
	lda $07e4,x
	clc
	adc #$10
	sta $07e4,x
@text:
	inc $dbe4,x

	.ifdef DEBUGSCANNER
	jsr debugscan
	.endif

	ldx fnum			; save track, sector, and offset for current file
	lda track
	sta buf_track,x
	lda sector
	sta buf_sector,x
	lda offset			; offset + 2 for actual buffer position
	clc
	adc #2
	sta buf_offset,x

	;ldx fnum			; add the length to offset
	jsr getlen
	clc
	adc offset
	sta offset
	tya
	adc offset + 1
	sta offset + 1

@moveforward:				; while offset >= 254...
	lda offset + 1
	bne @nextsector
	lda offset
	cmp #$fe
	beq @nextsector
	cmp #$ff
	bne @gotnext
@nextsector:
	lda offset			; subtract 254 from the offset...
	sec
	sbc #254
	sta offset
	bcs :+
	dec offset + 1
:
	jsr readts			; and move to the next sector
	jsr nextsector
	bcc @moveforward

	lda offset			; check if last file ends on sector
	bne @error			; boundary
	lda fcount
	cmp #1
	beq @gotlast
@error:
	inc $d020			; unexpected eof
	jmp * - 3
@gotnext:
	inc fnum
	dec fcount
	bne @next
@gotlast:
	clc
	rts


getlen:
	ldy flongshort
	beq @short
@long:
	txa
	asl
	tax
	inx
	jsr @getlen
	tay
	dex
@getlen:
@short:
flenptr = * + 1
	lda $5e1f,x
	rts


nextsector:
	sec
	lda buf
	beq @eof
	sta track
	lda buf + 1
	sta sector
	clc
@eof:
	rts


readts:
	lda loader_drivetype
	beq :+
	cmp #5
	bcc readts_fast
:
	.ifdef DEBUGSCANNER
	lda #$13
	sta $0428
	.endif

	lda #3				; read sector command
	jsr loader_send

	lda track
	.ifdef DEBUGSCANNER
	sta $0429
	.endif
	jsr loader_send
	lda sector
	.ifdef DEBUGSCANNER
	sta $042a
	.endif
	jsr loader_send

	;lda #0				; offset
	;jsr loader_send

	lda #2				; length
	jsr loader_send

	jsr loader_recv			; get status
	beq :+
	.ifdef DEBUGSCANNER
	inc $d020
	jmp *-3
	.endif
	sec
	rts
:
	jsr loader_recv			; get track and sector
	sta buf
	jsr loader_recv
	sta buf + 1

	clc
	rts


; scan one track at a time, only supported on 1541-1581
readts_fast:
	.ifdef DEBUGSCANNER
	lda #$06
	sta $0428
	.endif

	lda track			; is current track buffered?
	.ifdef DEBUGSCANNER
	sta $0429
	.endif
	cmp curtrk
	beq :+
	jsr gettrackts			; no, read it in
	bcs @err
:	ldx sector
	.ifdef DEBUGSCANNER
	stx $042a
	.endif
	lda trkbuf,x
	sta buf
	lda secbuf,x
	sta buf + 1
	clc
@err:
	rts


; read and buffer track of ts links
trkbuf:	 .res 64
secbuf:	 .res 64
curtrk:	 .byte 0

gettrackts:
	sta curtrk
	pha
	lda #5				; read track ts
	jsr loader_send
	pla
	jsr loader_send			; track num

	jsr loader_recv			; get status or count
	bpl :+				; negative for error
	sec
	rts
:
	tax				; last sector num
:	jsr loader_recv
	sta trkbuf,x
	jsr loader_recv
	sta secbuf,x
	dex
	bpl :-

	clc
	rts


readdir:
	.ifdef DEBUGSCANNER
	lda #'1'
	sta $0450
	.endif
	lda #1
	jsr loader_send			; send command

	.ifdef DEBUGSCANNER
	lda #'1'
	sta $0451
	.endif
	lda #1				; name len
	jsr loader_send

	.ifdef DEBUGSCANNER
	lda #'$'
	sta $0452
	.endif
	lda #'$'			; send name
	jsr loader_send

	lda #0
	sta loader_ctr

	jsr loader_recv			; get reply
	.ifdef DEBUGSCANNER
	sta $0453
	.endif
	bmi @err

:	jsr readdirblock
	bcs @done
	jsr parsedirblock
	jmp :-
@done:
	rts
@err:
	inc $d020
	jmp @err


readdirblock:
	ldx #2
@read1:
	jsr loader_getbyte
	bcs :+
	sta buf,x
	.ifdef DEBUGSCANNER
	sta $0478,x
	.endif
	inx
	bne @read1
:	rts


parsedirblock:
	.ifdef DEBUGSCANNER
	inc $d020
	.endif
	ldy #0
@parse:
	lda #$20
	bit $d011
	beq @text
	lda $07e3
	clc
	adc #$10
	sta $07e3
@text:
	inc $dbe3

	lda buf + 2,y			; PRG
	cmp #$82
	bne @next
	lda buf + 8,y			; max len 3
	cmp #$a0
	bne @next

	jsr checkname			; check if it's an IFFL file
	bcs @next

	lda buf + 3,y			; yep, save track/sector
	sta t_starttrack,x
	lda buf + 4,y
	sta t_startsector,x
@next:
	tya
	clc
	adc #32
	tay
	bcc @parse

	rts

checkname:
	lda buf + 5,y
	ldx #3
:	cmp ifflname0,x
	beq @match
	dex
	bpl :-
@nomatch:
	sec
	rts
@match:
	lda buf + 6,y
	cmp ifflname1,x
	bne @nomatch
	lda buf + 7,y
	cmp ifflname2,x
	bne @nomatch
	clc
	rts


convhex:
	sec
	sbc #$30
	cmp #10
	bcc :+
	sec
	sbc #7
:	rts


; ------------------------------------------------------------------------
;
; fastloader
;

	.bss

data:		.res 1
loader_ctr:	.res 1


	.code

loader_getbyte:
	lda loader_ctr
	beq @nextblock
@return:
	dec loader_ctr
	jsr loader_recv
	clc
@eof:
	rts
@nextblock:
	jsr loader_recv
	sec
	beq @eof
	sta loader_ctr
	jmp @return


	.rodata

numfiles:
	.byte <num_map_files		; map
	.byte <num_tlk_files		; tlk
	.byte <num_dng_files 		; dng
	.byte <num_gam_files 		; gam


activity:
	.byte '$'			; dir
ifflname0:
	.byte 'm'			; map
	.byte 't'			; tlk
	.byte 'd'			; dng
	.byte 'g'			; gam

ifflname1:
	.byte 'a'
	.byte 'l'
	.byte 'n'
	.byte 'a'

ifflname2:
	.byte 'p'
	.byte 'k'
	.byte 'g'
	.byte 'm'

t_longshort:
	.byte 0				; map
	.byte 0				; tlk
	.byte 0				; dng
	.byte 1				; gam

t_filelen_hi:
	.byte >map_iffl_len
	.byte >tlk_iffl_len
	.byte >dng_iffl_len
	.byte >gam_iffl_len

t_filelen_lo:
	.byte <map_iffl_len
	.byte <tlk_iffl_len
	.byte <dng_iffl_len
	.byte <gam_iffl_len


ttab_hi:
	.byte >map_track
	.byte >tlk_track
	.byte >dng_track
	.byte >gam_track

ttab_lo:
	.byte <map_track
	.byte <tlk_track
	.byte <dng_track
	.byte <gam_track

stab_hi:
	.byte >map_sector
	.byte >tlk_sector
	.byte >dng_sector
	.byte >gam_sector

stab_lo:
	.byte <map_sector
	.byte <tlk_sector
	.byte <dng_sector
	.byte <gam_sector

otab_hi:
	.byte >map_offset
	.byte >tlk_offset
	.byte >dng_offset
	.byte >gam_offset

otab_lo:
	.byte <map_offset
	.byte <tlk_offset
	.byte <dng_offset
	.byte <gam_offset


	.ifdef DEBUGSCANNER

	.code

debugscan:
	lda #19
	jsr $ffd2

	lda fnum
	jsr printhex

	lda #' '
	jsr $ffd2

	lda track
	jsr printhex

	lda sector
	jsr printhex

	lda #' '
	jsr $ffd2

	lda offset
	;jmp printhex


printhex:
	pha
	lsr
	lsr
	lsr
	lsr
	jsr @print
	pla
	and #$0f
@print:
	ora #$30
	cmp #$3a
	bcc :+
	;sec
	adc #6
:	jmp $ffd2

	.endif
