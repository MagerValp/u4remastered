

	.export basicstub
	.export basiclen
	.export programstub
	
	.import init
	
	
	.segment "STARTUP"

	.word basicstub		; load address

basicstub:
	.word @nextline
	.word 2005
	.byte $9e
	.byte <(((init / 10000) .mod 10) + $30)
	.byte <(((init / 1000 ) .mod 10) + $30)
	.byte <(((init / 100  ) .mod 10) + $30)
	.byte <(((init / 10   ) .mod 10) + $30)
	.byte <(((init        ) .mod 10) + $30)
	.byte 0
@nextline:
	.word 0
basiclen = * - basicstub


	.incbin "files/compressed/loader1541", basiclen + 2

programstub:
	.incbin "files/compressed/loader1541", 2, basiclen
