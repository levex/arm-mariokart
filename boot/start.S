.section ".text.boot"

.globl _start
_start:
    // setup stack
    mov sp, #0x8000

    // setup VFP
    bl vfp_init

    // setup UART
    bl uart_init

    mov r0, #'G'
    bl uart_send_byte
    mov r0, #'2'
    bl uart_send_byte
    mov r0, #'4'
    bl uart_send_byte

    // Initialize the framebuffer
    bl fb_init

    mov r4, #0xFF000000
    rainbow:
    add r4, #0x0100

    mov r0, #100
    mov r1, #100
    mov r2, r4
    ldr r3, =procrastination1
    bl render_string

    mov r0, #100
    mov r1, #150
    mov r2, r4
    ldr r3, =procrastination2
    bl render_string

    mov r0, #100
    mov r1, #200
    mov r2, r4
    ldr r3, =procrastination3
    bl render_string

    mov r0, #100
    mov r1, #250
    mov r2, r4
    ldr r3, =procrastination4
    bl render_string

    mov r0, #100
    mov r1, #300
    mov r2, r4
    ldr r3, =procrastination5
    bl render_string

    /*mov r0, #1
    bl wait_realtime*/
    ldr r0, =1000
    bl delay
    b rainbow


    // Test rasterizer
    //bl triangle_test

    // Blink LEDs to check if it works
    //bl led_blinker

    // ideally do more stuff here
    bye:
        b bye


vfp_init:
    //enable vfp in secure mode
    ldr r0, =(0xF << 20)
    mcr p15, #0, r0, c1, c0, #2

    //enable FP processor in general
    //EN bit in fpexc
    mov r3, #0x40000000
    vmsr fpexc, r3

    bx lr

// keep this for vim
// @ vim:ft=armv5
