typedef struct player {
    char name[16];
    unsigned char sex;              // $10
    unsigned char class;            // $11
    char status;                    // $12
    unsigned char strength;         // $13
    unsigned char dexterity;        // $14
    unsigned char intelligence;     // $15
    unsigned char mp;               // $16
    unsigned char classmask;        // $17
    unsigned char hp[2];            // $18
    unsigned char hpmax[2];         // $1a
    unsigned char experience[2];    // $1c
    unsigned char weapon;           // $1e
    unsigned char armor;            // $1f
} t_player;


extern unsigned char bit[];

extern unsigned char save_1a[0x20];
extern unsigned char save_80[0x200];
extern unsigned char loadaddr_1a[2];
extern unsigned char loadaddr_80[2];


extern t_player *player;


#define party_size save_1a[0x0f]
extern unsigned char *virtue;
#define torches save_80[0x108]
#define gems save_80[0x109]
#define keys save_80[0x10a]
#define sextant save_80[0x10b]
#define stones save_80[0x10c]
#define runes save_80[0x10d]
#define items save_80[0x10e]
#define threepartkey save_80[0x10f]
extern unsigned char *food;
extern unsigned char *gold;
#define horn save_80[0x115]
#define wheel save_80[0x116]
#define skull save_80[0x117]
extern unsigned char *armor;
extern unsigned char *weapon;
extern unsigned char *reagent;
extern unsigned char *mixture;
