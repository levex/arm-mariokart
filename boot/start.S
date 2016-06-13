.section ".text.boot"

.macro splash_screen
  mov r0, #0
  mov r1, #0
  ldr r2, =splash_pbmp
  bl pbmp_draw

  bl copy_back_buffer
 
  ldr r0, =5000000  
  bl wait_realtime  // Wait 5 seconds
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

    // ideally do more stuff here
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
