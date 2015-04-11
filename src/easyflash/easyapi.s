	.include "macro.i"
	.include "easyflash.i"


	.export _easyapi_init
	.export _easyapi_write_flash
	.export _easyapi_erase_sector
	.export _easyapi_set_bank
	.export _easyapi_get_bank
	.export _easyapi_set_ptr
	.export _easyapi_read_flash_inc
	.export _easyapi_write_flash_inc

	.export _easyapi_eof

	.import EAPIInit

	.import __EASYAPI_LOAD__
	.import __EASYAPI_RUN__
	.import __EASYAPI_SIZE__

	.import _memcpy, pushax, popa
	.importzp ptr1


	.data

eapi_bank:	.byte 0
_easyapi_eof:	.byte 0


	.code

; void __fastcall__ easyapi_init(void);
_easyapi_init:
	ldax #__EASYAPI_RUN__
	jsr pushax
	ldax #__EASYAPI_LOAD__
	jsr pushax
	ldax #__EASYAPI_SIZE__
	jsr _memcpy

	jmp EAPIInit


; bool __fastcall__ easyapi_write_flash(uint8_t value, void *addr);
_easyapi_write_flash:
	stax ptr1
	lda eapi_bank
	sta ef_bank
	jsr popa
	ldx ptr1
	ldy ptr1 + 1
	jsr EAPIWriteFlash
return_error:
	ldx #0
	txa
	bcs @error
	lda #1
@error:
	rts
	

; bool __fastcall__ easyapi_erase_sector(erase_bank_t baseaddr, uint8_t bank);
_easyapi_erase_sector:
	pha
	jsr popa
	tay
	pla
	jsr EAPIEraseSector
	jmp return_error


; void __fastcall__ easyapi_set_bank(uint8_t bank);
_easyapi_set_bank	=  EAPISetBank


; uint8_t __fastcall__ easyapi_get_bank(void);
_easyapi_get_bank:
	jsr EAPIGetBank
return_a:
	ldx #0
	rts


; void __fastcall__ easyapi_set_ptr(bank_mode_t mode, void *addr);
_easyapi_set_ptr:
	stax ptr1
	jsr popa
	ldx ptr1
	ldy ptr1 + 1
	jmp EAPISetPtr


; void __fastcall__ easyapi_set_len(uint8_t hi, uint16_t lo);

; uint8_t __fastcall__ easyapi_read_flash_inc(void);
_easyapi_read_flash_inc:
	jsr EAPIReadFlashInc
	tay
	lda #0
	rol
	sta _easyapi_eof
	tya
	jmp return_a


; bool __fastcall__ easyapi_write_flash_inc(uint8_t value);
_easyapi_write_flash_inc:
	jsr EAPIWriteFlashInc
	jmp return_error


; void __fastcall__ easyapi_set_slot(uint8_t slot);
