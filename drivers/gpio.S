/*
*   gpio.S
*
*   GPIO driver for handling controls
*/

.section ".text"

.globl controller_init
controller_init:
    push {r0-r2}

    ldr r0, =0x20200000
    ldr r1, [r0, #8]
    ldr r2, =0xFFFF803F     //set GPIO 22-24 as an input
    and r1, r2
    str r1, [r0, #8]

    ldr r1, [r0, #100]
    mov r2, #(7 << 22)
    orr r1, r2              //enable high detect
    str r1, [r0, #100]

    pop {r0-r2}
    mov pc, lr

// Polls GPIO controller. Returns a 3-bit integer in r0, where each bit corresponds to state of each button
.globl poll_gpio
poll_gpio:
    push {r1-r3, lr}

    mov r3, #0              // return value (3-bits, one for each button, 1 = on, 0 = off)

    ldr r0, =0x20200000
    ldr r1, =0xFFFFFFFF
    str r1, [r0, #64]       // clear event detect register
    ldr r1, [r0, #64]       // read event register

    mov r2, #(1 << 22)
    ands r2, r1             // check GPIO 22
    andeq r3, r3, #4        // set first bit if button pressed

    mov r2, #(1 << 23)      // GPIO 23
    ands r2, r1
    andeq r3, r3, #2        // set second bit if button pressed

    mov r2, #(1 << 24)      // GPIO 24
    ands r2, r1, r2
    andeq r3, r3, #1        // set third bit if button pressed

    mov r0, r3              // return

    pop {r1-r3, pc}
