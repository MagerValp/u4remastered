	.export EAPIInit


	.segment "EASYAPI"

EAPIInit = * + 20

	.incbin "eapi_driver.prg", 2
