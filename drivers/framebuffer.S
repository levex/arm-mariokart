.section ".text"

// Framebuffer driver
// Requests a framebuffer address using the mailbox

.balign 16
gpu_framebuffer_struct:
             .word 640  /* width */
             .word 480  /* height */
             .word 640  /* virtual (???) width */
             .word 480  /* virtual (???) height */
    pitch:   .word 000  /* pitch, not entirely sure what this is */
             .word 024  /* depth */
             .word 000  /* x_offset */
             .word 000  /* y_offset */
    fb_addr: .word 000  /* pointer to framebuffer, set by GPU */
             .word 000  /* size of framebuffer, set by GPU */

/*
 * fb_init - initalize a framebuffer for use
 */
.globl fb_init
fb_init:
    push {r0, lr}

    /* send the GPU our lovely request */
    ldr r1, =gpu_framebuffer_struct
    add r1, r1, #0x40000000  /* turn off caching */
    add r1, r1, #1   /* set channel 1 */
    bl mail_write_mailbox

    /* wait until the GPU replies */
    bl mail_read_mailbox

    /* framebuffer is valid */
    ldr r0, =framebuffer_acquired_str
    bl uart_send_string

    ldr r2, =0xFF0000
    ldr r0, =320
    ldr r1, =240
    bl fb_put_pixel

    ldr r2, =0x00FF00
    ldr r0, =319
    ldr r1, =240
    bl fb_put_pixel

    ldr r2, =0x00FF00
    ldr r0, =318
    ldr r1, =240
    bl fb_put_pixel

    ldr r2, =0x00FF00
    ldr r0, =317
    ldr r1, =240
    bl fb_put_pixel

    ldr r2, =0x00FF00
    ldr r0, =316
    ldr r1, =240
    bl fb_put_pixel

    pop {r0, lr}
    mov pc, lr

/*
 * fb_put_pixel -> put r2 at (r0, r1), (x, y)
 *
 * Does not handle out of range!
 */
.globl fb_put_pixel
fb_put_pixel:
    push {r3, r4, lr}

    ldr r3, pitch
    mul r1, r1, r3 // y = y * pitch

    mov r3, #3
    mul r0, r0, r3 // x = x * 3

    add r4, r0, r1  // r4 = 3x + y * pitch

    ldr r3, fb_addr
    str r2, [r3, r4]

    pop {r3, r4, lr}
    mov pc, lr

/*
 * fb_draw_line - draw line from (r0, r1) to (r2, r3)
 */
.globl fb_draw_line
fb_draw_line:
   push {r4, lr}

   /* calculate slope */
   sub r4, r2, r0 /* dX */
   sub r5, r3, r1 /* dY */
   /* WIP */

   pop {r4, lr}
   mov pc, lr
