.section ".text"
.include "util/macros.S"

// preprocessed bmp driver
// pbmps have the following formats:
// uint32_t at 0x00: WIDTH
// uint32_t at 0x04: HEIGHT
// uint32_t from on: 32 bit colors

.globl pbmp_draw
pbmp_draw:
    push {r2-r4, lr}

    ldr r3, [r2, #0x00]
    ldr r4, [r2, #0x04]

    add r2, r2, #0x08 // skip pbmp header

    bl fb_copy_rect

    pop {r2-r4, pc}

// @ vim:ft=armv5
