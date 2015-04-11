	.include "macro.i"
	.include "kernal.i"
	.include "drivetype.i"


	.export loader_init
	.export dtv2_detect
	.exportzp loader_zp1, loader_zp2

	.import loader_detect
	.import loader_drivetype

	.import loader_send, loader_recv
	.import supercpu_send, supercpu_recv
	.import dtv2_send, dtv2_recv
	.import loader_recv_palntsc
	.import loader_send_waitbadline, loader_recv_waitbadline

	.import __DRIVECOMMON_RUN__
	.import __DRIVECOMMON_SIZE__
	.import __DRIVECOMMON_LOAD__

	.import drv_start

	.import __DRIVESPECIFIC_START__
	.import __DRIVESPECIFIC_SIZE__

	.import __DRIVE1541_LOAD__
	.import __DRIVE1541_LOAD__
	.import __DRIVE1571_LOAD__
	.import __DRIVE1581_LOAD__
	.import __DRIVECMDFD_LOAD__
	.import __DRIVECMDHD_LOAD__

	.import iffl_scan


cmdbytes	= 32			; number of bytes in one M-W command

	.segment "LOADERZP" : zeropage

code_ptr:	.res 2
loader_zp1	= code_ptr
loader_zp2	= code_ptr + 1

	.bss

code_len:		.res 2
cmd_data:		.res 1


	.data

cmd:		.byte "m-"
cmd_type:	.byte "w"
cmd_addr:	.addr $ffff
cmd_len:	.byte 0

u0m1:		.byte "u0>m1"


	.rodata

drivecodes:
	.addr 0
	.addr __DRIVE1541_LOAD__
	.addr __DRIVE1541_LOAD__	; 1570
	.addr __DRIVE1571_LOAD__
	.addr __DRIVE1581_LOAD__
	.addr __DRIVECMDFD_LOAD__
	.addr __DRIVECMDHD_LOAD__
	.addr 0
	.addr 0

	.code

; initialize loader by sending over drive code
loader_init:
	lda $ba				; default to device 8
	bne :+
	lda #8
	sta $ba
:
	lda #1				; prepare detection messages
	sta $0286
	ldx #24
	ldy #0
	clc
	jsr PLOT

	sei				; detect PAL or NTSC

	lda #$ff			; wait for line 255
:	cmp $d012
	bne :-

	lda #8				; wait for line 263
:	cmp $d012			; ntsc hits line 8 instead
	bne :-

	bit $d011			; msb set = pal
	bmi @pal
@ntsc:
	lda #$d0			; BNE = 3 cycles
	sta loader_recv_palntsc
	ldax #str_ntsc
	jmp @pal_ntsc_set
@pal:
	;lda #$f0			; BEQ = 2 cycles
	;sta loader_recv_palntsc
	ldax #str_pal
@pal_ntsc_set:
	cli

	jsr strout

	jsr dtv2_detect			; detect dtv2
	ldax #str_dtv2
	bcs @gotmodel

	ldy #0				; check for sings of C128

	lda $d030
	cmp #$ff
	beq :+
	iny
:
	lda $d600
	beq :+
	iny
:
	ldax #str_c64
	cpy #0
	beq :+
	ldax #str_c128
:
@gotmodel:
	jsr strout

	bit $d0bc			; detect SuperCPU
	bmi :+
	jsr supercpu
:
	ldax #str_dev			; print device number
	jsr strout

	ldx #$ff
	lda $ba
:	inx
	sec
	sbc #10
	bcs :-
	clc
	adc #10
	pha
	txa
	beq :+
	ora #$30
	jsr $ffd2
:	pla
	ora #$30
	jsr $ffd2	

	lda #' '
	jsr $ffd2

	jsr loader_detect		; detect what kind of drive we loaded from
	bcc :+
	rts
:	sta loader_drivetype
	asl
	tay
	lda str_drive + 1,y
	tax
	lda str_drive,y
	jsr strout

	ldax #__DRIVECOMMON_LOAD__	; send common drive code
	stax code_ptr

	ldax #__DRIVECOMMON_SIZE__
	stax code_len

	ldax #__DRIVECOMMON_RUN__
	stax cmd_addr

	jsr sendcode			; upload code

	jsr check1571disk		; check if 1571 disk is double sided
	bcc @codeptrset

	lda loader_drivetype
	asl
	tay
	lda drivecodes + 1,y		; send code for detected drive
	sta code_ptr + 1
	bne :+
	sec				; fail if there's no code
	rts
:	lda drivecodes,y
	sta code_ptr
@codeptrset:

	ldax #__DRIVESPECIFIC_SIZE__
	stax code_len

	ldax #__DRIVESPECIFIC_START__	; they all start at the same address
	stax cmd_addr

	jsr sendcode			; upload code

	lda #'e'			; execute
	sta cmd_type
	ldax #drv_start
	stax cmd_addr
	jsr send_cmd

	ldx #0				; delay
:	dex
	bne :-

	jmp iffl_scan


supercpu:
	ldax #str_scpu
	jsr strout

	lda #'1'
	bit $d0b0
	bmi :+
	lda #'2'
:	jsr $ffd2

	lda #$4c			; redirect to supercpu routines
	sta loader_send
	sta loader_recv
	ldax #supercpu_send
	stax loader_send + 1
	ldax #supercpu_recv
	stax loader_recv + 1

	rts


; detect DTV2 by checking VIC mirror regs
dtv2_detect:
	lda #1
	sta $d03f
	lda #$55
	sta $d000
	cmp $d040
	bne @dtv2
	lda #$aa
	sta $d000
	cmp $d040
	bne @dtv2
