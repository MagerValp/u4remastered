#include <stdint.h>
#include <conio.h>
#include "util.h"
#include "easyapi.h"
#include "monitor.h"


static char hexchar[] = {
    '0', '1', '2', '3',
    '4', '5', '6', '7',
    '8', '9', 'a', 'b',
    'c', 'd', 'e', 'f'
};


static void hexdump_page(uint8_t bank, uint8_t page) {
    static uint16_t addr;
    static uint8_t x, y;
    static uint8_t byte;
    
    easyapi_set_bank(bank);
    
    addr = ((page | 0x80) << 8);
    easyapi_set_ptr(MODE_ALTERNATE, (void *)addr);
    
    gotoxy(0, 0);
    textcolor(COLOR_YELLOW);
    cprintf("%02x:%d:%02x00", bank, page >> 5, page & 0x1f);
    
    for (y = 0; y < 16; ++y) {
        gotoxy(0, y + 1);
        textcolor(COLOR_YELLOW);
        cputc(hexchar[(page >> 4) | 0x08]);
        cputc(hexchar[page & 0x0f]);
        cputc(hexchar[y]);
        cputs("0  ");
        for (x = 0; x < 8; ++x) {
            textcolor(COLOR_WHITE);
            byte = easyapi_read_flash_inc();
            cputc(hexchar[byte >> 4]);
            cputc(hexchar[byte & 0x0f]);
            textcolor(COLOR_GRAY3);
            byte = easyapi_read_flash_inc();
            cputc(hexchar[byte >> 4]);
            cputc(hexchar[byte & 0x0f]);
        }
    }
}


static void menu_option_str(char *key, char *desc) {
    textcolor(COLOR_CYAN);
    cputs("       (");
    textcolor(COLOR_WHITE);
    cputs(key);
    textcolor(COLOR_CYAN);
    cputs(")  ");
    textcolor(COLOR_YELLOW);
    cprintf("%s\r\n", desc);
}


static void hexdump(void) {
    static uint8_t bank = 0;
    static uint8_t page = 0;
    
    clrscr();
    
    clear_menu();
    menu_option_str("F1/UP", "Bank -");
    menu_option_str("F3/LT", "Page -");
    menu_option_str("F5/RT", "Page +");
    menu_option_str("F7/DN", "Bank +");
    cputs("\r\n");
    menu_option(0x5f, "Back to monitor menu");
        
    
    for (;;) {

        hexdump_page(bank, page);
        switch (cgetc()) {
        
        case CH_F1:
        case CH_CURS_UP:
            bank = (bank - 1) & 0x3f;
            break;
        
        case CH_F3:
        case CH_CURS_LEFT:
            page = (page - 1) & 0x3f;
            break;
        
        case CH_F5:
        case CH_CURS_RIGHT:
            page = (page + 1) & 0x3f;
            break;
        
        case CH_F7:
        case CH_CURS_DOWN:
            bank = (bank + 1) & 0x3f;
            break;
        
        case 0x5f:
            clrscr();
            return;
        }
    }
}


static void filedump(void) {
    static uint8_t bank;
    static uint16_t addr;
    static uint8_t byte;
    static uint16_t size;
    static uint8_t line;
    
    clrscr();
    
    bank = 0x30;
    addr = 0x8000;
    
    line = 0;
    
    for (;;) {
        while (addr >= 0xa000 || addr < 0x8000) {
            ++bank;
            addr -= 0x2000;
        }
        
        gotoxy(0, line);
        textcolor(COLOR_YELLOW);
        cprintf("%02x:%04x  ", bank, addr);
        
        if (bank < 0x30 || bank > 0x3f) {
            textcolor(COLOR_LIGHTRED);
            cputs("bank overflow");
            break;
        }
        
        textcolor(COLOR_WHITE);
        
        easyapi_set_bank(bank);
        easyapi_set_ptr(MODE_LO, (void *)addr);
        
        byte = easyapi_read_flash_inc();
        
        if (byte == 0xff) {
            cputs("Free space");
            for (size = 0; size < 0x042f; ++size) {
                if (easyapi_read_flash_inc() != 0xff) {
                    textcolor(COLOR_LIGHTRED);
                    cputs(" < $430 bytes!");
                    break;
                }
            }
            break;
        }
        
        if (byte == 0) {
            cputs("DEL, ");
        } else {
            cprintf("File %02x, ", byte);
        }
        
        byte = easyapi_read_flash_inc();
        if (byte != 0xff) {
            textcolor(COLOR_LIGHTRED);
            cputs("reserved byte not $ff");
            break;
        }
        
        size = easyapi_read_flash_inc();
        size |= easyapi_read_flash_inc() << 8;
        cprintf("$%04x bytes", size);
        
        addr += size + 4;
        
        if (++line > 22) {
            textcolor(COLOR_CYAN);
            cputsxy(0, 24, "Any key for next page");
            cgetc();
            clrscr();
            line = 0;
        }
    }

    textcolor(COLOR_CYAN);
    cputsxy(0, 24, "Any key to return");
    cgetc();
    clrscr();
}


