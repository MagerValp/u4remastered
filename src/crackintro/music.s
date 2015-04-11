	.export music_init
	.export music_play


	.segment "MUSIC"

music_init	 = *
music_play	 = * + 3

	.incbin "alcorythm.sid", $7e
