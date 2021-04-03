

typedef struct _highlight {
    unsigned char x;
    unsigned char y;
    unsigned char l;
} highlight;


extern highlight *cursor_list[];


void select(unsigned char focus, unsigned char pos);
void deselect(unsigned char focus, unsigned char pos);
