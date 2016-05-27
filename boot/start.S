.section ".text.boot"

.globl _start
_start:
	// setup stack
	mov sp, #0x8000

	// setup UART
	bl uart_init

	mov r0, #0x47 // G
	bl uart_send_byte
	mov r0, #0x32 // 2
	bl uart_send_byte
	mov r0, #0x34 // 4
	bl uart_send_byte
	mov r0, #0x0A // \n
	bl uart_send_byte

	// Initialize the framebuffer
	bl fb_init

        // Test rasterizer
        bl triangle_test

	ldr r0, =mario_face
	bl bmp_draw

	// Blink LEDs to check if it works
	mov r1, #0
	bl led_blinker

	// ideally do more stuff here
	bye:
		b bye


// keep this for vim
// @ vim:ft=armv5
