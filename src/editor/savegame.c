#include "savegame.h"


unsigned char bit[] = {
    128, 64, 32, 16, 8, 4, 2, 1
};

unsigned char save_1a[0x20];
unsigned char save_80[0x200];
unsigned char loadaddr_1a[2];
unsigned char loadaddr_80[2];

t_player *player = (t_player *) &save_80[0];

unsigned char *virtue = &save_80[0x100];
unsigned char *food = &save_80[0x110];
unsigned char *gold = &save_80[0x113];
unsigned char *armor = &save_80[0x118];
unsigned char *weapon = &save_80[0x120];
unsigned char *reagent = &save_80[0x138];
unsigned char *mixture = &save_80[0x140];
