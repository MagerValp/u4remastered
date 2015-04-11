	.include "drivetype.i"


	.export start_game

	.import flipdisk


	.segment "MAIN_5B"

start_game:
	jmp flipdisk

	.incbin "files/patched/15b.prg", 5;, $4800-3
