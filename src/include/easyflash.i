; A:value XY:addr -> C:error
EAPIWriteFlash		= $df80
; A:bank Y:baseaddr -> C:error
EAPIEraseSector		= $df83
; A:bank
EAPISetBank		= $df86
; -> A:bank
EAPIGetBank		= $df89
; A:bankmode XY:addr
EAPISetPtr		= $df8c
; XYA:length
EAPISetLen		= $df8f
; -> A:value C:eof
EAPIReadFlashInc	= $df92
; A:value -> C:error
EAPIWriteFlashInc	= $df95
; A:slot
EAPISetSlot		= $df98

ef_bank		= $de00
ef_control	= $de02
ef_ram		= $df00
EF_LED		= %10000000
EF_8K		= %00000110
EF_16K		= %00000111
EF_KILL		= %00000100

EF_ERASE_ROML	= $80
EF_ERASE_ROMH	= $e0

EF_MODE_ALT	= $d0
EF_MODE_LO	= $b0
EF_MODE_HI	= $d4
