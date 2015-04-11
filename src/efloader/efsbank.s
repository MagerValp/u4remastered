	.include "files/easyflash/efs.i"


	.export efs_bank

	.export efs_file_bank
	.export efs_offset_lo
	.export efs_offset_hi
	.export efs_length_lo
	.export efs_length_hi

	.export efsbank_start
	.export efsbank_end


	.import __EFSBANK_START__
	.import __EFSBANK_SIZE__


efsbank_start	= __EFSBANK_START__
efsbank_end	= __EFSBANK_START__ + __EFSBANK_SIZE__


	.segment "LOADER"

efs_bank:
	.byte gam_bank
	.byte map_bank
	.byte tlk_bank
	.byte dng_bank


	.segment "EFSBANK"

efs_file_bank:	.res 256
efs_offset_lo:	.res 256
efs_offset_hi:	.res 256
efs_length_lo:	.res 256
efs_length_hi:	.res 256
