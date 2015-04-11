	.export u4loader_run
	.export u4loader_load
	.export u4loader_save
	.export u4loader_readblock

	.export get_crunched_byte

	.export loader_send, loader_recv
	.export supercpu_send, supercpu_recv
	.export dtv2_send, dtv2_recv
	.export dtv2_fast, dtv2_slow
	.export loader_send_waitbadline, loader_recv_waitbadline
	.export loader_recv_palntsc
	.export loader_drivetype


	.importzp aptr
	.importzp currdisk

	.import u4loader_fileaddr
	.import u4loader_blocknum
	.import u4loader_filenum
	.import u4loader_iodone

	.import filemap_lo
	.import filemap_hi

	.import lzmv_unpack

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


buffer		= $9e00


	.segment "LOADERA000"

crunched:	.res 1
sector:		.res 1
track:		.res 1
offset:		.res 1

fname:
	.byte "s00"			; filename


	.segment "LOWLOADER"


	.segment "LOADER"

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
@try:
	jsr doload
	bcc @ok
	inc $d020
	bcs @try
@ok:
	jmp u4loader_iodone


u4loader_save:
	ldx u4loader_filenum
	cpx #$40
	bcs @long

	lda #$10		; the only save file is $1a at $0010
	sta u4loader_fileaddr
	lda #$00
	sta u4loader_fileaddr + 1

	jmp @try

@long:
	; file:   $7e   $7f   $80
	; addr: $ac00 $ac00 $aa00
	lda #$ac
	cpx #$80
	bne :+
	lda #$aa
:
	sta u4loader_fileaddr + 1
	lda #0
	sta u4loader_fileaddr

@try:
	jsr dosave
	bcc @ok
	inc $d020
	bcs @try
@ok:
	jmp u4loader_iodone


doload:
	jsr setname		; check for iffl or save game file

	lda crunched
	beq loadplain

@loadiffl:			; do iffl load
	jsr readsector		; read start track/sector
	bcc :+
	rts
:
	jsr iffl_getbyte
	sta aptr
	sta u4loader_fileaddr
	jsr iffl_getbyte
	sta aptr + 1
	sta u4loader_fileaddr + 1

doifflload:
	jsr lzmv_unpack
	clc
	rts

loadplain:
	lda #1			; load file
	jsr startfile
	bcc :+
	rts
:
	jsr loader_getbyte
	sta aptr
	jsr loader_getbyte
	sta aptr + 1

:	jsr loader_getbyte
	bcs loadeof
	ldx #0
	sta (aptr,x)
	inc aptr
	bne :-
	inc aptr + 1
	bne :-
loadeof:
	clc
	rts


dosave:
	jsr setname		; check for iffl or save game file

	lda #2
	jsr startfile
	bcc :+
	rts
:
	lda u4loader_fileaddr
	sta aptr
	jsr loader_sendbyte
	bcc :+
	rts
:
	lda u4loader_fileaddr + 1
	sta aptr + 1
	jsr loader_sendbyte
	bcc :+
	rts
:
	ldy #0
@save:	lda (aptr),y
	jsr loader_sendbyte
	bcs @done
	iny
	bne @save
	inc aptr + 1
	bne @save
@done:
	clc
	rts


startfile:
	pha

	lda #0
	sta loader_ctr
	sta saver_ctr

	pla
	jsr loader_send

	lda #3			; name len
	jsr loader_send

	ldx #0			; send name
:	lda fname,x
	jsr loader_send
	inx
	cpx #3
	bne :-

	jsr loader_recv		; get reply
	clc
	beq :+
	sec
:	rts


setname:
	ldx #1			; assume crunched iffl file
	stx crunched

	lda u4loader_filenum	; 1a, 7e, 7f, and 80 are uncrunched save files
	cmp #$1a
	beq notcrunched
	cmp #$7e
	bcc @crunched
	cmp #$81
	bcc notcrunched

