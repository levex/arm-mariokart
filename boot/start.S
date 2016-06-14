.section ".text.boot"
.include "graphics/colors.S"

.macro splash_screen
  mov r0, #0
  mov r1, #0
  ldr r2, =splash_pbmp
  bl pbmp_draw

  bl copy_back_buffer
 
  ldr r0, =5000000  
  bl wait_realtime  // Wait 5 seconds
.endm

.macro countdown
  /* render skybox */
  mov r0, #0
  mov r1, #0
  ldr r2, =sky_pbmp
  add r2, r2, #8
  mov r3, #640
  mov r4, #380
  bl fb_copy_rect

  bl copy_back_buffer

  /* 3 */
  ldr r0, =260
  mov r1, #118
  mov r2, #color_red
  ldr r3, =countdown_3_str
  bl render_string
  bl copy_back_buffer

  ldr r0, =1000000
  bl wait_realtime

  /* 2 */
  ldr r0, =295
  mov r1, #118
  ldr r3, =countdown_2_str
  bl render_string
  bl copy_back_buffer

  ldr r0, =1000000
  bl wait_realtime

  /* 1 */
  ldr r0, =330
  mov r1, #118
  ldr r3, =countdown_1_str
  bl render_string
  bl copy_back_buffer

  ldr r0, =1000000
  bl wait_realtime

  /* 0 */
  ldr r0, =365
  mov r1, #118
  ldr r3, =countdown_0_str
  bl render_string
  bl copy_back_buffer

  ldr r0, =1000000
  bl wait_realtime
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

    // Countdown
    countdown

    // Start game
    b game_loop
    bye:
        b bye

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

// keep this for vim
// @ vim:ft=armv5
