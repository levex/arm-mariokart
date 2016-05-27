.section ".text"


// LED Driver

.globl led_ok_turn_off
led_ok_turn_off:
    push {lr}
    push {r0-r2}

    ldr r0, =0x20200000
    // Select OK LED
    mov r1, #(1 << 18)
    ldr r2, [r0, #4]    // r2 = gpio[LED_GFPSEL]
    orr r2, r1          // r2 = r2 | (1 << 18)
    str r2, [r0, #4]    // gpio[LED_GFPSEL] = r2

    mov r1, #(1 << 16) 
    ldr r2, [r0, #28]
    orr r2, r1
    str r2, [r0, #28]

    pop {r0-r2}
    pop {lr}
    bx lr

.globl led_ok_turn_on
led_ok_turn_on:
    push {lr}
    push {r0-r2}

    ldr r0, =0x20200000
    // Select OK LED
    mov r1, #(1 << 18)
    ldr r2, [r0, #4]    // r2 = gpio[LED_GFPSEL]
    orr r2, r1          // r2 = r2 | (1 << 18)
    str r2, [r0, #4]    // gpio[LED_GFPSEL] = r2

    mov r1, #(1 << 16) 
    ldr r2, [r0, #40]
    orr r2, r1
    str r2, [r0, #40]

    pop {r0-r2}
    pop {lr}
    bx lr

.align
hello: .asciz "Hello, Lev!\n"
.align

.globl led_blinker
led_blinker:
    bl led_ok_turn_on

    ldr r0, =5000000
    bl delay

    ldr r0, =hello
    bl uart_send_string

    mov r0, #0
    mov r1, #0
    ldr r2, =sky_pbmp
    bl pbmp_draw

    mov r0, #100
    mov r1, #100
    ldr r2, =mario_face
    bl pbmp_draw

    bl triangle_test

    bl led_ok_turn_off

    ldr r0, =5000000
    bl delay

    bl fb_clear

    b led_blinker

