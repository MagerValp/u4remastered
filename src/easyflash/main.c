#include <stdbool.h>
#include <conio.h>
#include <peekpoke.h>
#include "easyapi.h"
#include "util.h"
#include "startgame.h"
#include "backup.h"


static void draw_game_info(void) {
    clrscr();
    textcolor(COLOR_CYAN);
    cputs("             Origin Systems\r\n"
          "           and Genesis Project\r\n"
          "            proudly presents\r\n"
          "\r\n");
    textcolor(COLOR_WHITE);
    cputs("     Ultima IV: Quest of the Avatar\r\n"
          "\r\n"
          "        Designed by Lord British\r\n"
          "\r\n");
    textcolor(COLOR_CYAN);
    cputs("  Commodore 64 conversion by  Chuckles\r\n"
          "  Music composed by  Kenneth W. Arnold\r\n"
          "     EasyFlash version by MagerValp\r\n"
          "       Graphics remade by Mermaid\r\n"
          "\r\n"
          " Copyright (c) 1985 Origin Systems, inc.");
}


void main(void) {
    static bool repaint;
    
    repaint = true;
    bgcolor(COLOR_BLUE);
    bordercolor(COLOR_BLUE);
    draw_game_info();
    
    POKE(1, 0x37);
    cart_16k();
    easyapi_init();
    
    while (kbhit()) {
        cgetc();
    }
    
    for (;;) {
        
        if (repaint) {
            clear_menu();
            menu_option('G', "Start game");
            cputs("\r\n");
            menu_option('S', "Manage saves");
            cputs("\r\n");
            menu_option('Q', "Quit to basic");
        }
        
        repaint = false;
        
        switch (cgetc()) {
        case ' ':
        case 'g':
            startgame();
            return;
        
        case 's':
            backup();
            repaint = true;
            break;
        
        case 'q':
            cart_kill();
            __asm__("lda #$37");
            __asm__("sta $01");
            __asm__("ldx #$ff");
            __asm__("txs");
            __asm__("jmp $fcfb");
            break;
        }
    }
}
