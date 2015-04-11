

	.import drivebuffer
	.import track_list, sector_list


	.segment "DRIVE1541"


	.include "drivecodejumptable.i"


serport		= $1800

retries	= 5			; number of retries when reading a sector
ledctl	= $1c00			; LED control
ledbit	= $08
job3	= $03
trk3	= $0c
sct3	= $0d
zptmp		= $1b

iddrv0	= $12			; disk drive id
id	= $16			; disk id

secpertrk	= $f24b		; get number of sectors in track
jobok		= $f505
waitsync        = $f556         ; wait for sync
decode          = $f7e8         ; decode 5 GCR bytes, bufferindex in Y
bufptr		= $30


drv_get_dir_ts:
	lda #18
	sta track
	lda #1
	sta sector
	clc
	; fall through

; flush, perform after writing sectors
drv_flush:
	rts


; sector read subroutine. Returns clc if successful, sec if error
drv_readsector:
	lda #$80		; read sector job code
	jmp job


; sector write subroutine. Returns clc if successful, sec if error
drv_writesector:
	lda #$90
	;jmp job

job:
	sta zptmp
	lda track
	sta trk3
	lda sector
	sta sct3

	ldy #retries		; retry counter
	jsr blink		; turn on led

retry:
	lda zptmp
	sta job3

	cli
@wait:
	lda job3
	bmi @wait

	sei

	cmp #2			; check status
	bcc success

	lda id			; check for disk ID change
	sta iddrv0
	lda id + 1
	sta iddrv0 + 1

	dey			; decrease retry counter
	bne retry
failure:
	;sec
	rts
success:
	clc
blink:
	lda ledctl		; blink LED
	eor #ledbit
	sta ledctl
	rts


drv_track_ts:
	sta track
	lda #$4c		; store jmp to our code in buffer
	sta drivebuffer
	lda #<dotrackts
	sta drivebuffer + 1
	lda #>dotrackts
	sta drivebuffer + 2
	lda #$e0		; start motor, execute code
	jsr job			; return carry clear
	lda #20			; num sectors - 1
	rts

dotrackts:
	lda #>drivebuffer
	sta bufptr + 1

	lda #21			; read 21 sectors, regardless of track
	sta sct3
@getts:
	lda #0			; read header to $0600
	jsr read5bytes
	lda drivebuffer
	cmp #$52		; check for sector header
	bne @getts

	lda #5			; read first 5 bytes to $0605
	jsr read5bytes

	ldy #0			; decode header
	sty bufptr
	jsr decode
	lda $54			; sector number
	pha

	ldy #5			; decode data
	jsr decode

	pla
	tax

	lda $53			; save track link
	sta track_list,x
	lda $54			; save sector link
	sta sector_list,x

	dec sct3
	bne @getts

	jmp jobok		; return controller status 01, ok


read5bytes:
	sta bufptr
	jsr waitsync		; wait for SYNC, clears Y
:	bvc :-			; wait for data
	clv
	lda $1c01
	sta (bufptr),y
	iny
	cpy #5			; read 5 GCR bytes
	bne :-
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

; 1 MHz code

	lda drv_sendtbl,y	; get the CLK, DATA pairs for high nybble
	sta serport

	asl
	and #$0f
	sta serport

	pla
	sta serport

	asl
	and #$0f
	sta serport

	nop 
	nop
	lda #$00		; set CLK and DATA high
	sta serport

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

;	lda serport		; get EOR mask for data
;	asl
;	eor serport
;	and #$e0
;	sta @eor

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

	nop
	nop
	lda serport		; get bits 7 and 5

	asl
	nop
	nop
	eor serport		; get bits 6 and 4

	asl
	asl
	asl
	cmp ($00,x)
	eor serport		; get 3 and 1

	asl
	nop
	nop
	eor serport		; finally get 2 and 0

;@eor = * + 1
;	eor #$5e

	rts
