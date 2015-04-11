#include <conio.h>
#include <string.h>
#include "fileio.h"
#include "savegame.h"
#include "draw.h"


char *str_class[] = {
    "Mage",
    "Bard",
    "Fighter",
    "Druid",
    "Tinker",
    "Paladin",
    "Ranger",
    "Shepherd"
};


char *str_weapon[] = {
    "Hands",
    "Staff",
    "Dagger",
    "Sling",
    "Mace",
    "Axe",
    "Sword",
    "Bow",
    "Crossbow",
    "Flaming Oil",
    "Halberd",
    "Magic Axe",
    "Magic Sword",
    "Magic Bow",
    "Magic Wand",
    "Mystic Sword"
};


char *str_armor[] = {
    "Skin",
    "Cloth",
    "Leather",
    "Chain Mail",
    "Plate Mail",
    "Magic Chain",
    "Magic Plate",
    "Mystic Robe"
};


char *str_reagent[] = {
    "Ash",
    "Gin",
    "Gar",
    "Sil",
    "Mos",
    "Pea",
    "Nig",
    "Man"
};


char *str_virtue[] = {
    "Hon",
    "Com",
    "Val",
    "Jus",
    "Sac",
    "Hnr",
    "Spi",
    "Hum"
};


char *str_item[] = {
    "Trch",
    "Gems",
    "Keys",
    "Sexta",
    "Bell ",
    "Book ",
    "Candl",
    "Horn ",
    "Wheel",
    "Skull",
    "Truth",
    "Love ",
    "Coura"
};


char conv_uscii_char(char c) {
    c &= 0x7f;
    if ((c >= 0x41 && c <= 0x5a) || (c >= 0x61 && c <= 0x7a)) {
        c ^= 0x20;
    }
    return c;
}

static char uscii_buf[17];

char *conv_uscii(char *s) {
    unsigned char index = 0;
    
    bzero(uscii_buf, sizeof(uscii_buf));
    while (uscii_buf[index] = conv_uscii_char(*s)) {
        ++s;
        ++index;
    }
    return uscii_buf;
}


char *str_sex(unsigned char s) {
    switch (s) {
        case 0x7b:
        return("F");
        case 0x5c:
        return("M");
        default:
        return("?");
    }
}


void centerstring(char *str, unsigned char len) {
    unsigned char x;

    x = wherex();
    gotox(x + (len - strlen(str))/2);
    cputs(str);
}


void draw_player(unsigned char p) {
    textcolor(COLOR_WHITE);

    cputsxy(17, 2, "                ");
    gotoxy(17, 2);
    centerstring(conv_uscii(player[p].name), 16);

    cputsxy(21, 3, "        ");
    cputsxy(17, 3, str_sex(player[p].sex));
    gotoxy(18, 3);
    centerstring(str_class[player[p].class], 14);
    gotoxy(32, 3);
    cprintf("%c", player[p].status);

    gotoxy(21, 4);
    cprintf("%02x", player[p].mp);
    gotoxy(28, 4);
    cprintf("%x", player[p].hpmax[0]);

    gotoxy(21, 5);
    cprintf("%02x", player[p].strength);
    gotoxy(28, 5);
    cprintf("%02x%02x", player[p].hp[0], player[p].hp[1]);

    gotoxy(21, 6);
    cprintf("%02x", player[p].dexterity);
    gotoxy(28, 6);
    cprintf("%02x%02x", player[p].hpmax[0], player[p].hpmax[1]);

    gotoxy(21, 7);
    cprintf("%02x", player[p].intelligence);
    gotoxy(28, 7);
    cprintf("%02x%02x", player[p].experience[0], player[p].experience[1]);

    cputsxy(19, 8, "            ");
    gotoxy(19, 8);
    cputs(str_weapon[player[p].weapon]);

    cputsxy(19, 9, "            ");
    gotoxy(19, 9);
    cputs(str_armor[player[p].armor]);
}


