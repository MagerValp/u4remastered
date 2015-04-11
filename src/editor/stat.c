#include <cbm.h>
#include <conio.h>
#include "savegame.h"
#include "edit.h"
#include "stat.h"


unsigned char bcd2_add(unsigned char a, unsigned char b) {
    if (a + b > 0x99) {
        return(0x99);
    }
    while (b >= 0x10) {
        a += 0x10;
        b -= 0x10;
    }
    return(b + a);
}


unsigned char bcd2_sub(unsigned char a, unsigned char b) {
    if ((int) a - (int) b < 0) {
        return(0x00);
    }
    while (b >= 0x10) {
        a -= 0x10;
        b -= 0x10;
    }
    return(b - a);
}


unsigned char bcd2_inc(unsigned char *a) {
    if (*a < 0x99) {
        *a = bcd2_add(*a, 0x01);
        return(1);
    }
    return(0);
}


unsigned char bcd2_dec(unsigned char *a) {
    if (*a > 0x00) {
        *a = bcd2_sub(*a, 0x01);
        return(1);
    }
    return(0);
}


unsigned char player_stat_inc(unsigned char p, unsigned char c) {
    switch (c) {

    case 2:
        ++player[p].class;
        if (player[p].class >= 8) {
            player[p].class = 0;
        }
        player[p].classmask = bit[player[p].class];
        return(1);
        break;

    case 5:
        if (player[p].hpmax[0] < 8) {
            ++player[p].hpmax[0];
            return(1);
        }
        break;

    case 11:
        if (player[p].weapon < 15) {
            ++player[p].weapon;
            return(1);
        }
        break;

    case 12:
        if (player[p].armor < 7) {
            ++player[p].armor;
            return(1);
        }
        break;

    }
    return(0);
}


unsigned char party_size_inc(void) {
    if (party_size < 8) {
        ++party_size;
        return(1);
    }
    return(0);
}


/*
unsigned char food_gold_inc(unsigned char c) {
  return(0);
}


unsigned char mixtures_inc(unsigned char c) {
  return(0);
}


unsigned char reagents_inc(unsigned char c) {
  return(0);
}


unsigned char virtues_inc(unsigned char c) {
  return(0);
}


unsigned char runes_inc(unsigned char c) {
  return(0);
}


unsigned char stones_inc(unsigned char c) {
  return(0);
}


unsigned char items_inc(unsigned char c) {
  return(0);
}
*/


unsigned char stat_inc(unsigned char p, unsigned char f, unsigned char c) {
    switch (f) {
    case FOCUS_PLAYER:
        return(player_stat_inc(p, c));
    case FOCUS_PARTY_SIZE:
        return(party_size_inc());
    /*
    case FOCUS_FOOD_GOLD:
        return(food_gold_inc(c));
    case FOCUS_MIXTURES:
        return(mixtures_inc(c));
    case FOCUS_REAGENTS:
        return(reagents_inc(c));
    case FOCUS_VIRTUES:
        return(virtues_inc(c));
    case FOCUS_RUNES:
        return(runes_inc(c));
    case FOCUS_STONES:
        return(stones_inc(c));
    case FOCUS_ITEMS:
        return(items_inc(c));
    */
    default:
        return(0);
    }
}


unsigned char player_stat_dec(unsigned char p, unsigned char c) {
    switch (c) {

    case 2:
        --player[p].class;
        if (player[p].class >= 8) {
            player[p].class = 7;
        }
        player[p].classmask = bit[player[p].class];
        return(1);
        break;

    case 5:
        if (player[p].hpmax[0] > 1) {
            --player[p].hpmax[0];
            return(1);
        }
        break;

    case 11:
        if (player[p].weapon) {
            --player[p].weapon;
            return(1);
        }
        break;

    case 12:
        if (player[p].armor) {
            --player[p].armor;
            return(1);
        }
        break;

    }
    return(0);
}


unsigned char party_size_dec(void) {
    if (party_size > 1) {
        --party_size;
        return(1);
    }
    return(0);
}


/*
unsigned char food_gold_dec(unsigned char c) {
  return(0);
}


unsigned char mixtures_dec(unsigned char c) {
  return(0);
}


unsigned char reagents_dec(unsigned char c) {
  return(0);
}


unsigned char virtues_dec(unsigned char c) {
  return(0);
}


unsigned char runes_dec(unsigned char c) {
  return(0);
}


unsigned char stones_dec(unsigned char c) {
  return(0);
}


unsigned char items_dec(unsigned char c) {
  return(0);
}
*/


unsigned char stat_dec(unsigned char p, unsigned char f, unsigned char c) {
    switch (f) {
    case FOCUS_PLAYER:
        return(player_stat_dec(p, c));
    case FOCUS_PARTY_SIZE:
        return(party_size_dec());
    /*
    case FOCUS_FOOD_GOLD:
        return(food_gold_dec(c));
    case FOCUS_MIXTURES:
        return(mixtures_dec(c));
    case FOCUS_REAGENTS:
        return(reagents_dec(c));
    case FOCUS_VIRTUES:
        return(virtues_dec(c));
    case FOCUS_RUNES:
        return(runes_dec(c));
    case FOCUS_STONES:
        return(stones_dec(c));
    case FOCUS_ITEMS:
        return(items_dec(c));
    */
    default:
        return(0);
    }
}


