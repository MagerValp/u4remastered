

	.segment "DRIVECMDFD"


	.include "drivecodejumptable.i"


serport		= $4001

retries	= 5			; number of retries when reading a sector
ledctl	= $4000			; LED control
ledbit	= $40
execjob	= $ff54			; execute job
job3	= $05
trk3	= $11
sct3	= $12
zptmp	= $13


drv_get_dir_ts:
	lda $54
	sta track
	lda $56
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
	sta job3
	lda track
	sta trk3
	lda sector
	sta sct3

	ldy #retries		; retry counter
	jsr blink		; turn on led

retry:
	ldx #3			; job 3
	lda zptmp
	jsr execjob
	lda job3		; cmd fd doesn't return status

	cmp #2			; check status
	bcc success

	dey			; decrease retry counter
	bne retry
drv_track_ts:
failure:
	sec
	rts
success:
	clc
blink:
	lda ledctl		; blink LED
	eor #ledbit
	sta ledctl
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
