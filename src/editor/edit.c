#include <conio.h>
#include "fileio.h"
#include "draw.h"
#include "cursor.h"
#include "savegame.h"
#include "stat.h"
#include "edit.h"


unsigned char cur_player_select;
unsigned char cur_player;
unsigned char cur_food_gold;
unsigned char cur_mixtures;
unsigned char cur_reagents;
unsigned char cur_virtues;
unsigned char cur_runes;
unsigned char cur_stones;
unsigned char cur_items;


unsigned char edit_player_select(void) {
    char c;

    select(FOCUS_PLAYER_SELECT, cur_player_select);
    draw_player(cur_player_select);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_PLAYER_SELECT, cur_player_select);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_PLAYER_SELECT, cur_player_select);
            savegame();
            break;

        case CH_CURS_UP:
            if (cur_player_select) {
                deselect(FOCUS_PLAYER_SELECT, cur_player_select);
                --cur_player_select;
                select(FOCUS_PLAYER_SELECT, cur_player_select);
                draw_player(cur_player_select);
            }
            break;

        case CH_CURS_DOWN:
            deselect(FOCUS_PLAYER_SELECT, cur_player_select);
            if (party_size && cur_player_select < party_size - 1) {
                ++cur_player_select;
                select(FOCUS_PLAYER_SELECT, cur_player_select);
                draw_player(cur_player_select);
            } else {
                return(FOCUS_PARTY_SIZE);
            }
            break;

        case CH_ENTER:
        case CH_CURS_RIGHT:
            deselect(FOCUS_PLAYER_SELECT, cur_player_select);
            cur_player = 0;
            return(FOCUS_PLAYER);
            break;
        }
    }
}


unsigned char edit_player(void) {
    char c;

    select(FOCUS_PLAYER, cur_player);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_PLAYER, cur_player);
            return(FOCUS_QUIT);
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_PLAYER, cur_player);
            switch (cur_player) {
            case 2:
            case 3:
            case 5:
            case 7:
            case 10:
                cur_player -= 1;
                select(FOCUS_PLAYER, cur_player);
                break;
                default:
                return(FOCUS_PLAYER_SELECT);
                break;
            }
            break;

        case CH_CURS_RIGHT:
            switch (cur_player) {
            case 1:
            case 2:
            case 4:
            case 6:
            case 9:
                deselect(FOCUS_PLAYER, cur_player);
                cur_player += 1;
                select(FOCUS_PLAYER, cur_player);
                break;
            }
            break;

        case CH_CURS_UP:
            if (cur_player) {
                deselect(FOCUS_PLAYER, cur_player);
                switch (cur_player) {
                case 1:
                case 2:
                case 3:
                    cur_player = 0;
                    break;
                case 4:
                case 5:
                    cur_player = 2;
                    break;
                case 6:
                case 7:
                case 8:
                    cur_player -= 2;
                    break;
                case 9:
                    cur_player = 8;
                    break;
                case 10:
                    cur_player = 7;
                    break;
                case 11:
                    cur_player = 9;
                    break;
                case 12:
                    cur_player = 11;
                    break;
                }
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case CH_CURS_DOWN:
            deselect(FOCUS_PLAYER, cur_player);
            switch (cur_player) {
            case 0:
                cur_player = 2;
                break;
            case 1:
            case 2:
                cur_player = 4;
                break;
            case 3:
            case 4:
            case 5:
            case 6:
                cur_player += 2;
                break;
            case 7:
                cur_player = 10;
                break;
            case 8:
                cur_player = 9;
                break;
            case 9:
            case 10:
                cur_player = 11;
                break;
            case 11:
                cur_player = 12;
                break;
                default:
                cur_virtues = 0;
                return(FOCUS_VIRTUES);
            }
            select(FOCUS_PLAYER, cur_player);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_PLAYER, cur_player)) {
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case 'f':
            if (cur_player == 1 && player[cur_player_select].sex != 0x7b) {
                player[cur_player_select].sex = 0x7b;
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case 'm':
            if (cur_player == 1 && player[cur_player_select].sex != 0x5c) {
                player[cur_player_select].sex = 0x5c;
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case 'd':
            if (cur_player == 3) {
                if (player[cur_player_select].status != 'D') {
                    player[cur_player_select].status = 'D';
                    draw_player(cur_player_select);
                    select(FOCUS_PLAYER, cur_player);
                }
            } else {
                if (++dev > 30) {
                    dev = 8;
                }
                draw_help();
            }
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 'g':
            if (cur_player == 3 && player[cur_player_select].status != 'G') {
                player[cur_player_select].status = 'G';
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case 'p':
            if (cur_player == 3 && player[cur_player_select].status != 'P') {
                player[cur_player_select].status = 'P';
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case 's':
            if (cur_player == 3) {
                if (player[cur_player_select].status != 'S') {
                    player[cur_player_select].status = 'S';
                    draw_player(cur_player_select);
                    select(FOCUS_PLAYER, cur_player);
                }
            } else {
                deselect(FOCUS_PLAYER, cur_player);
                savegame();
            }
            break;

        case '+':
            if (stat_inc(cur_player_select, FOCUS_PLAYER, cur_player)) {
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;

        case '-':
            if (stat_dec(cur_player_select, FOCUS_PLAYER, cur_player)) {
                draw_player(cur_player_select);
                select(FOCUS_PLAYER, cur_player);
            }
            break;
        }
    }
}


unsigned char edit_party_size(void) {
    char c;

    select(FOCUS_PARTY_SIZE, 0);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_PARTY_SIZE, 0);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_PARTY_SIZE, 0);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_PARTY_SIZE, 0);
            if (party_size) {
                cur_player_select = party_size - 1;
            } else {
                cur_player_select = 0;
            }
            return(FOCUS_PLAYER_SELECT);
            break;

        case CH_CURS_DOWN:
            deselect(FOCUS_PARTY_SIZE, 0);
            cur_food_gold = 0;
            return(FOCUS_FOOD_GOLD);
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_PARTY_SIZE, 0);
            cur_items = 0;
            return(FOCUS_ITEMS);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_PARTY_SIZE, 0)) {
                draw_party_size();
                list_players();
                select(FOCUS_PARTY_SIZE, 0);
            }
            break;

        case '+':
            if (stat_inc(0, FOCUS_PARTY_SIZE, 0)) {
                draw_party_size();
                list_players();
                select(FOCUS_PARTY_SIZE, 0);
            }
            break;

        case '-':
            if (stat_dec(0, FOCUS_PARTY_SIZE, 0)) {
                draw_party_size();
                list_players();
                select(FOCUS_PARTY_SIZE, 0);
            }
            break;
        }
    }
}