void colon(void) {
    unsigned char c;

    c = textcolor(COLOR_GRAY3);
    cputc(':');
    textcolor(c);
}


void dash(void) {
    unsigned char c;

    c = textcolor(COLOR_GRAY3);
    cputc('-');
    textcolor(c);
}


void draw_player_template(void) {
    textcolor(COLOR_YELLOW);

    cputsxy(17, 3, "                ");

    cputsxy(17, 4, " MP");
    colon();
    cputs("    ");

    cputsxy(25, 4, "LV");
    colon();
    cputs("     ");

    cputsxy(17, 5, "STR");
    colon();
    cputs("    ");

    cputsxy(25, 5, "HP");
    colon();
    cputs("     ");

    cputsxy(17, 6, "DEX");
    colon();
    cputs("    ");

    cputsxy(25, 6, "HM");
    colon();
    cputs("     ");

    cputsxy(17, 7, "INT");
    colon();
    cputs("    ");

    cputsxy(25, 7, "EX");
    colon();
    cputs("     ");

    cputsxy(17, 8, "W");
    colon();
    cputs("              ");

    cputsxy(17, 9, "A");
    colon();
    cputs("              ");
}


void draw_template(void) {
    unsigned char i;

    draw_player_template();

    textcolor(COLOR_LIGHTRED);

    cputsxy(0, 11, "Party size");
    colon();

    cputsxy(0, 13, "Food");
    colon();
    cputsxy(0, 14, "Gold");
    colon();

    cputsxy(0, 16, "Mixt");

    cputsxy(15, 16, "Reagnt");
    cputsxy(22, 16, "Virtue");
    cputsxy(29, 16, "R");
    cputsxy(31, 16, "S");
    cputsxy(33, 11, "Items  ");

    textcolor(COLOR_YELLOW);

  /* mixtures */
    for (i = 0; i < 9; ++i) {
        if (i) {
            gotoxy(0, i + 16);
            cputc(i + 'A' - 1);
            dash();
        }
        gotoxy(5, i + 16);
        cputc(i + 'I');
        dash();
        gotoxy(10, i + 16);
        cputc(i + 'R');
        dash();
    }

  /* reagents and virtues */
    for (i = 0; i < 8; ++i) {
        cputsxy(15, i + 17, str_reagent[i]);
        dash();
        cputsxy(22, i + 17, str_virtue[i]);
        dash();
    }

  /* items */
    for (i = 0; i < 13; ++i) {
        cputsxy(33, i + 12, str_item[i]);
        dash();
    }
}


void list_players(void) {
    unsigned char i, l;

    textcolor(COLOR_WHITE);
    for (i = 0; i < 8; ++i) {
        if (i == party_size) {
            textcolor(COLOR_GRAY1);
        }
        cputsxy(0, i + 2, conv_uscii(player[i].name));
        l = 16 - strlen(player[i].name);
        while (l) {
            cputc(' ');
            --l;
        }
    }
}


void draw_party_size(void) {
    textcolor(COLOR_WHITE);
    gotoxy(11, 11);
    cprintf("%d", party_size);
}


void draw_food_gold(void) {
    textcolor(COLOR_WHITE);
    gotoxy(5, 13);
    cprintf("%02x%02x", food[0], food[1]);
    gotoxy(5, 14);
    cprintf("%02x%02x", gold[0], gold[1]);
}


void draw_mixtures(void) {
    unsigned char i;

    textcolor(COLOR_WHITE);

    for (i = 0; i < 9; ++i) {
        if (i) {
            gotoxy(2, i + 16);
            cprintf("%02x", mixture[i - 1]);
        }
        gotoxy(7, i + 16);
        cprintf("%02x", mixture[i + 8]);
        gotoxy(12, i + 16);
        cprintf("%02x", mixture[i + 17]);
    }
}


void draw_reagents(void) {
    unsigned char i;

    textcolor(COLOR_WHITE);

    for (i = 0; i < 8; ++i) {
        gotoxy(19, i + 17);
        cprintf("%02x", reagent[i]);
    }
}


