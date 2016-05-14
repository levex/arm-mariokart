.section ".text"

// UART related code

/*
 * First, we disable UART0 so we can safely setup the GPIO.
 * For the moment being, we'll recode UART0 to GPIO #14-#15.
 * 
 */
.global uart_init
uart_init:
	push {lr}
	push {r0-r3}

	// UART0_BASE => r0
	ldr r0, =0x20201000
	// GPIO BASE => r2
	ldr r2, =0x20200000

	mov r1, #0
	// write zeros to Control Register to disable UART0
	str r1, [r0, #0x30]        // UART0_CR

	// Disable all U/D pull for GPIOs
	str r1, [r2, #0x94]        // GPPUD
	push {r0}
		mov r0, #100
		bl delay
	pop {r0}

	// Use pin #14 & #15
	mov r3, #((1 << 14) | (1 << 15))
	str r3, [r2, #0x98]        // GPPUDCLK0
	push {r0}
		mov r0, #100
		bl delay
	pop {r0}

	// Reset clock now
	str r1, [r2, #0x98]        // GPPUDCLK0

	// UART has to be clear of IRQs
	ldr r3, =0x7ff
	str r3, [r0, #0x44]        // UART0_ICR

	// setup baud-rate using some data I found online
	mov r3, #1
	str r3, [r0, #0x24]        // UART0_IBRD
	mov r3, #40
	str r3, [r0, #0x28]        // UART0_FBRD

	// FIFO, 8bit data, 1 bit stop bit w/o parity
	mov r3, #(1 << 4 | 1 << 5 | 1 << 6)
	str r3, [r0, #0x2C]        // UART0_LCRH

	// mask interrupts
	ldr r3, =0xFF2
	str r3, [r0, #0x38] 	   // UART0_IMSC

	// enable, receive + send
	ldr r3, =0x301	
	str r3, [r0, #0x30]        // UART0_CR

	pop {r0-r3}
	pop {lr}
	bx lr