int get_digit(unsigned char min, unsigned char max) {
    unsigned char c;

    textcolor(COLOR_WHITE);
    cputc(' ');
    if (wherex() == 0) {
        gotoxy(39, wherey() - 1);
    } else {
        gotox(wherex() - 1);
    }
    for (;;) {
        cursor(1);
        c = cgetc();
        cursor(0);
        switch (c) {
        case CH_STOP:
            return(-1);
        case CH_ENTER:
            return(-2);
        case CH_DEL:
            return(-3);
        }
        c -= '0';
        if (c >= min && c <= max) {
            return(c);
        }
    }
}


int get_bcd2(void) {
    unsigned char bcd = 0x00;
    unsigned char l = 0;
    int n;

    cputs("  ");
    if (wherex() < 2) {
        gotoxy(38, wherey() - 1);
    } else {
        gotox(wherex() - 2);
    }
    while (l < 2) {
        switch (n = get_digit(0, 9)) {
        case -1:
            return(-1);
        case -2:
            if (l) {
                return(bcd);
            } else {
                return(-1);
            }
        case -3:
            if (l) {
                gotox(wherex() - 1);
                cputc(' ');
                gotox(wherex() - 1);
                --l;
                bcd >>= 4;
            }
            break;
        default:
            cputc(n + '0');
            bcd = (bcd << 4) | n;
            ++l;
            break;
        }
    }
    return(bcd);
}


void set_bcd2(unsigned char *bcd) {
    int n;

    if ((n = get_bcd2()) >= 0) {
        *bcd = n;
    }
}


int get_bcd4(void) {
    unsigned short bcd = 0x0000;
    unsigned char l = 0;
    int n;

    cputs("    ");
    gotox(wherex() - 4);
    while (l < 4) {
        switch (n = get_digit(0, 9)) {
        case -1:
            return(-1);
        case -2:
            if (l) {
                return(bcd);
            } else {
                return(-1);
            }
        case -3:
            if (l) {
                gotox(wherex() - 1);
                cputc(' ');
                gotox(wherex() - 1);
                --l;
                bcd >>= 4;
            }
            break;
        default:
            cputc(n + '0');
            bcd = (bcd << 4) | n;
            ++l;
            break;
        }
    }
    return(bcd);
}


void set_bcd4(unsigned char *bcd) {
    int n;

    n = get_bcd4();
    if (n >= 0 || n < 0xa000) {
        bcd[0] = n >> 8;
        bcd[1] = n & 0xff;
    }
}


unsigned char player_stat_edit(unsigned char p, unsigned char c) {
    int n;

    switch (c) {

    case 4:
        set_bcd2(&player[p].mp);
        return(1);
        break;

    case 5:
        if ((n = get_digit(1, 8)) > 0) {
            player[p].hpmax[0] = n;
        }
        return(1);
        break;

    case 6:
        set_bcd2(&player[p].strength);
        return(1);
        break;

    case 7:
        set_bcd4((unsigned char *)&player[p].hp);
        return(1);
        break;

    case 8:
        set_bcd2(&player[p].dexterity);
        return(1);
        break;

    case 9:
        set_bcd2(&player[p].intelligence);
        return(1);
        break;

    case 10:
        set_bcd4((unsigned char *)&player[p].experience);
        return(1);
        break;

    }
    return(0);
}


unsigned char party_size_edit(void) {
    int n;

    if ((n = get_digit(1, 8)) > 0) {
        party_size = n;
        return(1);
    }
    return(0);
}


unsigned char food_gold_edit(unsigned char c) {
    switch (c) {

    case 0:
        set_bcd4(food);
        return(1);
        break;

    case 1:
        set_bcd4(gold);
        return(1);
        break;

    }

    return(0);
}


unsigned char mixtures_edit(unsigned char c) {
    set_bcd2(&mixture[c]);
    return(1);
}


unsigned char reagents_edit(unsigned char c) {
    set_bcd2(&reagent[c]);
    return(1);
}


unsigned char virtues_edit(unsigned char c) {
    set_bcd2(&virtue[c]);
    return(1);
}


unsigned char runes_edit(unsigned char c) {
    runes ^= bit[c];
    return(1);
}


unsigned char stones_edit(unsigned char c) {
    stones ^= bit[c];
    return(1);
}


unsigned char items_edit(unsigned char c) {
    switch (c) {
    case 0:
        set_bcd2(&torches);
        break;
    case 1:
        set_bcd2(&gems);
        break;
    case 2:
        set_bcd2(&keys);
        break;
    case 3:
        sextant ^= 1;
        break;
    case 4:
    case 5:
    case 6:
        items ^= bit[c + 1];
        break;
    case 7:
        horn ^= 1;
        break;
    case 8:
        wheel ^= 1;
        break;
    case 9:
        skull ^= 1;
        break;
    case 10:
    case 11:
    case 12:
        threepartkey ^= bit[c - 5];
        break;
    }
    return(1);
}


unsigned char stat_edit(unsigned char p, unsigned char f, unsigned char c) {
    switch (f) {
    case FOCUS_PLAYER:
        return(player_stat_edit(p, c));
    case FOCUS_PARTY_SIZE:
        return(party_size_edit());
    case FOCUS_FOOD_GOLD:
        return(food_gold_edit(c));
    case FOCUS_MIXTURES:
        return(mixtures_edit(c));
    case FOCUS_REAGENTS:
        return(reagents_edit(c));
    case FOCUS_VIRTUES:
        return(virtues_edit(c));
    case FOCUS_RUNES:
        return(runes_edit(c));
    case FOCUS_STONES:
        return(stones_edit(c));
    case FOCUS_ITEMS:
        return(items_edit(c));
    default:
        return(0);
    }
}
