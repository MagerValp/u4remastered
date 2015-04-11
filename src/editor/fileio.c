#include <string.h>
#include <stdio.h>
#include <cbm.h>
#include <stddef.h>
#include "draw.h"
#include "savegame.h"
#include "fileio.h"


unsigned char dev = 0;


void readerror(void) {
    unsigned char msg[36];
    unsigned char *p;
    unsigned char *c;
    unsigned char s;

    memset(msg, 0, sizeof(msg));

    cbm_close(15);
    if ((s = cbm_open(15, dev, 15, ""))) {
        sprintf(msg, "I/O Error %d", s);
        draw_error(msg);
        return;
    }
    cbm_read(15, msg, sizeof(msg) - 1);
    cbm_close(1);

    if ((p = strstr(msg, ","))) {
        p = p + 1;
        while (*p == ' ') {
            ++p;
        }
        if ((c = strstr(p, ","))) {
            *c = 0;
        }
    } else {
        p = msg;
    }

    if (strcmp("ok", p)) {
        draw_error(p);
    } else {
        draw_error("");
    }  

}


unsigned char loadgame(void) {
    if (cbm_open(1, dev, 2, "s1a")) {
        goto error;
    }
    if (cbm_read(1, loadaddr_1a, 2) != 2) {
        cbm_close(1);
        goto error;
    }
    if (cbm_read(1, save_1a, sizeof(save_1a)) != sizeof(save_1a)) {
        cbm_close(1);
        goto error;
    }
    cbm_close(1);
    readerror();

    if (cbm_open(1, dev, 2, "s80")) {
        goto error;
    }
    if (cbm_read(1, loadaddr_80, 2) != 2) {
        cbm_close(1);
        goto error;
    }
    if (cbm_read(1, save_80, sizeof(save_80)) != sizeof(save_80)) {
        cbm_close(1);
        goto error;
    }
    cbm_close(1);
    readerror();

    return(1);

    error:
    readerror();
    return(0);
}


unsigned char savegame(void) {
    if (cbm_open(1, dev, 15, "s0:s1a")) {
        goto error;
    }
    cbm_close(1);
    readerror();

    if (cbm_open(1, dev, 2, "s1a,p,w")) {
        goto error;
    }

    if (cbm_write(1, loadaddr_1a, 2) != 2) {
        cbm_close(1);
        goto error;
    }
    if (cbm_write(1, save_1a, sizeof(save_1a)) != sizeof(save_1a)) {
        cbm_close(1);
        goto error;
    }
    cbm_close(1);
    readerror();

    if (cbm_open(1, dev, 15, "s0:s80")) {
        goto error;
    }
    cbm_close(1);
    readerror();

    if (cbm_open(1, dev, 2, "s80,p,w")) {
        goto error;
    }
    if (cbm_write(1, loadaddr_80, 2) != 2) {
        cbm_close(1);
        goto error;
    }
    if (cbm_write(1, save_80, sizeof(save_80)) != sizeof(save_80)) {
        cbm_close(1);
        goto error;
    }
    cbm_close(1);
    readerror();

    return(1);

    error:
    readerror();
    return(0);
}
