.section ".text"

// Misc stuff

/*
 * delay - Delays execution for a number of cycles
 *
 * Parameters:
 * r0 = Number of cycles
 *
 * 5,000,000 = 500ms
 */
.globl delay
delay:
	push {r1}
	mov r1, #0
	delay_loop:
		nop
		add r1, r1, #1
		cmp r1, r0
		ble delay_loop
	pop {r1}
	bx lr
