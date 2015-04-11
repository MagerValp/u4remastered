//#include "src/easyflash/util.h"
#include <stdint.h>
#include <stdbool.h>
#include "savegame.h"
#include "fileio.h"


unsigned char dev = DEV_FLASH;


uint16_t flash_load_file(uint8_t filenum, uint8_t *buffer);
bool flash_save_file(uint8_t filenum, uint8_t *buffer, uint16_t length);


unsigned char loadgame(void) {
    if (flash_load_file(0x1a, save_1a) != sizeof(save_1a)) {
        return 0;
    }
    if (flash_load_file(0x80, save_80) != sizeof(save_80)) {
        return 0;
    }
    return 1;
}


unsigned char savegame(void) {
    if (!flash_save_file(0x1a, save_1a, sizeof(save_1a))) {
        return 0;
    }
    if (!flash_save_file(0x80, save_80, sizeof(save_80))) {
        return 0;
    }
    return 1;
}
