	.export game_run
	.exportzp game_pages


	.segment "GAME"

game_run:
	.incbin "src/efloader.prg", 2
game_pages = (>*) - (>game_run) + 1
