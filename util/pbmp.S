.section ".text"

// preprocessed bmp driver
// pbmps have the following formats:
// uint32_t at 0x00: WIDTH
// uint32_t at 0x04: HEIGHT
// uint32_t from on: 32 bit colors

.globl pbmp_get_width
pbmp_get_width:
    ldr r0, [r0, #0x00]
    mov pc, lr

.globl pbmp_get_height
pbmp_get_height:
    ldr r0, [r0, #0x04]
    mov pc, lr

.globl pbmp_draw
pbmp_draw:
    push {r0-r3, r6-r8, lr}

    mov r7, r0 // save the image ptr to r7

    bl pbmp_get_width
    mov r6, r0 // save width as r6
    bl uart_send_int_dec
    bl uart_send_newline

    mov r0, r7
    bl pbmp_get_height
    mov r8, r0 // save height as r8
    bl uart_send_int_dec
    bl uart_send_newline

    add r7, r7, #0x08 // skip pbmp header

    mov r0, #0   // r0 as X
    mov r1, #0   // r1 as Y
    1:
      mul r3, r1, r6    // r3 = Y * width
      add r3, r3, r0    // r3 = Y * width + X
      lsl r3, #2        // r3 <<= 2
      ldr r2, [r7, r3]  // load color
      bl fb_put_pixel   // put pixel
      add r0, r0, #1    // increase X
      cmp r0, r6        // compare X with width
      moveq r0, #0      // if eq, reset X to zero
      addeq r1, r1, #1  // if eq, add 1 to Y
      cmp r1, r8        // compare Y with height
      beq 2f            // exit loop if eq
      b 1b              // else jump back to loop
    2:
    pop {r0-r3, r6-r8, lr}
    mov pc, lr
    
// @ vim:ft=armv5
