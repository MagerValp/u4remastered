# Compiler settings for target platform.
TARGET=c64
CC65=cl65
AS65=ca65
LD65=ld65
CC65FLAGS=-Oirs -t $(TARGET)
AS65FLAGS=-t $(TARGET) -I . -I src/include --debug-info
LD65FLAGS=

# Compiler settings for host platform.
#CC=clang
CFLAGS=-O

# Select source directory for game save files.
SAVEGAME=untouched
#SAVEGAME=test

# Select which bins to include when creating crt.
# Use these for testing:
#CRT_BINS=src/easyflash/padded.bin src/easyflash/efssg.bin
# Use this for releasing:
CRT_BINS=src/easyflash/efs.bin

# Tweak to trade off compressed size for compression speed.
EXOMIZER_MAX_OFFSET=65535


%.o: %.c
	$(CC65) -c $(CC65FLAGS) $<

%.o: %.s
	$(AS65) $(AS65FLAGS) $<


all: u4remastered.d81 u4remastered.d71 u4remastered-a.d64 u4remastered-b.d64 u4remastered.crt


# Tools.

tools/backpack: tools/backpack.c
	$(CC) $(CFLAGS) -o $@ $^

clean_tools:
	rm -f tools/*.pyc
	rm -f tools/backpack


# Game files.

MAP_FILES = $(shell python3 -c 'for x in range(256): print("map_%02x" % x)')
TLK_FILES = $(shell python3 -c 'for x in range(256): print("tlk_%02x" % x)')
DNG_FILES = $(shell python3 -c 'for x in range(176): print("dng_%02x" % x)')

# Changing these requires a clean rebuild.
BOOT_FILES = \
	117 141 142 143 144 14c 14d 14f \
	150 155 156 19e
PROGRAM_FILES = \
	118 141 145 146 147 148 149 14a \
	14b 151 152 153 154 156 157 158 \
	159 15a 15b 19f
BRITANNIA_FILES = \
	201 202 203 204 205 206 207 208 \
	209 20a 20b 20c 20d 20e 20f 21c \
	277 279 27a 27b 282 285 287 288 \
	289
TOWNE_FILES = \
	319 35c 35d 35e 35f 360 361 362 \
	363 364 365 366 367 368 369 36a \
	36b 36c 36d 36e 36f 370 371 372 \
	373 374 375 376 378 379 37a
UNDERWORLD_FILES = \
	40f 410 411 412 413 414 415 416 \
	477 479 47a 48c 48d 48e 48f 490 \
	491 492 493 495 49a 49b

GAM_FILES = $(PROGRAM_FILES) $(BRITANNIA_FILES) $(TOWNE_FILES) $(UNDERWORLD_FILES)

SAVEGAME_FILES = \
	files/savegame/$(SAVEGAME)/s1a \
	files/savegame/$(SAVEGAME)/s7e \
	files/savegame/$(SAVEGAME)/s7f \
	files/savegame/$(SAVEGAME)/s80


# Extract files from disk images.

DISK_IMAGES = \
	files/original/u4program.d64 \
	files/original/u4britannia.d64 \
	files/original/u4towne.d64 \
	files/original/u4underworld.d64

EXTRACTED_BOOT_FILES = $(patsubst %,files/extracted/%.prg,$(BOOT_FILES))
EXTRACTED_GAM_FILES = $(patsubst %,files/extracted/%.prg,$(GAM_FILES))
EXTRACTED_MAP_FILES = $(patsubst %,files/extracted/%.bin,$(MAP_FILES))
EXTRACTED_TLK_FILES = $(patsubst %,files/extracted/%.bin,$(TLK_FILES))
EXTRACTED_DNG_FILES = $(patsubst %,files/extracted/%.bin,$(DNG_FILES))

EXTRACT_TMP := $(shell mktemp -d -u -t u4remastered_XXXXXXXXXX)

files/extracted: $(DISK_IMAGES) files/filemap.txt tools/extract_files.py
	rm -rf $(EXTRACT_TMP)
	mkdir -p $(EXTRACT_TMP)
	tools/extract_files.py files/filemap.txt $(DISK_IMAGES) $(EXTRACT_TMP)
	c1541 $< -read "ultima" "$(EXTRACT_TMP)/ultima.prg"
	mv $(EXTRACT_TMP) $@

$(EXTRACTED_BOOT_FILES): files/extracted
$(EXTRACTED_GAM_FILES): files/extracted
$(EXTRACTED_MAP_FILES): files/extracted
$(EXTRACTED_TLK_FILES): files/extracted
$(EXTRACTED_DNG_FILES): files/extracted

clean_extracted:
	rm -rf files/extracted


# Patch game files.

files/patched: files/extracted
	mkdir -p $@
	touch $@

files/patched/%.prg: src/charcreate/%.koa | files/patched
	python3 -c 'import sys; sys.stdout.write("\x00\x40")' > $@
	dd if=$< of=$@ bs=1 skip=2    seek=2    count=5888 2> /dev/null
	dd if=$< of=$@ bs=1 skip=8002 seek=5890 count=768  2> /dev/null
	dd if=$< of=$@ bs=1 skip=9002 seek=6658 count=768  2> /dev/null

files/patched/%.prg: files/extracted/%.prg patches/%.binpatch | files/patched
	tools/binpatch.py $< $(word 2,$^) $@

files/patched/%.bin: files/extracted/%.bin patches/%.binpatch | files/patched
	tools/binpatch.py $< $(word 2,$^) $@

files/patched/%: files/extracted/% | files/patched
	cp $< $@

clean_patched:
	rm -rf files/patched


# Compress files.

COMPRESSED_GAM_FILES = $(patsubst %,files/compressed/%,$(GAM_FILES))
COMPRESSED_MAP_FILES = $(patsubst %,files/compressed/%,$(MAP_FILES))
COMPRESSED_TLK_FILES = $(patsubst %,files/compressed/%,$(TLK_FILES))
COMPRESSED_DNG_FILES = $(patsubst %,files/compressed/%,$(DNG_FILES))

files/compressed: files/extracted tools/backpack
	mkdir -p $@
	touch $@

files/compressed/%: files/patched/%.prg | files/compressed
	tools/backpack -q -s 2 $< $@
files/compressed/%: files/patched/%.bin | files/compressed
	tools/backpack -q $< $@

clean_compressed:
	rm -rf files/compressed


# Save game editor.

EDITOR_COMMON_OBJS = \
	src/editor/main.o \
	src/editor/savegame.o \
	src/editor/draw.o \
	src/editor/cursor.o \
	src/editor/stat.o \
	src/editor/edit.o

EDITOR_OBJS = \
	$(EDITOR_COMMON_OBJS) \
	src/editor/fileio.o

src/editor/editor.prg: $(EDITOR_OBJS) src/editor/editor.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/editor/editor.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(EDITOR_OBJS) --lib c64.lib || (rm -f $@ && exit 1)

files/compressed/editor: src/editor/editor.prg | files/compressed
	exomizer sfx sys -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<

EDITOR_FLASH_OBJS = \
	$(EDITOR_COMMON_OBJS) \
	src/editor/fileio_flash.o \
	src/easyflash/util.o \
	src/easyflash/eapi_driver.o \
	src/easyflash/easyapi.o

src/editor/editor_flash.prg: $(EDITOR_FLASH_OBJS) src/editor/editor.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/editor/editor.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(EDITOR_FLASH_OBJS) --lib c64.lib || (rm -f $@ && exit 1)

files/compressed/editor_flash: src/editor/editor_flash.prg | files/compressed
	exomizer sfx sys -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<

clean_editor:
	rm -f $(EDITOR_OBJS)
	rm -f src/editor/editor.prg
	rm -f src/editor/editor.map
	rm -f src/editor/editor.lab
	rm -f files/compressed/editor
	rm -f $(EDITOR_FLASH_OBJS)
	rm -f src/editor/editor_flash.prg
	rm -f src/editor/editor_flash.map
	rm -f src/editor/editor_flash.lab
	rm -f files/compressed/editor_flash


# Game main.

GAMEMAIN_COMMON_OBJS = \
	src/loadaddr.o \
	src/gamemain/gamemain.o \
	src/gamemain/patchmain.o \
	src/trainer/trainerroutines.o

src/gamemain/gamemain.o: files/patched/15b.prg

src/gamemain/patchmain.o: src/include/trainer.i src/include/u4loader.i

GAMEMAIN_OBJS = \
	$(GAMEMAIN_COMMON_OBJS) \
	src/gamemain/dummy_flipdisk.o

src/gamemain/gamemain.prg: $(GAMEMAIN_OBJS) src/gamemain/gamemain.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/gamemain/gamemain.cfg \
		-o $@ $(LD65FLAGS) $(GAMEMAIN_OBJS) || (rm -f $@ && exit 1)

files/compressed/15b: src/gamemain/gamemain.prg | files/compressed
	tools/backpack -q -s 2 $< $@

GAMEMAIN1541_OBJS = \
	$(GAMEMAIN_COMMON_OBJS) \
	$(U4LOADER_OBJS) \
	src/ifflinit1541/flipdisk.o \
	src/ifflinit1541/iffllen_play.o \
	src/ifflinit/ifflscanner.o \
	$(IFFLLOADER_OBJS)

src/ifflinit1541/iffllen_play.o: files/iffl/gam_play_iffl.i

src/gamemain/gamemain_1541.prg: $(GAMEMAIN1541_OBJS) src/gamemain/gamemain.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/gamemain/gamemain.cfg \
		-o $@ $(LD65FLAGS) $(GAMEMAIN1541_OBJS) || (rm -f $@ && exit 1)

files/compressed/15b_1541: src/gamemain/gamemain_1541.prg | files/compressed
	tools/backpack -q -s 2 $< $@

clean_gamemain:
	rm -f $(GAMEMAIN_OBJS) $(GAMEMAIN1541_OBJS)
	rm -f src/gamemain/gamemain.prg
	rm -f src/gamemain/gamemain.map
	rm -f src/gamemain/gamemain_1541.prg
	rm -f src/gamemain/gamemain_1541.map
	rm -f files/compressed/15b
	rm -f files/compressed/15b_1541


# Tiles and font.

src/tiles/tileset.bin: src/tiles/tiles.png
	tools/gen_tiles.py $< $@

TILEBITMAP_OBJS = \
	src/loadaddr.o \
	src/tiles/tilecolors.o

src/tiles/tilebitmap.prg: $(TILEBITMAP_OBJS) src/tiles/tilebitmap.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/tiles/tilebitmap.cfg \
		-o $@ $(LD65FLAGS) $(TILEBITMAP_OBJS) || (rm -f $@ && exit 1)

files/compressed/141: src/tiles/tilebitmap.prg
	tools/backpack -s 2 $< $@

src/tiles/font.bin: src/tiles/font.png
	tools/gen_font.py $< $@

clean_tiles:
	rm -f src/tiles/font.bin
	rm -f src/tiles/tileset.bin
	rm -f src/tiles/tilebitmap.prg
	rm -f src/tiles/tilebitmap.map


# Character creation.

CHARCREATE_OBJS = \
	src/loadaddr.o \
	src/charcreate/charcreate.o \
	src/charcreate/cardcolors.o

src/charcreate/charcreate.o: files/patched/151.prg

src/charcreate/charcreate.prg: $(CHARCREATE_OBJS) src/charcreate/charcreate.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/charcreate/charcreate.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(CHARCREATE_OBJS) || (rm -f $@ && exit 1)

files/compressed/151: src/charcreate/charcreate.prg | files/compressed
	tools/backpack -q -s 2 $< $@

CARDCOLORS_OBJS = \
 	src/loadaddr.o \
	src/charcreate/cardcolors.o

CARD_KOALAS = src/charcreate/cards1.koa src/charcreate/cards2.koa

files/patched/152.prg: tools/gen_cards.py $(CARD_KOALAS) | files/patched
	$< $(CARD_KOALAS) $@ files/patched/19f.prg

files/patched/19f.prg: files/patched/152.prg
	touch $@

src/charcreate/cardcolors.o: files/patched/19f.prg

files/compressed/19f: src/charcreate/cardcolors.prg | files/compressed
	tools/backpack -q -s 2 $< $@

src/charcreate/cardcolors.prg: $(CARDCOLORS_OBJS) src/charcreate/cardcolors.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/charcreate/cardcolors.cfg \
		-o $@ $(LD65FLAGS) $(CARDCOLORS_OBJS) || (rm -f $@ && exit 1)

clean_charcreate:
	rm -f $(CHARCREATE_OBJS)
	rm -f src/charcreate/charcreate.prg
	rm -f src/charcreate/charcreate.map
	rm -f src/charcreate/charcreate.lab
	rm -f files/compressed/151
	rm -f $(CARDCOLORS_OBJS)
	rm -f src/charcreate/cardcolors.prg
	rm -f src/charcreate/cardcolors.map
	rm -f files/compressed/19f


# Talk.

PATCHED_TLK_FILES = $(patsubst %,files/patched/%.bin,$(TLK_FILES))

files/patched/tlk_00.bin: tools/gen_talk.py src/talk/talk.json | files/patched
	tools/gen_talk.py src/talk/talk.json files/patched
	@touch $@

$(filter-out files/patched/tlk_00.bin,$(PATCHED_TLK_FILES)): files/patched/tlk_00.bin src/talk/talk.json
	@touch $@

TALK_OBJS = \
	src/loadaddr.o \
	src/talk/talk.o

files/patched/378.prg: src/talk/talk.prg | files/patched
	cp $< $@

src/talk/talk.prg: $(TALK_OBJS)
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/talk/talk.cfg \
		-o $@ $(LD65FLAGS) $(TALK_OBJS) || (rm -f $@ && exit 1)

clean_talk:
	rm -f files/patched/tlk_??.bin
	rm -f $(TALK_OBJS)
	rm -f src/talk/talk.prg
	rm -f src/talk/talk.map


# Patched game files.

clean_patchedgame: \
		clean_lord_british \
		clean_shops \
		clean_search \
		clean_use \
		clean_shrine \
		clean_camp \
		clean_end_game \
		clean_subs \
		clean_dungeon \
		clean_peer
	rm -f src/patchedgame/*.o
	rm -f src/patchedgame/*.prg
	rm -f src/patchedgame/*.map
	rm -f src/patchedgame/*.lab

# Subroutines.

files/patched/14f.prg: src/patchedgame/subs.prg | files/patched
	cp $< $@

src/patchedgame/subs.prg: src/patchedgame/subs.o src/patchedgame/subs.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/patchedgame/subs.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $< src/loadaddr.o || (rm -f $@ && exit 1)

clean_subs:
	rm -f files/patched/14f.prg

# Dungeon.

files/patched/495.prg: src/patchedgame/dungeon.prg | files/patched
	cp $< $@

src/patchedgame/dungeon.prg: src/patchedgame/dungeon.o src/patchedgame/dungeon.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/patchedgame/dungeon.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $< src/loadaddr.o || (rm -f $@ && exit 1)

clean_dungeon:
	rm -f files/patched/495.prg

# Peer at a gem.

files/patched/277.prg: src/patchedgame/peer_surface.prg | files/patched
	cp $< $@

files/patched/477.prg: src/patchedgame/peer_underworld.prg | files/patched
	cp $< $@

src/patchedgame/peer_%.prg: src/patchedgame/peer_%.o src/patchedgame/peer.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/patchedgame/peer.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $< src/loadaddr.o || (rm -f $@ && exit 1)

clean_peer:
	rm -f files/patched/277.prg
	rm -f files/patched/477.prg

# Lord British.

files/patched/287.prg: src/patchedgame/lord_british_talk.prg | files/patched
	cp $< $@

files/patched/288.prg: src/patchedgame/lord_british_help.prg | files/patched
	cp $< $@

clean_lord_british:
	rm -f files/patched/287.prg
	rm -f files/patched/288.prg

# Shops.
# (Identical to original, except where BUG FIX noted in .s files,
# reconstructed to allow more bytes for text corrections.)

files/patched/36d.prg: src/patchedgame/shop_weapons.prg | files/patched
	cp $< $@

files/patched/36e.prg: src/patchedgame/shop_armour.prg | files/patched
	cp $< $@

files/patched/372.prg: src/patchedgame/shop_healer.prg | files/patched
	cp $< $@

files/patched/376.prg: src/patchedgame/seer.prg | files/patched
	cp $< $@

clean_shops:
	rm -f files/patched/36d.prg
	rm -f files/patched/36e.prg
	rm -f files/patched/372.prg
	rm -f files/patched/376.prg

# Search.

files/patched/279.prg: src/patchedgame/search_britannia.prg | files/patched
	cp $< $@

files/patched/379.prg: src/patchedgame/search_towne.prg | files/patched
	cp $< $@

files/patched/479.prg: src/patchedgame/search_underworld.prg | files/patched
	cp $< $@

clean_search:
	rm -f files/patched/279.prg
	rm -f files/patched/379.prg
	rm -f files/patched/479.prg

# Use.

files/patched/27a.prg: src/patchedgame/use_britannia.prg | files/patched
	cp $< $@

files/patched/37a.prg: src/patchedgame/use_towne.prg | files/patched
	cp $< $@

files/patched/47a.prg: src/patchedgame/use_underworld.prg | files/patched
	cp $< $@

clean_use:
	rm -f files/patched/27a.prg
	rm -f files/patched/37a.prg
	rm -f files/patched/47a.prg

# Shrine.

files/patched/282.prg: src/patchedgame/shrine.prg | files/patched
	cp $< $@

clean_shrine:
	rm -f files/patched/282.prg

# Camp.

files/patched/285.prg: src/patchedgame/camp.prg | files/patched
	cp $< $@

clean_camp:
	rm -f files/patched/285.prg

# End game.

files/patched/49a.prg: src/patchedgame/end_game.prg | files/patched
	cp $< $@

clean_end_game:
	rm -f files/patched/49a.prg

# Implicit rule.

src/patchedgame/%.prg: src/patchedgame/%.o src/patchedgame/overlay8800.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/patchedgame/overlay8800.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $< src/loadaddr.o || (rm -f $@ && exit 1)


# Loader.

U4INIT_OBJS = \
	src/u4loader/u4init.o

U4LOADER_OBJS = \
	src/u4loader/u4loader.o \
	src/u4loader/filemap.o \
	src/u4loader/tempmap.o \
	src/u4loader/lzmv.o

TRAINER_OBJS = \
	src/trainer/trainerroutines.o \
	src/trainer/trainer.o

PRELOAD_OBJS = \
	src/u4loader/loadscreen.o \
	src/u4loader/preload.o

TILE_OBJS = \
	src/tiles/tilecolors.o \
	src/tiles/drawview.o \
	src/tiles/drawviewtitle.o

src/trainer/trainerroutines.o src/u4loader/tempmap.o src/u4loader/u4loader.o: src/include/u4loader.i

src/u4loader/loadscreen.o: src/u4loader/loadscreen.bin

src/u4loader/preload.o: \
	files/patched/117.prg \
	files/patched/142.prg \
	src/tiles/titlebitmap.prg \
	files/patched/144.prg \
	files/patched/14d.prg \
	files/patched/14f.prg \
	files/patched/150.prg \
	files/patched/155.prg \
	files/patched/156.prg \
	src/tiles/titlecolors.prg

src/u4loader/filemap.s: tools/gen_filemap.py files/filemap.txt
	tools/gen_filemap.py files/filemap.txt $@ $(GAM_FILES)

clean_loader:
	rm -f src/u4loader/filemap.s


# IFFL loader.

IFFLLOADER_OBJS = \
	src/ifflloader/ifflloader.o \
	src/ifflloader/ifflbss.o

IFFLINIT_OBJS = \
	src/ifflinit/loaderinit.o \
	src/ifflinit/drivedetect.o \
	src/ifflinit/ifflscanner.o

DRIVECODE_OBJS = \
	src/drivecode/drivecode.o \
	src/drivecode/drivecode_1541.o \
	src/drivecode/drivecode_1571.o \
	src/drivecode/drivecode_1581.o \
	src/drivecode/drivecode_cmdhd.o \
	src/drivecode/drivecode_cmdfd.o

LOADER_COMMON_OBJS = \
	src/loadaddr.o \
	$(U4INIT_OBJS) \
	$(U4LOADER_OBJS) \
	$(IFFLLOADER_OBJS) \
	$(IFFLINIT_OBJS) \
	$(DRIVECODE_OBJS) \
	$(TRAINER_OBJS) \
	$(PRELOAD_OBJS) \
	$(TILE_OBJS)

files/iffl/iffl_file_count.i: | files/iffl
	@echo "num_map_files = $$(echo $(MAP_FILES) | wc -w)" > $@
	@echo "num_tlk_files = $$(echo $(TLK_FILES) | wc -w)" >> $@
	@echo "num_dng_files = $$(echo $(DNG_FILES) | wc -w)" >> $@
	@echo "num_gam_files = $$(echo $(GAM_FILES) | wc -w)" >> $@

src/ifflinit/ifflscanner.o: files/iffl/iffl_file_count.i

src/ifflloader/ifflbss.o: files/iffl/iffl_file_count.i

src/ifflinit/iffllen.o: \
	files/iffl/map_iffl.i \
	files/iffl/tlk_iffl.i \
	files/iffl/dng_iffl.i \
	files/iffl/gam_iffl.i

LOADER_OBJS = $(LOADER_COMMON_OBJS) src/ifflinit/iffllen.o
LOADER1541_OBJS = $(LOADER_COMMON_OBJS) src/ifflinit1541/iffllen_program.o

src/tiles/tilecolors.o: files/patched/14c.prg src/tiles/tileset.bin src/tiles/font.bin

src/trainer/trainer.o: src/include/trainer.i

src/loader.prg: $(LOADER_OBJS) src/loader.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/loader.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(LOADER_OBJS) || (rm -f $@ && exit 1)

files/compressed/loader: src/loader.prg | files/compressed
	exomizer sfx 0x2000 -x 'sta $$dbe7' -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<

src/ifflinit1541/iffllen_program.o: files/iffl/gam_program_iffl.i

src/loader1541.prg: $(LOADER1541_OBJS) src/loader.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/loader.cfg -o $@ $(LD65FLAGS) $(LOADER1541_OBJS) || (rm -f $@ && exit 1)

files/compressed/loader1541: src/loader1541.prg | files/compressed
	exomizer sfx 0x2000 -x 'sta $$dbe7' -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<

clean_ifflloader:
	rm -f files/iffl/iffl_file_count.i
	rm -f $(LOADER_OBJS)
	rm -f src/loader.prg
	rm -f src/loader.map
	rm -f src/loader.lab
	rm -f files/compressed/loader
	rm -f $(LOADER1541_OBJS)
	rm -f src/loader1541.prg
	rm -f src/loader1541.map
	rm -f files/compressed/loader1541


# EasyFlash loader.

EFLOADER_OBJS = \
	src/loadaddr.o \
	$(U4INIT_OBJS) \
	$(U4LOADER_OBJS) \
	src/efloader/efloader.o \
	src/efloader/efsbank.o \
	src/efloader/easyflash.o \
	$(TRAINER_OBJS) \
	$(PRELOAD_OBJS) \
	$(TILE_OBJS)

src/efloader/efloader.o src/efloader/efsbank.o: files/easyflash/efs.i

src/efloader.prg: $(EFLOADER_OBJS) src/efloader.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/efloader.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(EFLOADER_OBJS) || (rm -f $@ && exit 1)

files/compressed/efloader: src/efloader.prg | files/compressed
	exomizer sfx 0x2000 -x 'sta $$dbe7' -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<

clean_efloader:
	rm -f $(EFLOADER_OBJS)
	rm -f src/efloader.prg
	rm -f src/efloader.map
	rm -f src/efloader.lab
	rm -f files/compressed/efloader


# Prepare iffl.

files/iffl:
	mkdir -p $@
	touch $@

files/zero: $(COMPRESSED_GAM_FILES)
	mkdir -p $@
	touch $@

files/zero/%: files/compressed/% | files/zero
	touch $@

files/iffl/map_iffl.i: $(COMPRESSED_MAP_FILES) | files/iffl
	tools/makeifflshort.py files/iffl/map_iffl files/iffl/map_iffl.i files/compressed/map_??
files/iffl/map_iffl: files/iffl/map_iffl.i
	touch $@

files/iffl/tlk_iffl.i: $(COMPRESSED_TLK_FILES) | files/iffl
	tools/makeifflshort.py files/iffl/tlk_iffl files/iffl/tlk_iffl.i files/compressed/tlk_??
files/iffl/tlk_iffl: files/iffl/tlk_iffl.i
	touch $@

files/iffl/dng_iffl.i: $(COMPRESSED_DNG_FILES) | files/iffl
	tools/makeifflshort.py files/iffl/dng_iffl files/iffl/dng_iffl.i files/compressed/dng_??
files/iffl/dng_iffl: files/iffl/dng_iffl.i
	touch $@

files/iffl/gam_iffl.i: $(COMPRESSED_GAM_FILES) | files/iffl
	tools/makeiffllong.py files/iffl/gam_iffl files/iffl/gam_iffl.i files/compressed/[1-4]??
files/iffl/gam_iffl: files/iffl/gam_iffl.i
	touch $@

COMPRESSED_GAM_1541PROGRAM_FILES = \
	files/compressed/118 \
	files/zero/141 \
	files/compressed/145 \
	files/compressed/146 \
	files/compressed/147 \
	files/compressed/148 \
	files/compressed/149 \
	files/compressed/14a \
	files/compressed/14b \
	files/compressed/151 \
	files/compressed/152 \
	files/compressed/153 \
	files/compressed/154 \
	files/compressed/156 \
	files/compressed/157 \
	files/compressed/158 \
	files/compressed/159 \
	files/compressed/15a \
	files/compressed/15b_1541 \
	files/compressed/19f \
	$(patsubst %,files/zero/%,$(BRITANNIA_FILES) $(TOWNE_FILES) $(UNDERWORLD_FILES))

files/iffl/gam_program_iffl.i: $(COMPRESSED_GAM_1541PROGRAM_FILES) | files/iffl files/zero
	tools/makeiffllong.py files/iffl/gam_program_iffl files/iffl/gam_program_iffl.i $(COMPRESSED_GAM_1541PROGRAM_FILES)
files/iffl/gam_program_iffl: files/iffl/gam_program_iffl.i
	touch $@

COMPRESSED_GAM_1541PLAY_FILES = \
	files/zero/118 \
	files/compressed/141 \
	files/zero/145 \
	files/zero/146 \
	files/zero/147 \
	files/zero/148 \
	files/zero/149 \
	files/zero/14a \
	files/zero/14b \
	files/zero/151 \
	files/zero/152 \
	files/zero/153 \
	files/zero/154 \
	files/compressed/156 \
	files/compressed/157 \
	files/compressed/158 \
	files/compressed/159 \
	files/compressed/15a \
	files/zero/15b \
	files/zero/19f \
	$(patsubst %,files/compressed/%,$(BRITANNIA_FILES) $(TOWNE_FILES) $(UNDERWORLD_FILES))

files/iffl/gam_play_iffl.i: $(COMPRESSED_GAM_1541PLAY_FILES) | files/iffl files/zero
	tools/makeiffllong.py files/iffl/gam_play_iffl files/iffl/gam_play_iffl.i $(COMPRESSED_GAM_1541PLAY_FILES)
files/iffl/gam_play_iffl: files/iffl/gam_play_iffl.i
	touch $@

clean_iffl:
	rm -rf files/iffl

clean_zero:
	rm -rf files/zero


# Prepare EasyFlash.

EFS_START_BANK = 6
EASYFLASH_SAVE_BANK = 48
EASYFLASH_SAVE_SIZE = 16

files/easyflash:
	mkdir -p $@
	touch $@

files/easyflash/map.efs: $(COMPRESSED_MAP_FILES) tools/makeefs.py | files/easyflash
	tools/makeefs.py short $@ $(COMPRESSED_MAP_FILES)

files/easyflash/tlk.efs: $(COMPRESSED_TLK_FILES) tools/makeefs.py | files/easyflash
	tools/makeefs.py short $@ $(COMPRESSED_TLK_FILES)

files/easyflash/dng.efs: $(COMPRESSED_DNG_FILES) tools/makeefs.py | files/easyflash
	tools/makeefs.py short $@ $(COMPRESSED_DNG_FILES)

files/easyflash/gam.efs: $(COMPRESSED_GAM_FILES) tools/makeefs.py | files/easyflash
	tools/makeefs.py long $@ $(COMPRESSED_GAM_FILES)

EFS_FILES = \
	files/easyflash/gam.efs \
	files/easyflash/map.efs \
	files/easyflash/tlk.efs \
	files/easyflash/dng.efs \

files/easyflash/efs.i: $(EFS_FILES) tools/gen_efs_i.py | files/easyflash
	tools/gen_efs_i.py $(EFS_START_BANK) $(EASYFLASH_SAVE_BANK) $@ $(EFS_FILES)

clean_easyflash:
	rm -rf files/easyflash


# Intro.

COMMON_INTRO_OBJS = \
	src/crackintro/init.o \
	src/crackintro/fadebasic.o \
	src/crackintro/main.o \
	src/crackintro/irq.o \
	src/crackintro/music.o \
	src/crackintro/gfx.o \
	src/crackintro/swing.o \
	src/crackintro/swingdata.o \
	src/crackintro/text.o

INTRO_OBJS = \
	$(COMMON_INTRO_OBJS) \
	src/crackintro/startup.o

INTRO1541_OBJS = \
	$(COMMON_INTRO_OBJS) \
	src/crackintro/startup1541.o

INTROEF_OBJS = \
	$(COMMON_INTRO_OBJS) \
	src/crackintro/startupef.o

src/crackintro/swingdata.o: src/crackintro/swingdata.s
src/crackintro/swingdata.s: src/crackintro/swingdata.py
	$< 2170 $@

src/crackintro/music.o: src/crackintro/alcorythm.sid

src/crackintro/startup.o: files/compressed/loader

src/crackintro/intro.prg: $(INTRO_OBJS) src/crackintro/intro.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/crackintro/intro.cfg -o $@ $(LD65FLAGS) $(INTRO_OBJS)

files/compressed/u4remastered: src/crackintro/intro.prg | files/compressed
	exomizer sfx sys -m $(EXOMIZER_MAX_OFFSET) -q -o $@ $<


src/crackintro/startup1541.o: files/compressed/loader1541

src/crackintro/intro1541.prg: $(INTRO1541_OBJS) src/crackintro/intro.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/crackintro/intro.cfg -o $@ $(LD65FLAGS) $(INTRO1541_OBJS)

files/compressed/u4remastered1541: src/crackintro/intro1541.prg | files/compressed
	exomizer sfx sys -q -m $(EXOMIZER_MAX_OFFSET) -o $@ $<


src/crackintro/startupef.o: files/compressed/cartmenu

src/crackintro/introef.prg: $(INTROEF_OBJS) src/crackintro/intro.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/crackintro/intro.cfg -o $@ $(LD65FLAGS) $(INTROEF_OBJS)

files/compressed/cartmenu_intro: src/crackintro/introef.prg | files/compressed
	tools/backpack -q -s 2 $< $@

clean_intro:
	rm -f src/crackintro/swingdata.s
	rm -f $(INTRO_OBJS)
	rm -f src/crackintro/intro.prg
	rm -f src/crackintro/intro.map
	rm -f files/compressed/u4remastered
	rm -f $(INTRO1541_OBJS)
	rm -f src/crackintro/intro1541.prg
	rm -f src/crackintro/intro1541.map
	rm -f files/compressed/u4remastered1541
	rm -f $(INTROEF_OBJS)
	rm -f src/crackintro/introef.prg
	rm -f src/crackintro/introef.map
	rm -f files/compressed/cartmenu_intro


# Create disk images.

APPS = files/compressed/u4remastered files/compressed/editor
IFFL_COMMON = files/iffl/map_iffl files/iffl/tlk_iffl files/iffl/dng_iffl

u4remastered.d81: files/compressed/u4remastered files/compressed/editor $(IFFL_COMMON) files/iffl/gam_iffl $(SAVEGAME_FILES)
	@echo "Creating $@"
	@rm -f $@
	@c1541 >/dev/null -format "u4 remastered/gp,mv" d81 $@
	@c1541 >/dev/null -attach $@ \
		-write files/compressed/u4remastered "ultima iv" \
		-write files/compressed/editor "save game editor" \
		-write files/savegame/$(SAVEGAME)/s1a "s1a" \
		-write files/savegame/$(SAVEGAME)/s7e "s7e" \
		-write files/savegame/$(SAVEGAME)/s7f "s7f" \
		-write files/savegame/$(SAVEGAME)/s80 "s80" \
		-write files/iffl/map_iffl "map" \
		-write files/iffl/tlk_iffl "tlk" \
		-write files/iffl/dng_iffl "dng" \
		-write files/iffl/gam_iffl "gam"

u4remastered.d71: files/compressed/u4remastered files/compressed/editor $(IFFL_COMMON) files/iffl/gam_iffl $(SAVEGAME_FILES)
	@echo "Creating $@"
	@rm -f $@
	@c1541 >/dev/null -format "u4 remastered/gp,mv" d71 $@
	@c1541 >/dev/null -attach $@ \
		-write files/compressed/u4remastered "ultima iv" \
		-write files/compressed/editor "save game editor" \
		-write files/savegame/$(SAVEGAME)/s1a "s1a" \
		-write files/savegame/$(SAVEGAME)/s7e "s7e" \
		-write files/savegame/$(SAVEGAME)/s7f "s7f" \
		-write files/savegame/$(SAVEGAME)/s80 "s80" \
		-write files/iffl/map_iffl "map" \
		-write files/iffl/tlk_iffl "tlk" \
		-write files/iffl/dng_iffl "dng" \
		-write files/iffl/gam_iffl "gam"

u4remastered-a.d64: files/compressed/u4remastered1541 $(IFFL_COMMON) files/iffl/gam_program_iffl
	@echo "Creating $@"
	@rm -f $@
	@c1541 >/dev/null -format "u4 remastered/gp,4a" d64 $@
	@c1541 >/dev/null -attach $@ \
		-write files/compressed/u4remastered1541 "ultima iv 1541" \
		-write files/iffl/gam_program_iffl "gam" \

u4remastered-b.d64: files/compressed/editor $(IFFL_COMMON) files/iffl/gam_play_iffl $(SAVEGAME_FILES)
	@echo "Creating $@"
	@rm -f $@
	@c1541 >/dev/null -format "u4 remastered/gp,4b" d64 $@
	@c1541 >/dev/null -attach $@ \
		-write files/compressed/editor "save game editor" \
		-write files/savegame/$(SAVEGAME)/s1a "s1a" \
		-write files/savegame/$(SAVEGAME)/s7e "s7e" \
		-write files/savegame/$(SAVEGAME)/s7f "s7f" \
		-write files/savegame/$(SAVEGAME)/s80 "s80" \
		-write files/iffl/map_iffl "map" \
		-write files/iffl/tlk_iffl "tlk" \
		-write files/iffl/dng_iffl "dng" \
		-write files/iffl/gam_play_iffl "gam"

clean_diskimages:
	rm -f u4remastered-a.d64 u4remastered-b.d64 u4remastered.d71 u4remastered.d81


# Create cartridge image.

EASYFLASH_OBJS = \
	src/easyflash/startup.o \
	src/easyflash/cartridge.o \
	src/easyflash/startmenu.o \
	src/u4loader/lzmv.o \
	src/easyflash/eapi_driver.o \
	src/easyflash/game.o \
	src/easyflash/editor.o

CARTMENU_OBJS = \
	src/easyflash/main.o \
	src/easyflash/easyapi.o \
	src/easyflash/startgame.o \
	src/easyflash/starteditor.o \
	src/easyflash/backup.o \
	src/easyflash/monitor.o \
	src/easyflash/util.o \
	src/easyflash/eapi_driver.o \
	src/easyflash/game.o \
	src/easyflash/editor.o

src/easyflash/eapi_driver.o: src/easyflash/eapi_driver.prg

src/easyflash/game.o: src/efloader.prg

src/easyflash/editor.o: files/compressed/editor_flash

src/easyflash/cartmenu.prg: $(CARTMENU_OBJS) src/easyflash/cartmenu.cfg
	$(LD65) -m $(patsubst %.prg,%.map,$@) -C src/easyflash/cartmenu.cfg \
		-Ln $(patsubst %.prg,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(CARTMENU_OBJS) --lib c64.lib || (rm -f $@ && exit 1)

files/compressed/cartmenu: src/easyflash/cartmenu.prg | files/compressed
	exomizer sfx sys -m $(EXOMIZER_MAX_OFFSET) -n -q -o $@ $<

src/easyflash/startmenu.o: files/compressed/cartmenu_intro

src/easyflash/menu.bin: $(EASYFLASH_OBJS) src/easyflash/easyflash.cfg
	$(LD65) -m $(patsubst %.bin,%.map,$@) -C src/easyflash/easyflash.cfg \
		-Ln $(patsubst %.bin,%.lab,$@) \
		-o $@ $(LD65FLAGS) $(EASYFLASH_OBJS) --lib c64.lib || (rm -f $@ && exit 1)

src/easyflash/efs.bin: src/easyflash/menu.bin $(EFS_FILES)
	cat $^ > $@

src/easyflash/padded.bin: src/easyflash/efs.bin
	python3 -c "import sys; sys.stdout.write('\xff' * 0x4000 * $(EASYFLASH_SAVE_BANK))" > $@
	dd if=$< of=$@ bs=16k conv=notrunc 2> /dev/null

src/easyflash/efssg.bin: $(SAVEGAME_FILES)
	tools/makeefssg.py $(EASYFLASH_SAVE_SIZE) $@ $(SAVEGAME_FILES)

u4remastered.crt: $(CRT_BINS)
	@echo "Creating $@"
	cat $^ > src/easyflash/easyflash.bin
	tools/gen_ef_crt.py src/easyflash/easyflash.bin $@
	rm -f src/easyflash/easyflash.bin

clean_cartridge:
	rm -f $(CARTMENU_OBJS)
	rm -f src/easyflash/cartmenu.prg
	rm -f src/easyflash/cartmenu.map
	rm -f src/easyflash/cartmenu.lab
	rm -f files/compressed/cartmenu
	rm -f $(EASYFLASH_OBJS)
	rm -f src/easyflash/menu.bin
	rm -f src/easyflash/menu.map
	rm -f src/easyflash/menu.lab
	rm -f src/easyflash/easyflash.bin
	rm -f src/easyflash/efs.bin
	rm -f src/easyflash/efssg.bin
	rm -f src/easyflash/padded.bin
	rm -f u4remastered.crt


clean_tempfiles:
	find . -name '*.bak' -delete
	find . -name '*.orig' -delete
	find . -name '*.\~*' -delete


.PHONY: clean
clean: 		clean_patched \
		clean_compressed \
		clean_editor \
		clean_gamemain \
		clean_tiles \
		clean_charcreate \
		clean_talk \
		clean_patchedgame \
		clean_loader \
		clean_ifflloader \
		clean_efloader \
		clean_iffl \
		clean_easyflash \
		clean_intro \
		clean_diskimages \
		clean_cartridge

distclean: 	clean \
		clean_extracted \
		clean_zero \
		clean_tools
