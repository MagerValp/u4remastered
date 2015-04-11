	.include "u4loader.i"


	.exportzp aptr
	.exportzp currdisk

	.export u4loader_fileaddr
	.export u4loader_blocknum
	.export u4loader_filenum
	.export u4loader_iodone

	.export sndvolume

	.export filemap_lo
	.export filemap_hi


	.import u4loader_run
	.import u4loader_load
	.import u4loader_save
	.import u4loader_readblock

	.import prg_filemap
	.import bri_filemap
	.import tow_filemap
	.import und_filemap

	.import u4loader_load_tempmap
	.import u4loader_save_tempmap
	.import u4loader_init_tempmap_cache
	.import u4loader_flush_tempmap_cache
	.import u4loader_quit_save_tempmap


aptr		= $0e
currdisk	= $51


	.segment "LOADERA000"

rwflag:			.res 1
blkcount:		.res 1
u4loader_fileaddr:	.res 2
u4loader_blocknum:	.res 2

jobcode:		.res 1
u4loader_filenum:	.res 1
ysave:			.res 1


kernalin:
	sei	        ; bank in kernal
	lda #$36
	sta $01
	cli
	rts

hardirq:
	pha	        ; hardware IRQ handler
	txa
	pha
	tsx	        ; get stack pointer
	inx
	inx
	inx
	lda $0100,x     ; get saved status register
	tax
	lda #>irqreturn	; push a6b3 as the return address
	pha
	lda #<irqreturn
	pha
	txa
	pha
	jmp (irqvect)   ; jump to IRQ handler (a6ac)

irqhandler:
	lda #$36        ; bank in kernal
	sta $01
	jmp ($fffe)     ; jump to kernal IRQ handler

irqreturn:
	lda #$35        ; bank out kernal
	sta $01
	pla	        ; return
	tax
	pla
	rti


; toggle sound output

togglesnd:
	pha
	lda sndvolume 
	eor #$0f
	sta sndvolume 
	sta $d418
	pla
	rts

sndvolume:
	.byte $a5		; SID volume


	.segment "LOADER"

	.assert * = $a100, error, "loader must start at $a100"

	jmp u4loader_fileio
	jmp u4loader_readblock
	jmp *
	jmp togglesnd	; toggle sound output
	jmp kernalin	; bank in kernal
	jmp setirqv
	jmp clearkbd	; clear keyboard queue
	jmp irqhandler	; IRQ handler
	jmp u4loader_init_tempmap_cache
	jmp u4loader_flush_tempmap_cache
	jmp u4loader_quit_save_tempmap

irqvect		= j_irqhandler + 1


; clear keyboard queue

clearkbd:
	pha			; clear keyboard queue
	lda #0
	sta $c6
	pla
	rts


setirqv:
	sei	        ; set IRQ vectors
	lda #<hardirq   ; set hardware IRQ vector to a696
	sta $fffe
	lda #>hardirq
	sta $ffff
	lda #<hardnmi   ; set hardware NMI vector to a6bb
	sta $fffa
	lda #>hardnmi
	sta $fffb
kernalout:
	lda #$35        ; bank out kernal
	sta $01
	cli
	rts

hardnmi:
	pha	        ; hardware NMI handler
	txa
	pha
	tsx	        ; get stack pointer
	inx
	inx
	inx
	lda $0100,x     ; get saved status register
	tax
	lda #>nmireturn	; push a6d5 as the NMI return address
	pha	        ; test
	lda #<nmireturn	; test
	pha
	txa	        ; push status register
	pha
	lda #$36        ; bank in kernal
	sta $01
	jmp ($fffa)     ; jump to kernal NMI handler

nmireturn:
	lda #$35        ; bank out kernal
	sta $01
	pla	        ; return
	tax
	pla
	rti


; handle file run/load/save request

filemap_lo:
	.byte <prg_filemap
	.byte <bri_filemap
	.byte <tow_filemap
	.byte <und_filemap

filemap_hi:
	.byte >prg_filemap
	.byte >bri_filemap
	.byte >tow_filemap
	.byte >und_filemap

u4loader_fileio:
	sta jobcode
	stx u4loader_filenum
	sty ysave

	cpx #$7e
	beq tempmap

	.ifdef DEBUGFILE
	jsr debugfile
	.endif

	cmp #$d2		; (R)un
	bne :+
	jmp u4loader_run
:
	cmp #$cc		; (L)oad
	bne :+
	jmp u4loader_load
:
	cmp #$d3		; (S)ave
	bne :+
	jmp u4loader_save
:
	sec
u4loader_iodone:
	lda #0
	sta $d020
	lda jobcode		; restore registers and return
	ldx u4loader_filenum
	ldy ysave
	rts

tempmap:
	cmp #$cc
	beq @load
@save:
	jsr u4loader_save_tempmap
	clc
	jmp u4loader_iodone
@load:
	jsr u4loader_load_tempmap
	clc
	jmp u4loader_iodone
