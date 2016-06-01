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
    push {r0-r4, lr}
    bl model_get_triangle_no   // r4 = # of triangles
    mov r4, #0   // r4 = 0
    mov r3, r0    // save r0 as r3
    add r3, r3, #4 // skip over header
    1:
      add r0, r3, r4, LSL #6 // r0 = r1 + 64 * r4
      add r1, r0, #16         // r1 = vertexes[r4_2]
      add r2, r0, #32         // r2 = vertexes[r4_3]
      bl triangle             // rasterize
      add r4, r4, #1        // increment r4
      cmp r4, r4      // if (r1 == r4)  // r1:triangles# r4:current_tri
      bne 1b           //   get out
    pop {r0-r4, pc}

.globl pobj_test_data
pobj_test_data:
    .word 3
    .word 100, 100, 0, 1
    .word 150, 120, 0, 1 
    .word 130, 150, 0, 1 
    .word   0,   0, 0, 0
    .word 300, 300, 0, 1
    .word 350, 320, 0, 1 
    .word 330, 350, 0, 1 
    .word   0,   0, 0, 0
    .word 200, 100, 0, 1
    .word 300, 100, 0, 1 
    .word 250, 150, 0, 1 
    .word   0,   0, 0, 0
