	.exportzp editor_pages


	.segment "EDITOR"

editor_start:
	.byte 0
	.incbin "files/compressed/editor_flash", 2
editor_pages = (>*) - (>editor_start) + 1
