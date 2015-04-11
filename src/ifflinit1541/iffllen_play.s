	.export map_iffl_len
	.export tlk_iffl_len
	.export dng_iffl_len
	.export gam_iffl_len


	.rodata

map_iffl_len:
	.include "files/iffl/map_iffl.i"

tlk_iffl_len:
	.include "files/iffl/tlk_iffl.i"

dng_iffl_len:
	.include "files/iffl/dng_iffl.i"

gam_iffl_len:
	.include "files/iffl/gam_play_iffl.i"
