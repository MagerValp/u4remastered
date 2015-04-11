#include <stdio.h>
#include <conio.h>
#include "easyapi.h"
#include "util.h"
#include "starteditor.h"
#include "monitor.h"
#include "backup.h"


#define DEV_X 20
#define DEV_Y 18


static void print_device(uint8_t device) {
    cclearxy(DEV_X, DEV_Y, 3);
    gotoxy(DEV_X, DEV_Y);
    textcolor(COLOR_WHITE);
    cprintf("%d", device);
}


static uint8_t select_device(void) {
    uint8_t device = 0;
    uint8_t input_len = 0;
    char c;
    
    for (;;) {
        if (input_len) {
            print_device(device);
        } else {
            cclearxy(DEV_X, DEV_Y, 3);
            gotoxy(DEV_X, DEV_Y);
        }
        
        cursor(1);
        c = cgetc();
        cursor(0);
        
        if (c == CH_ENTER) {
            if (device >= 4 && device <= 30) {
                return device;
            }
        } else if (c == CH_DEL && input_len > 0) {
            device /= 10;
            --input_len;
        } else if (c >= '0' && c <= '9' && input_len < 2) {
            device = device * 10 + c - '0';
            ++input_len;
        }
    }
}


static char save_filename_buf[4];

static char *save_filename(uint8_t filenum) {
    sprintf(save_filename_buf, "s%02x", filenum);
    return save_filename_buf;
}


static uint8_t save_filenum[4] = {
    0x1a, 0x7e, 0x7f, 0x80
};

static uint16_t save_addr[4] = {
    0x0010, 0xac00, 0xac00, 0xaa00
};

static uint8_t file_buf[512];


static void backup_to_disk(uint8_t device) {
    uint8_t i;
    uint8_t filenum;
    uint16_t length;
    
    clear_menu();
    for (i = 0; i < sizeof(save_filenum); ++i) {
        filenum = save_filenum[i];
        
        textcolor(COLOR_WHITE);
        cprintf("Backing up \"s%02x\"... ", filenum);
        
        if ((length = flash_load_file(filenum, file_buf)) == 0) {
            textcolor(COLOR_LIGHTRED);
            cputs("not found!\r\n");
            break;
        }
        
        if (disk_save_file(device, save_filename(filenum), save_addr[i], file_buf, length)) {
            textcolor(COLOR_LIGHTGREEN);
            cputs("OK\r\n");
        } else {
            textcolor(COLOR_LIGHTRED);
            cputs("failed!\r\n");
            break;
        }
    }
    
    cputs("\r\n");
    menu_option(0x5f, "Back to menu");
    while (cgetc() != 0x5f);
}


static void restore_from_disk(uint8_t device) {
    uint8_t i;
    uint8_t filenum;
    uint16_t length;
    uint16_t loadaddr;
    
    clear_menu();
    for (i = 0; i < sizeof(save_filenum); ++i) {
        filenum = save_filenum[i];
        
        textcolor(COLOR_WHITE);
        cprintf("Restoring \"s%02x\"... ", filenum);
        
        if ((length = disk_load_file(device, save_filename(filenum), &loadaddr, file_buf)) == 0) {
            textcolor(COLOR_LIGHTRED);
            cputs("failed!\r\n");
            break;
        }
        
        if (flash_save_file(filenum, file_buf, length)) {
            textcolor(COLOR_LIGHTGREEN);
            cputs("OK\r\n");
        } else {
            textcolor(COLOR_LIGHTRED);
            cputs("failed!\r\n");
            break;
        }
    }
    
    cputs("\r\n");
    menu_option(0x5f, "Back to menu");
    while (cgetc() != 0x5f);
}


static void erase(void) {
    uint8_t error = 0;
    
    clear_menu();
    textcolor(COLOR_WHITE);
    cputs("\r\n\r\n            Erasing...");
    if (erase_flash()) {
        textcolor(COLOR_LIGHTGREEN);
        cputs(" OK");
    } else {
        textcolor(COLOR_LIGHTRED);
        cputs(" Failed!");
    }
    cputs("\r\n\r\n\r\n");
    menu_option(0x5f, "Back to menu");
    while (cgetc() != 0x5f);
}


#define SURE_X 24
#define SURE_Y 21

static bool sure(void) {
    char c;
    
    textcolor(COLOR_YELLOW);
    cputsxy(SURE_X, SURE_Y, ". Sure? ");
    textcolor(COLOR_WHITE);
    cursor(1);
    c = cgetc();
    cursor(0);
    cclearxy(SURE_X, SURE_Y, 10);
    return c == 'y';
}


void backup(void) {
    static bool repaint;
    static uint8_t device = 8;
    
    repaint = true;
    for (;;) {

        if (repaint) {
            clear_menu();
            menu_option('D', "Device #");
            menu_option('B', "Backup flash to disk");
            menu_option('R', "Restore flash from disk");
            menu_option('F', "Format flash");
            menu_option('E', "Edit savegame");
            cputs("\r\n");
            menu_option(0x5f, "Back to main menu");
            print_device(device);
        }
        
        repaint = false;
        
        switch (cgetc()) {
        case 'd':
            device = select_device();
            break;
        
        case 'b':
            backup_to_disk(device);
            repaint = true;
            break;
        
        case 'r':
            restore_from_disk(device);
            repaint = true;
            break;
        
        case 'f':
            if (sure()) {
                erase();
                repaint = true;
            }
            break;
        
        case 'e':
            starteditor();
            return;
        
        case 'M':
            monitor();
            repaint = true;
            break;
        
        case 0x5f:
            return;
        }
    }
}
