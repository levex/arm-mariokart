.section ".text.boot"

.globl _start
_start:
	// setup stack
	mov sp, #0x8000

	bl main

	// setup UART
	bl uart_init

	// ideally do more stuff here
	bye:
		b bye


// keep this for vim
// @ vim:ft=armv5