@crunched:
	ldx currdisk
	lda filemap_lo - 1,x
	sta filemap_ptr
	lda filemap_hi - 1,x
	sta filemap_ptr + 1

	lda u4loader_filenum	; $00-$1c, $40-$9f becomes $00-$7f
	cmp #$40
	bcc :+
	sec
	sbc #$20
:	tax

	sei
	dec $01

filemap_ptr = * + 1		; get iffl file number
	lda $5e1f,x

	tax			; save track, sector, and offset
	lda gam_track,x
	sta track
	lda gam_sector,x
	sta sector
	lda gam_offset,x
	sta offset

	inc $01
	cli
	rts

notcrunched:
	ldx #0
	stx crunched

	lda u4loader_filenum
	lsr
	lsr
	lsr
	lsr
	jsr gethex
	sta fname + 1
	lda u4loader_filenum
	and #$0f
	jsr gethex
	sta fname + 2

	rts

gethex:
	ora #$30
	cmp #$3a
	bcc @gothex
	clc
	adc #7
@gothex:
	rts


; read block

u4loader_readblock:
	lda u4loader_fileaddr
	sta aptr
	lda u4loader_fileaddr + 1
	sta aptr + 1

	ldy currdisk
	lda t_addr_hi - 2,y
	sta ttptr + 1
	lda s_addr_hi - 2,y
	sta stptr + 1
	lda o_addr_hi - 2,y
	sta otptr + 1

	sei
	dec $01

	ldx u4loader_blocknum	; save track, sector, and offset
	dex
ttptr = * + 1
	lda iffl_track,x
	sta track
stptr = * + 1
	lda iffl_sector,x
	sta sector
otptr = * + 1
	lda iffl_offset,x
	sta offset

	inc $01
	cli

	jsr readsector
	bcc :+
	rts
:
	jmp doifflload


; read sector

readsector:
	.ifdef DEBUGREADSECTOR
	jsr debugreadsector
	.endif
	lda #3			; read sector command
	jsr loader_send

	lda track
	jsr loader_send
	lda sector
	jsr loader_send

	;lda #0			; start offset
	;jsr loader_send

	lda #<256		; length
doreadsector:
	jsr loader_send

	jsr loader_recv		; get status
	beq :+
	sec
	rts
:
	ldy #0
@read:
	jsr loader_recv		; read data
	sta buffer,y
	iny
	bne @read
	clc
	rts

readnextsector:
	.ifdef DEBUGREADSECTOR
	jsr debugreadsector
	.endif
	lda #4			; read next sector command
	jmp doreadsector


get_crunched_byte:
	sty @gcb_y
	jsr iffl_getbyte
@gcb_y = * + 1
	ldy #$1f
	rts

iffl_getbyte:
	clc
	ldx offset
	bne @getbyte

	lda buffer
	sta track
	lda buffer + 1
	sta sector
;	jsr readsector
	jsr readnextsector
	bcc :+
	rts
:
	ldx #2
	stx offset
@getbyte:
	inc offset
	lda buffer,x
	rts


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


loader_sendbyte:
	pha
	lda saver_ctr
	beq @nextblock
@return:
	dec saver_ctr
	pla
	jsr loader_send
	clc
	rts
@nextblock:
	jsr loader_recv
	beq @eof
	sta saver_ctr
	jmp @return
@eof:
	pla
	sec
	rts


loader_send:
	sta loader_send_savea
loader_send_do:
	sty loader_send_savey

	pha
	lsr
	lsr
	lsr
	lsr
	tay

	lda $dd00
	and #7
	sta $dd00
	sta savedd00
	eor #$07
	ora #$38
	sta $dd02

@waitdrv:
	bit $dd00		; wait for drive to signal ready to receive
	bvs @waitdrv		; with CLK low

	lda $dd00		; pull DATA low to acknowledge
	ora #$20
	sta $dd00

@wait2:
	bit $dd00		; wait for drive to release CLK
	bvc @wait2

	sei