unsigned char stone_color[] = {
    14, 7, 10, 13, 8, 4, 1, 11
};

unsigned char stone_char[] = {
    'B', 'Y', 'R', 'G', 'O', 'P', 'W', 'B'
};

unsigned char rune_char[] = {
    'H', 'C', 'V', 'J', 'S', 'H', 'S', 'H'
};

void draw_virtues(void) {
    unsigned char i;

    for (i = 0; i < 8; ++i) {
        textcolor(COLOR_WHITE);
        gotoxy(26, i + 17);
        cprintf("%02x", virtue[i]);
        gotox(29);
        cputc(runes & bit[i] ? rune_char[i] : '.');
        gotox(31);
        textcolor(stone_color[i]);
        cputc(stones & bit[i] ? stone_char[i] : '.');
    }
}


void draw_items(void) {
    textcolor(COLOR_WHITE);

    gotoxy(38, 12);
    cprintf("%02x", torches);

    gotoxy(38, 13);
    cprintf("%02x", gems);

    gotoxy(38, 14);
    cprintf("%02x", keys);

    cputsxy(39, 15, sextant ? "1" : "0");
    cputsxy(39, 16, items & 4 ? "1" : "0");
    cputsxy(39, 17, items & 2 ? "1" : "0");
    cputsxy(39, 18, items & 1 ? "1" : "0");
    cputsxy(39, 19, horn ? "1" : "0");
    cputsxy(39, 20, wheel ? "1" : "0");
    cputsxy(39, 21, skull ? "1" : "0");
    cputsxy(39, 22, threepartkey & 4 ? "1" : "0");
    cputsxy(39, 23, threepartkey & 2 ? "1" : "0");
    cputsxy(39, 24, threepartkey & 1 ? "1" : "0");
}


void draw_help(void) {
    cputsxy(34, 2, "      ");

    textcolor(COLOR_LIGHTRED);
    cputsxy(34, 3, "S ");
    textcolor(COLOR_YELLOW);
    cputsxy(36, 3, "Save");

    cputsxy(34, 4, "      ");

    textcolor(COLOR_LIGHTRED);
    cputsxy(34, 5, "Q ");
    textcolor(COLOR_YELLOW);
    cputsxy(36, 5, "Quit");

    cputsxy(34, 6, "      ");

    if (dev != DEV_FLASH) {
        textcolor(COLOR_LIGHTRED);
        cputsxy(34, 7, "D ");
        textcolor(COLOR_YELLOW);
        cputsxy(36, 7, "D#");
        cprintf("%02d", dev);
    } else {
        cputsxy(34, 7, "      ");
    }

    cputsxy(34, 8, "      ");

    textcolor(COLOR_LIGHTRED);
    cputsxy(14, 11, " Cursor ");
    textcolor(COLOR_YELLOW);
    cputsxy(22, 11, "Select   ");

    textcolor(COLOR_YELLOW);
    cputsxy(14, 12, "    /   Inc/Dec  ");
    textcolor(COLOR_LIGHTRED);
    cputsxy(17, 12, "+");
    cputsxy(19, 12, "-");

    cputsxy(14, 13, " Return ");
    textcolor(COLOR_YELLOW);
    cputsxy(22, 13, "Change   ");
}


void draw_error(unsigned char *msg) {
    unsigned char l = 15;

    revers(0);
    textcolor(COLOR_LIGHTRED);
    cputsxy(14, 14, " ");
    while (l && *msg) {
        cputc(*msg++);
        --l;
    }

    while (l) {
        cputc(' ');
        --l;
    }

    cputc(' ');
}


void draw_all(void) {
    revers(0);
    list_players();
    draw_template();
    draw_player(0);
    draw_party_size();
    draw_food_gold();
    draw_mixtures();
    draw_reagents();
    draw_virtues();
    draw_items();
    draw_help();
}