unsigned char edit_food_gold(void) {
    char c;

    select(FOCUS_FOOD_GOLD, cur_food_gold);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_FOOD_GOLD, cur_food_gold);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_FOOD_GOLD, cur_food_gold);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_FOOD_GOLD, cur_food_gold);
            if (cur_food_gold) {
                --cur_food_gold;
                select(FOCUS_FOOD_GOLD, cur_food_gold);
            } else {
                return(FOCUS_PARTY_SIZE);
            }
            break;

        case CH_CURS_DOWN:
            deselect(FOCUS_FOOD_GOLD, cur_food_gold);
            if (cur_food_gold < 1) {
                ++cur_food_gold;
                select(FOCUS_FOOD_GOLD, cur_food_gold);
            } else {
                cur_mixtures = 8;
                return(FOCUS_MIXTURES);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_FOOD_GOLD, cur_food_gold);
            cur_items = cur_food_gold + 1;
            return(FOCUS_ITEMS);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_FOOD_GOLD, cur_food_gold)) {
                draw_food_gold();
                select(FOCUS_FOOD_GOLD, cur_food_gold);
            }
            break;
        }
    }
}


unsigned char edit_mixtures(void) {
    char c;

    select(FOCUS_MIXTURES, cur_mixtures);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_MIXTURES, cur_mixtures);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_MIXTURES, cur_mixtures);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_MIXTURES, cur_mixtures);
            if (cur_mixtures == 0 || cur_mixtures == 8 || cur_mixtures == 17) {
                cur_food_gold = 1;
                return(FOCUS_FOOD_GOLD);
            } else {
                --cur_mixtures;
                select(FOCUS_MIXTURES, cur_mixtures);
            }
            break;

        case CH_CURS_DOWN:
            if (cur_mixtures == 7 || cur_mixtures == 16 || cur_mixtures == 25) {
            } else {
                deselect(FOCUS_MIXTURES, cur_mixtures);
                ++cur_mixtures;
                select(FOCUS_MIXTURES, cur_mixtures);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_MIXTURES, cur_mixtures);
            if (cur_mixtures < 8) {
                cur_mixtures += 9;
            } else if (cur_mixtures < 17) {
                cur_mixtures += 9;
            } else {
                if ((cur_reagents = cur_mixtures - 18) == 0xff) {
                    cur_reagents = 0;
                }
                return(FOCUS_REAGENTS);
            }
            select(FOCUS_MIXTURES, cur_mixtures);
            break;

        case CH_CURS_LEFT:
            if (cur_mixtures > 8) {
                deselect(FOCUS_MIXTURES, cur_mixtures);
                cur_mixtures -= 9;
                select(FOCUS_MIXTURES, cur_mixtures);
            }
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_MIXTURES, cur_mixtures)) {
                draw_mixtures();
                select(FOCUS_MIXTURES, cur_mixtures);
            }
            break;
        }
    }
}


