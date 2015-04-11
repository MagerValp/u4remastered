	.export screen
	.export sprptr
	.export screen2
	.export sprptr2

	.export genesis0
	.export genesis1
	.export genesis2
	.export genesis3
	.export genesis4


	.segment "GFX"

screen:
	.res 1000, $00
	.res 16, $00
sprptr:
	.res 8, $ff

screen2:
	.res 1000, $00
	.res 16, $00
sprptr2:
	.res 8, $ff


@sprites:
	.res 16 * 64, $5a
	.res 16 * 64, $5a
	.res 16 * 64, $5a
	.res 12 * 64, $5a

@m:
	.res 7 * 3, 0
	.res 14 * 3, $55
	.byte 0

@T:
	.res 14 * 3, $55
	.res 7 * 3, 0
	.byte 0

@_:
	;.res  3, $11
	;.res 61, $01
	.res 64, 0

@M:	
	;.res 3, $55
	;.res 57, $ff
	;.res 3, $aa
	;.res 1, 0
	.res 63, $55

@bfff:	
	.byte 0


	.data

m = $fc
T = $fd
_ = $fe
M = $ff

	.align $100
genesis0: .byte _,_,_,_,_,_,_,M,M,M,M,M,_,M,M,M,M,M,_,M,M,M,M,m,_,M,M,M,M,M,_,M,M,M,M,M,_,M,_,M,M,M,M,M,_,_,_,_,_,M,M,M,M,M,_,M,M,M,M,M,_,M,M,M,M,m,_,_,_,_,_,M,_,M,M,M,M,M,_,M,M,M,M,M,_,M,M,M,M,m,_,_,_,_,_,_,_,_
	.align $100
genesis1: .byte _,_,_,_,_,_,_,m,_,_,_,_,_,m,_,_,_,_,_,m,_,_,_,M,_,m,_,_,_,_,_,m,_,_,_,_,_,_,_,m,_,_,_,_,_,_,_,_,_,m,_,_,_,M,_,m,_,_,_,M,_,m,_,_,_,M,_,_,_,_,_,M,_,m,_,_,_,_,_,m,_,_,_,_,_,_,_,_,_,M,_,_,_,_,_,_,_,_
	.align $100
genesis2: .byte _,_,_,_,_,_,_,M,_,M,M,M,_,M,M,M,_,_,_,M,_,_,_,M,_,M,M,M,_,_,_,T,M,M,M,m,_,M,_,T,M,M,M,m,_,_,M,_,_,M,M,M,M,T,_,M,M,M,M,m,_,M,_,_,_,M,_,_,_,_,_,M,_,M,M,M,_,_,_,M,_,_,_,_,_,_,_,_,_,M,_,_,_,_,_,_,_,_
	.align $100
genesis3: .byte _,_,_,_,_,_,_,M,_,_,_,M,_,M,_,_,_,_,_,M,_,_,_,M,_,M,_,_,_,_,_,_,_,_,_,M,_,M,_,_,_,_,_,M,_,_,_,_,_,M,_,_,_,_,_,M,_,_,_,M,_,M,_,_,_,M,_,_,_,_,_,M,_,M,_,_,_,_,_,M,_,_,_,_,_,_,_,_,_,M,_,_,_,_,_,_,_,_
	.align $100
genesis4: .byte _,_,_,_,_,_,_,T,M,M,M,M,_,T,M,M,M,M,_,M,_,_,_,M,_,T,M,M,M,M,_,M,M,M,M,T,_,M,_,M,M,M,M,T,_,_,_,_,_,M,_,_,_,_,_,M,_,_,_,M,_,T,M,M,M,T,_,M,M,M,M,T,_,T,M,M,M,M,_,T,M,M,M,M,_,_,_,_,_,M,_,_,_,_,_,_,_,_
