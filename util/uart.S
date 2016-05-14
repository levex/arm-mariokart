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
	
	uart0_base .req r0
	gpio_base .req r2

	ldr uart0_base, =0x20201000
	ldr gpio_base, =0x20200000

	mov r1, #0
	// write zeros to Control Register to disable UART0
	str r1, [uart0_base, #0x30]        // UART0_CR

	// Disable all U/D pull for GPIOs
	str r1, [gpio_base, #0x94]        // GPPUD
	push {r0}
		mov r0, #100
		bl delay
	pop {r0}

	// Use pin #14 & #15
	mov r3, #((1 << 14) | (1 << 15))
	str r3, [gpio_base, #0x98]        // GPPUDCLK0
	push {r0}
		mov r0, #100
		bl delay
	pop {r0}

	// Reset clock now
	str r1, [gpio_base, #0x98]        // GPPUDCLK0

	// UART has to be clear of IRQs
	ldr r3, =0x7ff
	str r3, [uart0_base, #0x44]        // UART0_ICR

	// setup baud-rate using some data I found online
	mov r3, #1
	str r3, [uart0_base, #0x24]        // UART0_IBRD
	mov r3, #40
	str r3, [uart0_base, #0x28]        // UART0_FBRD

	// FIFO, 8bit data, 1 bit stop bit w/o parity
	mov r3, #(1 << 4 | 1 << 5 | 1 << 6)
	str r3, [uart0_base, #0x2C]        // UART0_LCRH

	// mask interrupts
	ldr r3, =0xFF2
	str r3, [uart0_base, #0x38] 	   // UART0_IMSC

	// enable, receive + send
	ldr r3, =0x301	
	str r3, [uart0_base, #0x30]        // UART0_CR

	pop {r0-r3}
	pop {lr}
	bx lr

/*
 * uart_wait_ready_send - waits until you can send a byte
 */
uart_wait_ready_send:
