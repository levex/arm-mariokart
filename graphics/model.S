.section ".text"

// Format of pobj
// uint32_t @ 0x00:   number of triangles
// uint32_t[3]    : x y z coordinates of triangles until EoF

// This file loads models

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r9, lr}
    mov r4, r0
    ldr r5, [r4], #4

    1:
      ldr r0, =projection_matrix
      mov r1, r4
      ldr r2, =dummy_triangle
      bl transform_triangle

      sub r0, r2, #48
      sub r1, r2, #32
      sub r2, r2, #16
      ldr r3, [r4, #48]       // load color

      bl triangle             // rasterize
      add r4, #64
      subs r5, #1
      bne 1b           //   get out
    pop {r0-r9, pc}

.globl dummy_triangle
dummy_triangle: .skip 4*4*3

.globl pobj_test_data
pobj_test_data:
    .word 3
    .word 300, 300, 0, 1
    .word 350, 320, 0, 1 
    .word 330, 350, 0, 1 
    .word   0,   0, 0, 0
    .word 100, 100, 0, 1
    .word 150, 120, 0, 1 
    .word 130, 150, 0, 1 
    .word   0,   0, 0, 0
    .word 200, 100, 0, 1
    .word 300, 100, 0, 1 
    .word 250, 150, 0, 1 
    .word   0,   0, 0, 0
