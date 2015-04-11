	.include "drivecode.i"


	.export drv_start

	.exportzp track, sector, stack

	.export drivebuffer
	.export track_list, sector_list


track	= $7a
sector	= $7b
stack	= $7c


	.segment "DRIVEBUFFER"

drivebuffer:	.res $100
track_list	= drivebuffer + $80
sector_list	= drivebuffer + $c0


	.segment "DRIVECOMMON"


; ------------------------------------------------------------------------
;
; load file
; args: filename len, filename
; returns: $00 followed by data blocks for ok, $80..$ff for error
load:
	jsr getandfindname
	bcc :+
	lda #$81		; file not found
	jmp error
:
@load:
	lda #0
	jsr drv_send

@sendsector:
	jsr drv_readsector
	bcc :+
	lda #$ff		; send read error
	jmp error
:
	ldx #254		; send 254 bytes (full sector)
	lda drivebuffer		; last sector?
	bne :+
	ldx drivebuffer + 1	; send number of bytes in sector (1-254)
	dex
:	stx @buflen
	txa
	jsr drv_send		; send byte count

	ldx #0			; send data
@send:
	lda drivebuffer + 2,x
	jsr drv_send
	inx
@buflen = * + 1
	cpx #$ff
	bne @send

	jsr nextts
	bcc @sendsector
@done:
	lda #0			; send 0 when we're done
	jmp senddone


; ------------------------------------------------------------------------
;
; read sector
; args: track, sector, length
; returns: $00 ok, $80..$ff for error
readsector:
	jsr drv_recv
	sta track
	jsr drv_recv
	sta sector
	jsr drv_recv
	sta rs_len

doreadsector:
	jsr drv_readsector
	bcc :+
	lda #$ff
	jmp error
:
	lda #0
	jsr drv_send

sendsector:
	ldx #0
:	lda drivebuffer,x
	jsr drv_send
	inx
rs_len = * + 1
	cpx #$ff
	bne :-

	jmp drv_main


drv_start:
	tsx
	stx stack

drv_main:
	.ifdef TEST

	cli
	sei
	jsr drv_recv		; echo all data we receive
	jsr drv_send
	jmp drv_main

	.else

	cli			; allow IRQs when waiting
	;sei			; drv_recv will disable IRQs
	jsr drv_recv		; get command byte, exit if ATN goes low

	cmp #1			; load a file
	beq load
	cmp #2			; save and replace a file
	beq save
	cmp #3			; read sector
	beq readsector
	cmp #4			; read next sector in chain
	beq readnextsector
	cmp #5			; read track and sector links
	beq readtrackts
@unknown:
	lda #$80		; send unknown command error

	.endif

senddone:
error:
	jsr drv_send
	jmp drv_main


; ------------------------------------------------------------------------
;
; read next sector
; args: copied from last call to read sector
; returns: $00 ok, $80..$ff for error
readnextsector:
	jsr nextts
	jmp doreadsector


; ------------------------------------------------------------------------
;
; save and replace file
; args: filename len, filename
; returns: $00 ok, $80..$ff for error
save:
	jsr getandfindname
	bcc :+
	lda #$81		; file not found
	jmp error
:
	lda #0
	jsr drv_send
@receivesector:
	jsr drv_readsector
	bcc :+
@error:
	lda #$ff		; send read error
	jmp error
:
	ldx #254		; receive 254 bytes (full sector)
	lda drivebuffer		; last sector?
	bne :+
	ldx drivebuffer + 1	; send number of bytes in sector (1-254)
	dex
:	stx @buflen
	txa
	jsr drv_send		; send byte count

	ldx #0			; receive data
@receive:
	jsr drv_recv
	sta drivebuffer + 2,x
	inx
@buflen = * + 1
	cpx #$ff
	bne @receive

	jsr drv_writesector	; write back the modified sector
	bcs @error

	jsr nextts
	bcc @receivesector
@done:
	jsr drv_flush		; flush the track cache

	lda #0			; send 0 when we're done
	jmp senddone


; next t/s in chain
nextts:
	sec
	lda drivebuffer
	beq :+
	sta track
	lda drivebuffer + 1
	sta sector
	clc
:	rts


; ------------------------------------------------------------------------
;
; read track and sector links
; args: track
; returns: numts followed by t/s pairs backwards, or $80..$ff for error
readtrackts:
	jsr drv_recv
	jsr drv_track_ts
	bcc :+
	lda #$ff
	jmp error
:	tax
	jsr drv_send

:	lda track_list,x
	jsr drv_send
	lda sector_list,x
	jsr drv_send
	dex
	bpl :-
	jmp drv_main


findfile:
	jsr drv_get_dir_ts

@readsector:
	jsr drv_readsector
	bcc :+
	rts
:
	ldx #0
@checkentry:
	lda drivebuffer + 2,x	; check if it's a PRG
	cmp #$82
	bne @next

	lda drivebuffer + 3,x	; save track and sector
	sta track
	lda drivebuffer + 4,x
	sta sector

	txa			; compare name
	clc
	adc #5
	sta @name
	ldy #15
@compare:
	lda fname,y
@name = * + 1
	cmp drivebuffer,y
	bne @next
	dey
	bpl @compare
	clc			; file found, return with clc
	rts
@next:
	txa			; next entry
	clc
	adc #32
	tax
	bcc @checkentry

	jsr nextts		; get next t/s in dir chain
	bcc @readsector

	;sec
	rts			; not found, return with sec


; receive filename, locate file
getandfindname:
	ldx #$0f
	lda #$a0
:	sta fname,x
	dex
	bpl :-

	jsr drv_recv
	sta @len

	ldx #0
:	jsr drv_recv
	sta fname,x
	inx
@len = * + 1
	cpx #$ff
	bne :-

	lda fname
	cmp #'$'
	bne findfile
	jmp drv_get_dir_ts


fname:		.res 16
