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

/* Execute a memory barrier */
.globl memory_barrier
memory_barrier:
    push {r3}
    mov r3, #0
    mcr p15, 0, r3, C7, C6, 0
    mcr p15, 0, r3, c7, c10, 0
    mcr p15, 0, r3, c7, c14, 0
    mcr p15, 0, r3, c7, c10, 4
    mcr p15, 0, r3, c7, c10, 5
    pop {r3}
    mov pc, lr