@c64:
	clc
	rts
@dtv2:
	lda #$4c			; redirect to dtv2 routines
	sta loader_send
	sta loader_recv
	ldax #dtv2_send
	stax loader_send + 1
	ldax #dtv2_recv
	stax loader_recv + 1

	lda #$20			; disable vic badlines
	sta $d03c

	lda #$4c			; disable loader badline checks
	sta loader_send_waitbadline
	sta loader_recv_waitbadline
	ldax #loader_send_waitbadline + 11
	stax loader_send_waitbadline + 1
	ldax #loader_recv_waitbadline + 11
	stax loader_recv_waitbadline + 1

	sec
	rts


; check if d71 or d64 is in 1571 drive
check1571disk:
	lda loader_drivetype
	cmp #drivetype_1571
	beq :+
	rts
:
	lda #18				; track 18
	ldx #$0c
	ldy #$00
	jsr drivepoke

	lda #0				; sector 0
	ldx #$0d
	ldy #$00
	jsr drivepoke

	lda #$80			; read sector job code
	ldx #$03
	ldy #$00
	jsr drivepoke

:	jsr drivepeek			; wait for job status
	bmi :-

	beq @gotsector
	cmp #1
	beq @gotsector
	sec
	rts

@gotsector:
	ldx #$03			; read 4th byte
	ldy #$06
	jsr drivepeek

	bmi @doublesided		; $80 means we have a double sided 1571 disk

	ldax #__DRIVE1541_LOAD__	; no, send 1541 code instead
	stax code_ptr
	clc
	rts


@doublesided:
	lda $ba				; set drive to listen
	jsr LISTEN
	lda #$6f			; channel 15
	jsr SECOND

	ldx #0				; send U0>M1 to switch to 1571 mode
:	lda u0m1,x
	jsr CIOUT
	inx
	cpx #5
	bne :-

	jsr UNLSN
	sec
	rts


drivepoke:
	stx cmd_addr
	sty cmd_addr + 1
	sta cmd_data

	lda #'w'
	sta cmd_type
	lda #1
	sta cmd_len
	ldax #cmd_data
	stax code_ptr
	jsr send_cmd

	ldx cmd_addr
	ldy cmd_addr + 1
	lda cmd_data

	rts


drivepeek:
	stx cmd_addr
	sty cmd_addr + 1
	sta cmd_data

	lda #'r'
	sta cmd_type
	lda #1
	sta cmd_len
	ldax #cmd_data
	stax code_ptr
	jsr send_cmd

	lda $ba
	jsr TALK
	lda #$6f
	jsr TKSA
	jsr ACPTR
	pha
	jsr UNTLK

	ldx cmd_addr
	ldy cmd_addr + 1
	pla

	rts


; send code, 32 bytes at a time
sendcode:
	lda #'w'			; M-W
	sta cmd_type
@next:
	lda #cmdbytes			; at least 32 bytes left?
	sta cmd_len
	lda code_len + 1
	bne @send
	lda code_len
	cmp #cmdbytes
	bcs @send
	beq @done
	sta cmd_len			; no, just send the rest
@send:
	jsr send_cmd			; send M-W command

	ldax cmd_addr
	jsr addlen
	stax cmd_addr

	ldax code_ptr
	jsr addlen
	stax code_ptr

	lda code_len
	sec
	sbc cmd_len
	sta code_len
	bcs :+
	dec code_len + 1
:	ora code_len + 1
	bne @next
@done:
	rts


addlen:
	clc
	adc cmd_len
	bcc :+
	inx
:	rts


send_cmd:
	lda $ba				; set drive to listen
	jsr LISTEN
	lda #$6f			; channel 15
	jsr SECOND

	ldx #0				; send M-W or M-E command and address
:	lda cmd,x
	jsr CIOUT
	inx
	cpx #5
	bne :-

	lda cmd_type			; exec
	cmp #'e'
	beq @done

	lda cmd_len			; length of data
	jsr CIOUT

	lda cmd_type			; read
	cmp #'r'
	beq @done

	ldy #0				; send the data
:	lda (code_ptr),y
	jsr CIOUT
	iny
	cpy cmd_len
	bne :-
@done:
	jmp UNLSN			; unlisten executes the command


strout:
	stax @ptr
@ptr = * + 1
:	lda $5e1f
	beq @done
	jsr $ffd2
	inc @ptr
	bne :-
	inc @ptr + 1
	bne :-
@done:
	rts


	.rodata

str_pal:
	.byte "pal", 0

str_ntsc:
	.byte "ntsc", 0

str_c64:
	.byte " c64", 0

str_c128:
	.byte " c128", 0

str_dtv2:
	.byte " dtv2", 0

str_scpu:
	.byte " supercpu v", 0

str_dev:
	.byte " #", 0

str_drive:
	.addr str_unknown
	.addr str_1541
	.addr str_1570
	.addr str_1571
	.addr str_1581
	.addr str_cmdfd
	.addr str_cmdhd
	.addr str_ramlink
	.addr str_unknown

str_unknown:
	.byte "unknown drive!", 0

str_1541:
	.byte "1541", 0

str_1570:
	.byte "1570", 0

str_1571:
	.byte "1571", 0

str_1581:
	.byte "1581", 0

str_cmdfd:
	.byte "cmd fd", 0

str_cmdhd:
	.byte "cmd hd", 0

str_ramlink:
	.byte "ramlink - unsupported!", 0