loader_send_waitbadline:
	lda $d011		; wait until a badline won't screw up
	clc			; the timing
	sbc $d012
	and #7
	beq loader_send_waitbadline

	lda $dd00		; release DATA to signal that data is coming
	;ora #$20
	and #$df
	sta $dd00

	lda sendtab,y		; send the first two bits
	sta $dd00

	lsr
	lsr
	and #%00110000		; send the next two
	sta $dd00

	pla			; get the next nybble
	and #$0f
	tay
	lda sendtab,y
	sta $dd00

	lsr			; send the last two bits
	lsr
	and #%00110000
	sta $dd00

	nop			; slight delay, and...
	nop
	lda savedd00		; restore $dd00 and $dd02
	sta $dd00
	lda #$3f
	sta $dd02

	ldy loader_send_savey
	lda loader_send_savea

	cli
	rts

savedd00:		.res 1
loader_send_savea:	.res 1
loader_send_savey:	.res 1


loader_recv:
:	bit $dd00		; wait for drive to signal data ready with
	bmi :-			; DATA low

loader_recv_do:
	lda $dd00		; drop CLK to acknowledge
	ora #$10
	sta $dd00

@wait2:
	bit $dd00		; wait for drive to release DATA
	bpl @wait2

	sei

loader_recv_waitbadline:
	lda $d011		; wait until a badline won't screw up
	clc			; the timing
	sbc $d012
	and #7
	beq loader_recv_waitbadline

	lda $dd00
	;ora #$10
	and #$ef
	sta $dd00		; set CLK low to signal that we are receiving
loader_recv_palntsc:
	beq :+			; 2 cycles for PAL, 3 for NTSC
:	nop

	and #3
	sta @eor+1
	sta $dd00		; set CLK high to be able to read the
	lda $dd00		; bits the diskdrive sends
	lsr
	lsr
	eor $dd00
	lsr
	lsr
	eor $dd00
	lsr
	lsr
@eor:
	eor #$00
	eor $dd00

	cli
	rts


supercpu_send:
	sta loader_send_savea
	sta $d07a		; switch to 1 MHz
	jsr loader_send_do
	sta $d07b		; switch back to 20 MHz
	rts


supercpu_recv:
:	bit $dd00		; wait for drive
	bmi :-

	sta $d07a		; switch to 1 MHz
	jsr loader_recv_do
	sta $d07b		; switch back to 20 MHz
	rts


dtv2_send:
	sta loader_send_savea
	jsr dtv2_slow		; disable speedup
	jsr loader_send_do
	jmp dtv2_fast		; reenable speedup


dtv2_recv:
:	bit $dd00		; wait for drive
	bmi :-

	jsr dtv2_slow		; disable speedup
	jsr loader_recv_do
	jmp dtv2_fast		; reenable speedup


dtv2_fast:
	php
	sei
	.byte $32, $99		; map cpu control reg into A
	lda #3			; enable burst and skip cycle
	.byte $32, $00		; return default A
	plp
	rts


dtv2_slow:
	php
	sei
	.byte $32, $99		; map cpu control reg into A
	lda #0			; disable burst and skip cycle
	.byte $32, $00		; return default A
	plp
	rts



t_addr_hi:
	.byte >map_track
	.byte >tlk_track
	.byte >dng_track

s_addr_hi:
	.byte >map_sector
	.byte >tlk_sector
	.byte >dng_sector

o_addr_hi:
	.byte >map_offset
	.byte >tlk_offset
	.byte >dng_offset

loadcount:	.byte 1

loader_ctr:	.res 1
saver_ctr:	.res 1
loader_drivetype:	.res 1

gcb_x:		.res 1
gcb_y:		.res 1

sendtab:
	.byte $00, $80, $20, $a0
	.byte $40, $c0, $60, $e0
	.byte $10, $90, $30, $b0
	.byte $50, $d0, $70, $f0
