.section ".text"
.include "util/macros.S"

// Framebuffer driver
// Requests a framebuffer address using the mailbox

.globl fb_addr
.globl y_offset
.balign 16
gpu_framebuffer_struct:
              .word 640  /* width */
              .word 480  /* height */
              .word 640  /* virtual (???) width */
              .word 960  /* virtual (???) height */
    pitch:    .word 000  /* pitch, not entirely sure what this is */
              .word  32  /* depth */
              .word 000  /* x_offset */
    y_offset: .word 000  /* y_offset */
    fb_addr:  .word 000  /* pointer to framebuffer, set by GPU */
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

    ldr r12, fb_addr
    add r12, r12, #1228800 // load r12 with backbuffer

    pop {r0, pc}

/*
 * Copies a rectangle of data onto the framebuffer
 *
 * Parameters:
 * r0 - starting x
 * r1 - starting y
 * r2 - pointer to data
 * r3 - width
 * r4 - height
 */
.globl fb_copy_rect
fb_copy_rect:
    push {r3-r5}
    ldr r10, pitch
    mul r10, r1, r10 // r10 = y * pitch
    add r10, r0, lsl #2  // r10 = 4x + y * pitch
    add r10, r12, r10
    ldr r5, pitch
    sub r5, r3
    sub r5, r3
    sub r5, r3
    sub r5, r3

    mov r11, r3

    1:
        pld [r2, #0xC0]
        vldm r2!, {d0-d7}
        vstm r10!, {d0-d7}
        subs r3, #16
        addle r10, r5
        movle r3, r11
        suble r4, #1
        cmp r4, #0
        bne 1b

    pop {r3-r5}
    mov pc, lr

.globl fb_clear
fb_clear:
    push {r0-r9}

    ldr r0, =gpu_framebuffer_struct
    ldr r1, [r0, #4]

    ldr r0, pitch
    mul r1, r0, r1

    //ldr r0, fb_addr
    mov r0, r12

    add r1, r1, r0

    mov r2, #0
    mov r3, #0
    mov r4, #0
    mov r5, #0
    mov r6, #0
    mov r7, #0
    mov r8, #0
    mov r9, #0

    1:
        stmia r0!, {r2-r9}
        cmp r0, r1
        blt 1b

    pop {r0-r9}
    mov pc, lr

/*
 * fb_draw_line - draw line from (r0, r1) to (r2, r3)
 * This uses Bresenham's line algorithm
 */
.globl fb_draw_line
fb_draw_line:
   push {r3-r7, lr}

   sub r4, r2, r0 // dx = x1 - x0
   sub r5, r3, r1 // dy = y1 - y0
   sub r3, r5, r4 // D = dy - dx
   mov r7, r1 // y = y0

   mov r8, r0 // x = x0
   sub r2, r2, #1  // x1 = x1 -1
   1:
      cmp r8, r2
      beq 2f
      push {r0, r1, r2}
        mov r0, r8
        mov r1, r7
        ldr r2, =0xFFFF0000
        put_pixel
      pop {r0, r1, r2}
      cmp r8, #0    // if x >= 0
        addge r7, r7, #1  // y += 1
        subge r3, r3, r4  // D = D - dx
      add r3, r3, r5
      add r8, r8, #1
      b 1b

   2:
   pop {r3-r7, pc}

