#include <stddef.h>
#include <conio.h>
#include <peekpoke.h>
#include "cursor.h"


highlight cursor_player_select[] = {
    { 0, 2, 16 },
    { 0, 3, 16 },
    { 0, 4, 16 },
    { 0, 5, 16 },
    { 0, 6, 16 },
    { 0, 7, 16 },
    { 0, 8, 16 },
    { 0, 9, 16 }
};

highlight cursor_player[] = {
    { 17, 2, 16 },
    { 17, 3, 1 },
    { 21, 3, 8 },
    { 32, 3, 1 },
    { 21, 4, 2 },
    { 28, 4, 1 },
    { 21, 5, 2 },
    { 28, 5, 4 },
    { 21, 6, 2 },
    { 21, 7, 2 },
    { 28, 7, 4 },
    { 19, 8, 12 },
    { 19, 9, 12 }
};

highlight cursor_party_size[] = {
    { 11, 11, 1 }
};

highlight cursor_consumables[] = {
    { 5, 13, 4 },
    { 5, 14, 4 }
};

highlight cursor_mixtures[] = {
    { 2, 17, 2 },
    { 2, 18, 2 },
    { 2, 19, 2 },
    { 2, 20, 2 },
    { 2, 21, 2 },
    { 2, 22, 2 },
    { 2, 23, 2 },
    { 2, 24, 2 },

    { 7, 16, 2 },
    { 7, 17, 2 },
    { 7, 18, 2 },
    { 7, 19, 2 },
    { 7, 20, 2 },
    { 7, 21, 2 },
    { 7, 22, 2 },
    { 7, 23, 2 },
    { 7, 24, 2 },

    { 12, 16, 2 },
    { 12, 17, 2 },
    { 12, 18, 2 },
    { 12, 19, 2 },
    { 12, 20, 2 },
    { 12, 21, 2 },
    { 12, 22, 2 },
    { 12, 23, 2 },
    { 12, 24, 2 }
};

highlight cursor_reagents[] = {
    { 19, 17, 2 },
    { 19, 18, 2 },
    { 19, 19, 2 },
    { 19, 20, 2 },
    { 19, 21, 2 },
    { 19, 22, 2 },
    { 19, 23, 2 },
    { 19, 24, 2 }
};

highlight cursor_virtues[] = {
    { 26, 17, 2 },
    { 26, 18, 2 },
    { 26, 19, 2 },
    { 26, 20, 2 },
    { 26, 21, 2 },
    { 26, 22, 2 },
    { 26, 23, 2 },
    { 26, 24, 2 }
};

highlight cursor_runes[] = {
    { 29, 17, 1 },
    { 29, 18, 1 },
    { 29, 19, 1 },
    { 29, 20, 1 },
    { 29, 21, 1 },
    { 29, 22, 1 },
    { 29, 23, 1 },
    { 29, 24, 1 }
};

highlight cursor_stones[] = {
    { 31, 17, 1 },
    { 31, 18, 1 },
    { 31, 19, 1 },
    { 31, 20, 1 },
    { 31, 21, 1 },
    { 31, 22, 1 },
    { 31, 23, 1 },
    { 31, 24, 1 }
};

highlight cursor_items[] = {
    { 38, 12, 2 },
    { 38, 13, 2 },
    { 38, 14, 2 },
    { 39, 15, 1 },
    { 39, 16, 1 },
    { 39, 17, 1 },
    { 39, 18, 1 },
    { 39, 19, 1 },
    { 39, 20, 1 },
    { 39, 21, 1 },
    { 39, 22, 1 },
    { 39, 23, 1 },
    { 39, 24, 1 }
};

highlight *cursor_list[] = {
    NULL,
    cursor_player_select,
    cursor_player,
    cursor_party_size,
    cursor_consumables,
    cursor_mixtures,
    cursor_reagents,
    cursor_virtues,
    cursor_runes,
    cursor_stones,
    cursor_items
};


void select(unsigned char focus, unsigned char pos) {
    unsigned char *scr;
    unsigned char l;

    /*
    gotoxy(36, 0);
    revers(1);
    textcolor(COLOR_LIGHTRED);
    cprintf("%d:%02d", focus, pos);
    revers(0);
    */
    gotoxy(cursor_list[focus][pos].x, cursor_list[focus][pos].y);
#ifdef __C64__
    scr = (unsigned char *) ((PEEK(0xd1) | (PEEK(0xd2) << 8)) + PEEK(0xd3));
#else
#ifdef __PLUS4__
    scr = (unsigned char *) ((PEEK(0xc8) | (PEEK(0xc9) << 8)) + PEEK(0xca));
#else
#error Unsupported target
#endif
#endif
    l = cursor_list[focus][pos].l;
    while (l) {
        *scr |= 0x80;
        ++scr;
        --l;
    }
}


void deselect(unsigned char focus, unsigned char pos) {
    unsigned char *scr;
    unsigned char l;

    gotoxy(cursor_list[focus][pos].x, cursor_list[focus][pos].y);
#ifdef __C64__
    scr = (unsigned char *) ((PEEK(0xd1) | (PEEK(0xd2) << 8)) + PEEK(0xd3));
#else
#ifdef __PLUS4__
    scr = (unsigned char *) ((PEEK(0xc8) | (PEEK(0xc9) << 8)) + PEEK(0xca));
#else
#error Unsupported target
#endif
#endif
    l = cursor_list[focus][pos].l;
    while (l) {
        *scr &= 0x7f;
        ++scr;
        --l;
    }
}
