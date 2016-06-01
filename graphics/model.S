.section ".text"

// Format of pobj
// uint32_t @ 0x00:   number of triangles
// uint32_t[3]    : x y z coordinates of triangles until EoF

// This file loads models

// Loads the number of triangles of model r0 into r1
.globl model_get_triangle_no
model_get_triangle_no:
    ldr r4, [r0]
    mov pc, lr

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r9, lr}
    bl model_get_triangle_no   // r4 = # of triangles
    mov r5, #0   // r5 = 0
    mov r6, r0    // save r0 as r3
    add r6, r6, #4 // skip over header
    1:
      add r0, r6, r5, LSL #6 // r0 = r1 + 64 * r5
      add r1, r0, #16         // r1 = vertexes[r4_2]
      add r2, r0, #32         // r2 = vertexes[r4_3]
      ldr r10, [r2, #16]       // load color

      ldr r7, [r0]
      ldr r8, [r0, #4]
      ldr r9, [r0, #8]
      str r7, [r3, #0]
      str r8, [r3, #4]
      str r9, [r3, #8]
      str r11, [r3, #12]

      ldr r7, [r1]
      ldr r8, [r1, #4]
      ldr r9, [r1, #8]
      str r7, [r3, #16]
      str r8, [r3, #20]
      str r9, [r3, #24]
      str r11, [r3, #28]

      ldr r7, [r2]
      ldr r8, [r2, #4]
      ldr r9, [r2, #8]
      str r7, [r3, #32]
      str r8, [r3, #36]
      str r9, [r3, #40]
      str r11, [r3, #44]

      ldr r0, =projection_matrix
      ldr r1, =(dummy_triangle+0)
      ldr r2, =(dummy_triangle+0)
      bl transform_vertex

      ldr r0, =projection_matrix
      ldr r1, =(dummy_triangle+16)
      ldr r2, =(dummy_triangle+16)
      bl transform_vertex

      ldr r0, =projection_matrix
      ldr r1, =(dummy_triangle+32)
      ldr r2, =(dummy_triangle+32)
      bl transform_vertex

      mov r3, r10
      bl triangle             // rasterize
      add r5, r5, #1        // increment r4
      cmp r4, r5      // if (r1 == r4)  // r1:triangles# r4:current_tri
      bne 1b           //   get out
    pop {r0-r6, pc}

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
