	.export tilecolors0
	.export tilecolors1
	.export tilecolors2
	.export tilecolors3


	.segment "TILEBITMAP"
	
	.incbin "src/tiles/tileset.bin", 0, $2000


	.segment "GFXTABLES"

	.incbin "files/patched/14c.prg", 2, $1b0
tilecolors0:
	.incbin "src/tiles/tileset.bin", $2000, $100
	.incbin "src/tiles/font.bin", $0400, $80
	.incbin "files/patched/14c.prg", 2 + $1b0 + $100 + $80, $d0


	.segment "COLORS1"

tilecolors1:
	.incbin "src/tiles/tileset.bin", $2100, $100


	.segment "COLORS2"

tilecolors2:
	.incbin "src/tiles/tileset.bin", $2200, $100


	.segment "COLORS3"

tilecolors3:
	.incbin "src/tiles/tileset.bin", $2300, $100


	.segment "FONT"
	
	.incbin "src/tiles/font.bin", 0, $0400
