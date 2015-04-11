#include <conio.h>
#include <string.h>
#include <peekpoke.h>
#include "fileio.h"
#include "edit.h"
#include "draw.h"


void main(void) {
    unsigned char c;

    POKE(1, 0x37);

    if (dev != DEV_FLASH) {
        dev = PEEK(0xba);
        if (dev == 0) {
            dev = 8;
        }
    }

    POKE(0xd020, 12);
    POKE(0xd021, 0);
    textcolor(COLOR_GRAY2);
    clrscr();

    memset((unsigned char *) 0x0450, 0xa0, 0x0398);
    memset((unsigned char *) 0x0428, 0xf7, 40);
    memset((unsigned char *) 0xd828, 12, 0x03c0);

    textcolor(COLOR_WHITE);
    revers(1);
    cputs(" Ultima IV Save Game Editor v1.1        ");

    while (loadgame() == 0) {
        cputsxy(5, 11, "                              ");
        cputsxy(5, 13, "                              ");
        if (dev == DEV_FLASH) {
            cputsxy(5, 12, "  No savegame found in flash  ");
            while (kbhit()) {
                cgetc();
            }
            cgetc();
            goto quit;
        }
        textcolor(COLOR_WHITE);
        cputsxy(5, 12, " Insert play disk into dev #");
        cprintf("%d ", dev);
        memset((unsigned char *) 0x0635, 0xf7, 30);
        c = cgetc();
        if (c == 'q' || c == CH_STOP) {
            goto quit;
        }
        textcolor(COLOR_GRAY2);
        memset((unsigned char *) 0x05bd, 0xa0, 160);
        memset((unsigned char *) 0xd9bd, 12, 160);
    }
    draw_all();
    edit();

quit:
    if (dev == DEV_FLASH) {
        POKE(0xde00, 0x00);
        POKE(0xde02, 0x07);
        __asm__("jmp $8000");
    }
    revers(0);
    textcolor(COLOR_LIGHTBLUE);
    clrscr();
    POKE(0xd018, 0x15);
    POKE(0x028a, 0);
    POKE(0xd020, 14);
    POKE(0xd021, 6);
}
