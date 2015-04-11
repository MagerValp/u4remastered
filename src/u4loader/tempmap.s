	.include "u4loader.i"


	.export u4loader_load_tempmap
	.export u4loader_save_tempmap
	.export u4loader_init_tempmap_cache
	.export u4loader_flush_tempmap_cache
	.export u4loader_quit_save_tempmap


	.import u4loader_load
	.import u4loader_save
	.import u4loader_filenum


tempmap_filenum	= $7e


	.segment "LOADER"

; Load tempmap from ram cache.
u4loader_load_tempmap:
	ldx #0
	sei
	dec $01
:	lda tempmap,x
	sta $ac00,x
	inx
	bne :-
return:
	inc $01
	cli
	rts

; Save tempmap to ram cache.
u4loader_save_tempmap:
	ldx #0
	sei
	dec $01
:	lda $ac00,x
	sta tempmap,x
	inx
	bne :-
	beq return

; Swap tempmap and cache buffers.
u4loader_swap_tempmap:
	ldx #0
	sei
	dec $01
:	lda $ac00,x
	tay
	lda tempmap,x
	sta $ac00,x
	tya
	sta tempmap,x
	inx
	bne :-
	beq return

; Read cache from disk.
u4loader_init_tempmap_cache:
	lda #tempmap_filenum
	sta u4loader_filenum
	jsr u4loader_load
	jmp u4loader_save_tempmap

; Patch quit and save command.
u4loader_quit_save_tempmap:
	jsr j_fileio
	;jmp u4loader_flush_tempmap_cache

; Write cache to disk.
u4loader_flush_tempmap_cache:
	jsr u4loader_swap_tempmap
	lda #tempmap_filenum
	sta u4loader_filenum
	jsr u4loader_save
	jsr u4loader_swap_tempmap
	lda #$d3
	rts


	.segment "TEMPMAP"

tempmap:	.res $100
