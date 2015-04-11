	.export iffl_track
	.export map_track
	.export tlk_track
	.export dng_track
	.export gam_track

	.export iffl_sector
	.export map_sector
	.export tlk_sector
	.export dng_sector
	.export gam_sector

	.export iffl_offset
	.export map_offset
	.export tlk_offset
	.export dng_offset
	.export gam_offset


	.include "files/iffl/iffl_file_count.i"


	.segment "IFFLBSS"

	.align 256

iffl_track:
map_track:	.res num_map_files
tlk_track:	.res num_tlk_files
dng_track:	.res num_dng_files
gam_track:	.res num_gam_files

iffl_sector:
map_sector:	.res num_map_files
tlk_sector:	.res num_tlk_files
dng_sector:	.res num_dng_files
gam_sector:	.res num_gam_files

iffl_offset:
map_offset:	.res num_map_files
tlk_offset:	.res num_tlk_files
dng_offset:	.res num_dng_files
gam_offset:	.res num_gam_files