#define SEC_X 24
#define SEC_Y 20


static void clear_sector(void) {
    cclearxy(SEC_X + 3, SEC_Y, 3);
    gotoxy(SEC_X + 3, SEC_Y);
}

static void print_sector(uint8_t sector) {
    clear_sector();
    textcolor(COLOR_WHITE);
    cprintf("%x", sector);
}


static uint8_t select_sector(void) {
    uint8_t sector = 0;
    uint8_t input_len = 0;
    char c;
    
    textcolor(COLOR_YELLOW);
    cputsxy(SEC_X, SEC_Y, ": ");
    textcolor(COLOR_WHITE);
    cputc('$');
    
    for (;;) {
        if (input_len) {
            print_sector(sector);
        } else {
            clear_sector();
        }
        
        cursor(1);
        c = cgetc();
        cursor(0);
        
        if (c == CH_STOP) {
            return 0xff;
        } else if (c == CH_ENTER) {
            if (sector <= 0x3f && (sector & 7) == 0) {
                return sector;
            }
        } else if (c == CH_DEL && input_len > 0) {
            sector /= 16;
            --input_len;
        } else if (input_len < 2) {
            if (c >= '0' && c <= '9') {
                sector = sector * 16 + c - '0';
                ++input_len;
            } else if (c >= 'a' && c <= 'f') {
                sector = sector * 16 + c - 'a' + 10;
                ++input_len;
            }
        }
    }
}


static void erase_sector(uint8_t sector) {
    clrscr();
    textcolor(COLOR_WHITE);
    gotoxy(0, 10);
    cprintf("Erasing sector $%02x...", sector);
    if (easyapi_erase_sector(ERASE_ROML, sector)) {
        textcolor(COLOR_LIGHTGREEN);
        cputs(" OK");
    } else {
        textcolor(COLOR_LIGHTRED);
        cputs(" Failed!");
    }
    cgetc();
    clrscr();
}


static void print_eapi_version(void) {
    static char c;
    
    easyapi_set_bank(0);
    easyapi_set_ptr(MODE_HI, (void *)0xb800);
    
    if (easyapi_read_flash_inc() == 0x65 &&
        easyapi_read_flash_inc() == 0x61 &&
        easyapi_read_flash_inc() == 0x70 &&
        easyapi_read_flash_inc() == 0x69) {
        textcolor(COLOR_WHITE);
        cputsxy(0, 24, "EasyAPI version: ");
        while ((c = easyapi_read_flash_inc())) {
            cputc(c);
        }
    } else {
        textcolor(COLOR_LIGHTRED);
        cputsxy(0, 24, "EasyAPI not found!");
    }
}


void monitor(void) {
    static bool repaint;
    static uint8_t sector;
    
    repaint = true;
    for (;;) {

        if (repaint) {
            clear_menu();
            menu_option('X', "Hex dump");
            menu_option('F', "Show file structure");
            menu_option('E', "Erase sector");
            cputs("\r\n");
            menu_option(0x5f, "Back to main menu");
            print_eapi_version();
        }
        
        repaint = false;
        
        switch (cgetc()) {
        
        case 'x':
            hexdump();
            repaint = true;
            break;
        
        case 'f':
            filedump();
            repaint = true;
            break;
        
        case 'e':
            sector = select_sector();
            if (sector != 0xff) {
                erase_sector(sector);
            }
            repaint = true;
            break;
        
        case 0x5f:
            clrscr();
            return;
        }
    }
}
