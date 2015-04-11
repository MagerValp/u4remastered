	.importzp track
	.importzp sector
	.importzp stack

	jmp drv_recv
	jmp drv_send
	jmp drv_readsector
	jmp drv_writesector
	jmp drv_flush
	jmp drv_get_dir_ts
	jmp drv_track_ts