unsigned char edit_reagents(void) {
    char c;

    select(FOCUS_REAGENTS, cur_reagents);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_REAGENTS, cur_reagents);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_REAGENTS, cur_reagents);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_REAGENTS, cur_reagents);
            if (cur_reagents) {
                --cur_reagents;
            } else {
                cur_player = 12;
                return(FOCUS_PLAYER);
            }
            select(FOCUS_REAGENTS, cur_reagents);
            break;

        case CH_CURS_DOWN:
            if (cur_reagents < 7) {
                deselect(FOCUS_REAGENTS, cur_reagents);
                ++cur_reagents;
                select(FOCUS_REAGENTS, cur_reagents);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_REAGENTS, cur_reagents);
            cur_virtues = cur_reagents;
            return(FOCUS_VIRTUES);
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_REAGENTS, cur_reagents);
            cur_mixtures = cur_reagents + 18;
            return(FOCUS_MIXTURES);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_REAGENTS, cur_reagents)) {
                draw_reagents();
                select(FOCUS_REAGENTS, cur_reagents);
            }
            break;
        }
    }
}


unsigned char edit_virtues(void) {
    char c;

    select(FOCUS_VIRTUES, cur_virtues);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_VIRTUES, cur_virtues);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_VIRTUES, cur_virtues);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_VIRTUES, cur_virtues);
            if (cur_virtues) {
                --cur_virtues;
            } else {
                cur_player = 12;
                return(FOCUS_PLAYER);
            }
            select(FOCUS_VIRTUES, cur_virtues);
            break;

        case CH_CURS_DOWN:
            if (cur_virtues < 7) {
                deselect(FOCUS_VIRTUES, cur_virtues);
                ++cur_virtues;
                select(FOCUS_VIRTUES, cur_virtues);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_VIRTUES, cur_virtues);
            cur_runes = cur_virtues;
            return(FOCUS_RUNES);
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_VIRTUES, cur_virtues);
            cur_reagents = cur_virtues;
            return(FOCUS_REAGENTS);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_VIRTUES, cur_virtues)) {
                draw_virtues();
                select(FOCUS_VIRTUES, cur_virtues);
            }
            break;
        }
    }
}


unsigned char edit_runes(void) {
    char c;

    select(FOCUS_RUNES, cur_runes);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_RUNES, cur_runes);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_RUNES, cur_runes);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_RUNES, cur_runes);
            if (cur_runes) {
                --cur_runes;
            } else {
                cur_player = 12;
                return(FOCUS_PLAYER);
            }
            select(FOCUS_RUNES, cur_runes);
            break;

        case CH_CURS_DOWN:
            if (cur_runes < 7) {
                deselect(FOCUS_RUNES, cur_runes);
                ++cur_runes;
                select(FOCUS_RUNES, cur_runes);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_RUNES, cur_runes);
            cur_stones = cur_runes;
            return(FOCUS_STONES);
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_RUNES, cur_runes);
            cur_virtues = cur_runes;
            return(FOCUS_VIRTUES);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_RUNES, cur_runes)) {
                draw_virtues();
                select(FOCUS_RUNES, cur_runes);
            }
            break;
        }
    }
}


