#include <stdbool.h>
#include <stdio.h>
#include <conio.h>
#include "easyapi.h"
#include "util.h"


bool erase_flash(void) {
    if (!easyapi_erase_sector(ERASE_ROML, 0x30)) { return false; }
    if (!easyapi_erase_sector(ERASE_ROML, 0x38)) { return false; }
    return true;
}


uint16_t flash_load_file(uint8_t filenum, uint8_t *buffer) {
    uint8_t byte;
    uint16_t length;
    uint16_t count;
    
    easyapi_set_bank(0x30);
    easyapi_set_ptr(MODE_LO, (void *)0x8000);
    
    for (;;) {
        if (easyapi_get_bank() < 0x30 || easyapi_get_bank() > 0x3f) {
            return 0;
        }
        byte = easyapi_read_flash_inc();
        if (byte == filenum) {
            easyapi_read_flash_inc();
            length = easyapi_read_flash_inc();
            length |= (easyapi_read_flash_inc() << 8);
            count = length;
            while (count) {
                *buffer = easyapi_read_flash_inc();
                ++buffer;
                --count;
            }
            return length;
        } else if (byte == 0xff) {
            return 0;
        } else {
            easyapi_read_flash_inc();
            length = easyapi_read_flash_inc();
            length |= (easyapi_read_flash_inc() << 8);
            while (length) {
                easyapi_read_flash_inc();
                --length;
            }
        }
    }
}


bool flash_save_file(uint8_t filenum, uint8_t *buffer, uint16_t length) {
    uint8_t bank = 0x30;
    uint16_t addr = 0x8000;
    uint8_t byte;
    uint16_t i;
    
    for (;;) {
        while (addr >= 0xa000 || addr < 0x8000) {
            ++bank;
            addr -= 0x2000;
        }
        
        // FIXME: Don't write to last bank as the code doesn't handle
        //        bank full scenario.
        if (bank < 0x30 || bank > 0x3e) {
            return false;
        }
        
        easyapi_set_bank(bank);
        easyapi_set_ptr(MODE_LO, (void *)addr);
        
        byte = easyapi_read_flash_inc();
        if (byte == filenum) {
            easyapi_set_bank(bank);
            easyapi_set_ptr(MODE_LO, (void *)addr);
            if (!easyapi_write_flash_inc(0)) {
                return false;
            }
        } else if (byte == 0xff) {
            easyapi_set_bank(bank);
            easyapi_set_ptr(MODE_LO, (void *)addr);
            easyapi_write_flash_inc(filenum);
            easyapi_write_flash_inc(0xff);
            easyapi_write_flash_inc(length & 0xff);
            easyapi_write_flash_inc(length >> 8);
            for (i = 0; i < length; ++i) {
                if (!easyapi_write_flash_inc(*buffer)) {
                    return false;
                }
                ++buffer;
            }
            return true;
        }
        easyapi_read_flash_inc();
        i = easyapi_read_flash_inc();
        i |= easyapi_read_flash_inc() << 8;
        addr += i + 4;
    }
}


uint16_t disk_load_file(uint8_t device, char *filename, uint16_t *loadaddr, unsigned char *buffer) {
    uint16_t length = 0;
    int result;
    
    if (cbm_open(1, device, 2, filename)) {
        return 0;
    }
    
    if (cbm_read(1, loadaddr, 2) != 2) {
        cbm_close(1);
        return 0;
    }
    
    while ((result = cbm_read(1, &buffer[length], 512)) > 0) {
        length += result;
    }
    cbm_close(1);
    return length;
}


bool disk_save_file(uint8_t device, char *filename, uint16_t loadaddr, unsigned char *buffer, uint16_t length) {
    char namebuf[32];
    
    sprintf(namebuf, "s0:%s", filename);
    cbm_open(1, device, 15, namebuf);
    cbm_close(1);
    
    sprintf(namebuf, "%s,w,p", filename);
    if (cbm_open(1, device, 2, namebuf)) {
        return false;
    }
    
    if (cbm_write(1, &loadaddr, 2) != 2) {
        cbm_close(1);
        return false;
    }
    
    if (cbm_write(1, buffer, length) != length) {
        cbm_close(1);
        return false;
    }
    
    cbm_close(1);
    return true;
}


void menu_option(char key, char *desc) {
    textcolor(COLOR_CYAN);
    cputs("       (");
    textcolor(COLOR_WHITE);
    cputc(key);
    textcolor(COLOR_CYAN);
    cputs(")  ");
    textcolor(COLOR_YELLOW);
    cprintf("%s\r\n", desc);
}


void clear_menu(void) {
    uint8_t y;
    
    for (y = 18; y < 25; ++y) {
        cclearxy(0, y, 40);
    }
    gotoxy(0, 18);
}


void cart_16k(void) {
    __asm__("lda #7");
    __asm__("sta $de02");
}


void cart_kill(void) {
    __asm__("lda #4");
    __asm__("sta $de02");
}


void __fastcall__ cart_bank(uint8_t bank) {
    __asm__("sta $de00");
    (void)bank;
}
