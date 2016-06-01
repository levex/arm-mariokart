/*
*   gpio.S
*
*   GPIO driver for handling controls
*/

.section ".text"

.globl controller_init
controller_init:
    push {lr}
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
    pop {lr}
    bx lr

.globl test_pin
test_pin:
    push {lr}

    check_pin:
    bl led_ok_turn_off
    bl poll_gpio
    b check_pin

    pop {lr}
    bx lr


.globl poll_gpio
poll_gpio:
    push {lr}
    push {r0-r2}

    ldr r0, =0x20200000
    ldr r1, =0xFFFFFFFF
    str r1, [r0, #64]       // clear event detect register
    ldr r1, [r0, #64]       // read event register

    mov r2, #(1 << 22)
    ands r2, r1             // check GPIO 22
    bleq led_ok_turn_on     // <--- Button pressed

    mov r2, #(1 << 23)      // GPIO 23
    ands r2, r1
    bleq led_ok_turn_on     // <--- Button pressed

    mov r2, #(1 << 24)      // GPIO 24
    ands r2, r1, r2
    bleq led_ok_turn_on     // <--- Button pressed

    pop {r0-r2}
    pop {lr}
    bx lr
