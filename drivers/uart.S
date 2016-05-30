.section ".text"

// UART related code
// Based on SPEC:
// https://www.raspberrypi.org/wp-content/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
// See Section 13, page 175.

/*
 * First, we disable UART0 so we can safely setup the GPIO.
 * For the moment being, we'll recode UART0 to GPIO #14-#15.
 * 
 */
.globl uart_init
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
		mov r0, #150
		bl delay
	pop {r0}

	// Use pin #14 & #15
	mov r3, #((1 << 14) | (1 << 15))
	str r3, [gpio_base, #0x98]        // GPPUDCLK0
	push {r0}
		mov r0, #150
		bl delay
	pop {r0}

	// Reset clock now
	mov r1, #0
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
.globl uart_wait_ready_send
uart_wait_ready_send:
	push {lr}
	push {r0-r1}

	uart0_base .req r0
	ldr uart0_base, =0x20201000

	// check UART0_FR
	1:
		ldr r1, [r0, #0x18]    // UART0_FR
		ands r1, r1, #(1 << 5)
		bne 1b // check if ands returned zero

	pop {r0-r1}
	pop {lr}
	bx lr

/*
 * uart_wait_ready_receive - waits until you can read a byte
 */
.globl uart_wait_ready_receive
uart_wait_ready_receive:
	push {lr}
	push {r0-r1}

	uart0_base .req r0
	ldr uart0_base, =0x20201000

	// check UART0_FR
	1:
		ldr r1, [r0, #0x18]    // UART0_FR
		ands r1, r1, #(1 << 4)
		bne 1b // check if ands returned zero

	pop {r0-r1}
	pop {lr}
	bx lr

/*
 * uart_get_byte - gets a byte from the UART, this one will wait until there
 *                 is a byte available!
 */
.globl uart_get_byte
uart_get_byte:
	push {lr}
	push {r1}

	// busy wait
	bl uart_wait_ready_receive
	ldr r1, =0x20201000 // UART0_BASE
	ldr r0, [r1, #0] // UART0_DR

	pop {r1}
	pop {lr}
	bx lr

/*
 * uart_send_byte - Sends a byte on the UART, will wait until space is avail
 * 
 * Parameters:
 * r0 contains the byte (HAS TO BE CLAMPED OTHERWISE BOOM)
 */
.globl uart_send_byte
uart_send_byte:
	push {lr}
	push {r1}
	// busy wait
	bl uart_wait_ready_send
	ldr r1, =0x20201000 // UART0_BASE

	str r0, [r1, #0]

	pop {r1}
	pop {lr}
	bx lr

/*
 * uart_send_string - send an ASCIZ over UART
 *
 * Parameters:
 * r0 contains the address of the ASCIZ string
 */
.globl uart_send_string
uart_send_string:
	push {lr}
	push {r1}

	mov r1, r0   // r1 = r0
	1:
		ldrb r0, [r1], #1   // r0 = *(r1 ++);
		bl uart_send_byte   // else uart_send_byte(r0)
		cmp r0, #0  // if (r0 == 0)
		beq 2f //    goto 2;
		b 1b // goto 1

	2:
	pop {r1}
	pop {lr}
	bx lr

/*
 * uart_send_int - sends an int stored in r0 over UART
 *
 * Parameters:
 * r0 contains the number to be sent
 * r1 contains the base to use (must be between 2 and 36)
 */
.globl uart_send_int
uart_send_int:
    push {lr}
    push {r2-r4}

    mov r4, #0
    mov r2, r0
    cmp r2, #0
    bge 1f
    mov r0, #0x2D       // ascii code of '-'
    bl uart_send_byte
    neg r2, r2

    1:
        mov r0, r2
        bl udiv
        mov r3, r0
        mul r0, r1, r3
        sub r0, r2, r0
        push {r0}
        add r4, #1
        cmp r3, #0
        beq 2f
        mov r2, r3
        b 1b

    2:
        pop {r0}
        cmp r0, #10
        addlt r0, #0x30  // if r0 < 10, add it to ascii code of '0' to get char
        subge r0, #10    // else remove 10
        addge r0, #0x41  // and add ascii code of 'A' to get hex value
        bl uart_send_byte
        sub r4, #1
        cmp r4, #0
        bne 2b

    pop {r2-r4}
    pop {lr}
    bx lr

.globl uart_send_int_bin
uart_send_int_bin:
    push {lr}
    push {r1}

    mov r1, #2
    bl uart_send_int

    pop {r1}
    pop {lr}
    bx lr

.globl uart_send_int_dec
uart_send_int_dec:
    push {lr}
    push {r1}

    mov r1, #10
    bl uart_send_int

    pop {r1}
    pop {lr}
    bx lr

.globl uart_send_int_hex
uart_send_int_hex:
    push {r1, lr}

    mov r1, #16
    bl uart_send_int

    pop {r1, pc}

.globl uart_send_newline
uart_send_newline:
    push {r0, lr}

    mov r0, #'\n'
    bl uart_send_byte
    mov r0, #'\r'
    bl uart_send_byte

    pop {r0, pc}
