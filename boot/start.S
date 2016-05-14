.section ".text.boot"

.globl _start
_start:
	// setup stack
	mov sp, #0x8000

	// setup UART
	// bl uart_init

	// Blink LEDs to check if it works
	bl led_blinker

	// ideally do more stuff here
	bye:
		b bye


// keep this for vim
// @ vim:ft=armv5
