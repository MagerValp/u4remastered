

	.import drivebuffer
	.import track_list, sector_list


	.segment "DRIVE1581"


	.include "drivecodejumptable.i"


serport		= $4001

retries	= 5			; number of retries when reading a sector
ledctl	= $4000			; LED control
ledbit	= $40
execjob	= $ff54			; execute job
job3	= $05
trk3	= $11
sct3	= $12
zptmp	= $45

bufptr	= $5e


drv_get_dir_ts:
	lda $022b
	sta track
	lda #3
	sta sector
	clc
	rts


; sector read subroutine. Returns clc if successful, sec if error
drv_readsector:
	lda #$80		; read sector job code
	jmp job


; sector write subroutine. Returns clc if successful, sec if error
drv_writesector:
	lda #$90
	jmp job


; flush, perform after writing sectors
drv_flush:
	lda #$a2
	;jmp job


job:
	sta zptmp
	lda track
	sta trk3
	lda sector
	sta sct3

	ldy #retries		; retry counter
	lda ledctl		; turn on led
	ora #ledbit
	sta ledctl

retry:
	ldx #3			; job 3
	lda zptmp
	jsr execjob

	cmp #2			; check status
	bcc success

	dey			; decrease retry counter
	bne retry
failure:
	;sec
	rts
success:
	clc

	lda ledctl		; blink LED
	and #<~ledbit
	sta ledctl
	rts


readtrack:
	sta $18
	lda track
	sta $17
	ldx #6
	lda #$80
	jsr execjob
	cmp #2
	rts


drv_track_ts:
	sta track
	lda #0
	sta bufptr
	jsr readtrack
	bcc :+
@error:
	rts
:
	jsr copyts

	ldx #19
:	lda track_list + 20,x
	sta track_list,x
	lda sector_list + 20,x
	sta sector_list,x
	dex
	bpl :-

	lda #20
	jsr readtrack
	bcs @error

copyts:
	;lda #0			; point to last sector in track cache
	;sta bufptr		; done above, saves 2 bytes
	lda #$1f
	sta bufptr + 1

	ldx #19			; read 20 sectors from cache
@getts:
	ldy #0
	lda (bufptr),y		; get track
	sta track_list + 20,x	; store in upper half
	iny
	lda (bufptr),y		; get sector
	sta sector_list + 20,x
	dec bufptr + 1		; previous sector
	dex
	bpl @getts

	lda #39			; number of sectors - 1
	clc
	rts


drv_send:
	ldy #$02		; set DATA low to signal that we're sending
	sty serport

	sta zptmp
	lsr
	lsr
	lsr
	lsr
	tay
	lda drv_sendtbl,y	; get the CLK, DATA pairs for low nybble
	pha
	lda zptmp
	and #$0f
	tay

	lda #$04
:	bit serport		; wait for CLK low
	beq :-

	lda #0			; release DATA
	sta serport

	lda #$04
:	bit serport		; wait for CLK high
	bne :-

; 2 MHz code

	lda drv_sendtbl,y	; get the CLK, DATA pairs for high nybble
	sta serport

	jsr @delay		; 20
	cmp ($00,x)
	nop

	asl
	and #$0f
	sta serport

	cmp ($00,x)		; 8
	nop

	pla
	sta serport

	cmp ($00,x)		; 8
	nop

	asl
	and #$0f
	sta serport

	pha			; 14
	pla
	pha
	pla

	lda #$00		; set CLK and DATA high
	sta serport

@delay:
	rts

drv_sendtbl:
	.byte $0f, $07, $0d, $05
	.byte $0b, $03, $09, $01
	.byte $0e, $06, $0c, $04
	.byte $0a, $02, $08, $00
drv_sendtbl_end:
	.assert (>drv_sendtbl) = (>drv_sendtbl_end), error, "drv_sendtbl crosses page boundary"


drv_exit:
	ldx stack
	txs
	rts

drv_recv:
	lda #$08		; CLK low to signal that we're receiving
	sta serport

	lda serport		; get EOR mask for data
	asl
	eor serport
	and #$e0
	sta @eor

	lda #$01
:	bit serport		; wait for DATA low
	bmi drv_exit
	beq :-

	sei			; disable IRQs

	lda #0			; release CLK
	sta serport

	lda #$01
:	bit serport		; wait for DATA high
	bne :-

; 2 MHz code

	jsr @delay		; 14
	nop

	lda serport		; get bits 7 and 5
	asl

	pha			; 14
	pla
	pha
	pla

	eor serport		; get bits 6 and 4

	asl
	asl
	asl

	jsr @delay		; 24
	jsr @delay

	eor serport		; get 3 and 1

	asl

	jsr @delay		; 18
	cmp ($00,x)

	eor serport		; finally get 2 and 0

@eor = * + 1
	eor #$5e

@delay:
	rts