unsigned char edit_stones(void) {
    char c;

    select(FOCUS_STONES, cur_stones);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_STONES, cur_stones);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_STONES, cur_stones);
            savegame();
            break;

        case CH_CURS_UP:
            deselect(FOCUS_STONES, cur_stones);
            if (cur_stones) {
                --cur_stones;
            } else {
                cur_player = 12;
                return(FOCUS_PLAYER);
            }
            select(FOCUS_STONES, cur_stones);
            break;

        case CH_CURS_DOWN:
            if (cur_stones < 7) {
                deselect(FOCUS_STONES, cur_stones);
                ++cur_stones;
                select(FOCUS_STONES, cur_stones);
            }
            break;

        case CH_CURS_RIGHT:
            deselect(FOCUS_STONES, cur_stones);
            cur_items = cur_stones + 5;
            return(FOCUS_ITEMS);
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_STONES, cur_stones);
            cur_runes = cur_stones;
            return(FOCUS_RUNES);
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_STONES, cur_stones)) {
                draw_virtues();
                select(FOCUS_STONES, cur_stones);
            }
            break;
        }
    }
}


unsigned char edit_items(void) {
    char c;

    select(FOCUS_ITEMS, cur_items);
    for (;;) {
        c = cgetc();
        switch(c) {

        case 'q':
            deselect(FOCUS_ITEMS, cur_items);
            return(FOCUS_QUIT);
            break;

        case 'd':
            if (++dev > 30) {
                dev = 8;
            }
            draw_help();
            break;

        case 'D':
            if (--dev < 8) {
                dev = 30;
            }
            draw_help();
            break;

        case 's':
            deselect(FOCUS_ITEMS, cur_items);
            savegame();
            break;

        case CH_CURS_UP:
            if (cur_items) {
                deselect(FOCUS_ITEMS, cur_items);
                --cur_items;
                select(FOCUS_ITEMS, cur_items);
            }
            break;

        case CH_CURS_DOWN:
            if (cur_items < 12) {
                deselect(FOCUS_ITEMS, cur_items);
                ++cur_items;
                select(FOCUS_ITEMS, cur_items);
            }
            break;

        case CH_CURS_LEFT:
            deselect(FOCUS_ITEMS, cur_items);
            switch (cur_items) {
            case 0:
                return(FOCUS_PARTY_SIZE);
            case 1:
            case 2:
                cur_food_gold = cur_items - 1;
                return(FOCUS_FOOD_GOLD);
            case 3:
            case 4:
                cur_stones = 0;
                return(FOCUS_STONES);
                break;
                default:
                cur_stones = cur_items - 5;
                return(FOCUS_STONES);
                break;
            }
            break;

        case CH_ENTER:
            if (stat_edit(cur_player_select, FOCUS_ITEMS, cur_items)) {
                draw_items();
                select(FOCUS_ITEMS, cur_items);
            }
            break;
        }
    }
}


void edit(void) {
    unsigned char focus = 1;

    cur_player_select = 0;
    cur_player = 0;
    cur_food_gold = 0;
    cur_mixtures = 0;
    cur_reagents = 0;
    cur_virtues = 0;
    cur_runes = 0;
    cur_stones = 0;

    while (focus != FOCUS_QUIT) {

        switch (focus) {

        case FOCUS_PLAYER_SELECT:
            focus = edit_player_select();
            break;

        case FOCUS_PLAYER:
            focus = edit_player();
            break;

        case FOCUS_PARTY_SIZE:
            focus = edit_party_size();
            break;

        case FOCUS_FOOD_GOLD:
            focus = edit_food_gold();
            break;

        case FOCUS_MIXTURES:
            focus = edit_mixtures();
            break;

        case FOCUS_REAGENTS:
            focus = edit_reagents();
            break;

        case FOCUS_VIRTUES:
            focus = edit_virtues();
            break;

        case FOCUS_RUNES:
            focus = edit_runes();
            break;

        case FOCUS_STONES:
            focus = edit_stones();
            break;

        case FOCUS_ITEMS:
            focus = edit_items();
            break;
        }
    }
}
