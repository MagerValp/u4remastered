#ifndef __UTIL_H__
#define __UTIL_H__


#include <stdbool.h>
#include <stdint.h>


bool erase_flash(void);
uint16_t flash_load_file(uint8_t filenum, uint8_t *buffer);
bool flash_save_file(uint8_t filenum, uint8_t *buffer, uint16_t length);
uint16_t disk_load_file(uint8_t device, char *filename, uint16_t *loadaddr, unsigned char *buffer);
bool disk_save_file(uint8_t device, char *filename, uint16_t loadaddr, unsigned char *buffer, uint16_t length);

void menu_option(char key, char *desc);
void clear_menu(void);

void cart_16k(void);
void cart_kill(void);
void __fastcall__ cart_bank(uint8_t bank);


#endif
