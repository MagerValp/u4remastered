#ifndef __EASYAPI_H__
#define __EASYAPI_H__


#include <stdbool.h>
#include <stdint.h>


typedef enum {
    ERASE_ROML = 0x80,
    ERASE_ROMH = 0xe0
} erase_bank_t;

typedef enum {
    MODE_ALTERNATE = 0xd0,
    MODE_LO = 0xb0,
    MODE_HI = 0xd4
} bank_mode_t;

extern bool easyapi_eof;


void __fastcall__ easyapi_init(void);
bool __fastcall__ easyapi_write_flash(uint8_t value, void *addr);
bool __fastcall__ easyapi_erase_sector(uint8_t baseaddr, uint8_t bank);
void __fastcall__ easyapi_set_bank(uint8_t bank);
uint8_t __fastcall__ easyapi_get_bank(void);
void __fastcall__ easyapi_set_ptr(uint8_t mode, void *addr);
void __fastcall__ easyapi_set_len(uint8_t hi, uint16_t lo);
uint8_t __fastcall__ easyapi_read_flash_inc(void);
bool __fastcall__ easyapi_write_flash_inc(uint8_t value);
void __fastcall__ easyapi_set_slot(uint8_t slot);


#endif
