TARGET=c64
CC=cl65
AS=ca65
LD=cl65 -t $(TARGET)
C1541=c1541
CFLAGS=-Oirs -t $(TARGET)
AFLAGS=


%.o: %.c
	$(CC) -c $(CFLAGS) $<

%.o: %.s
	$(AS) $(AFLAGS) $<


all: editor.d64


OBJS = \
	main.o \
	savegame.o \
	fileio.o \
	draw.o \
	cursor.o \
	stat.o \
	edit.o


editor.d64: editor.prg
	@rm -f $@
	c1541 -format "ultima iv editor,mv" d64 $@
	@c1541 -attach $@ \
		-write editor.prg "save game editor" \
		-write ../files/iffl/s1a "s1a" \
		-write ../files/iffl/s7e "s7e" \
		-write ../files/iffl/s7f "s7f" \
		-write ../files/iffl/s80 "s80"


editor.prg: $(OBJS)
	$(LD) -m editor.map -t $(TARGET) -o editor.prg $(AFLAGS) $^


clean:
	rm -f *.o
	rm -f editor.prg editor.map editor.d64


distclean: clean
	rm -f *~
