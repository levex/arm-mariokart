.section ".text.boot"

.macro splash_screen
  mov r0, #0
  mov r1, #0
  mov r3, #640
  mov r4, #480
  ldr r2, =splash_pbmp
  add r2, r2, #8
  bl fb_copy_rect

  ldr r0, =3000
  bl wait_realtime // Wait 3 seconds
.endm


.globl _start
_start:
    // Setup stack
    mov sp, #0x8000

    // Setup VFP
    bl vfp_init

    // Setup UART
    bl uart_init

    // Initialize the framebuffer
    bl fb_init

    // Init controller
    bl controller_init

    // Splash screen
    splash_screen

    // Start game
    b game_loop

vfp_init:
    //enable vfp in secure mode
    mcr p15, #0, r0, c1, c0, #2
    orr r0, r0, #(0xF << 20)
    mcr p15, #0, r0, c1, c0, #2

    //enable FP processor in general
    //EN bit in fpexc
    mov r3, #0x40000000
    vmsr fpexc, r3
    mov pc, lr

procrastination:
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

// keep this for vim
// @ vim:ft=armv5
