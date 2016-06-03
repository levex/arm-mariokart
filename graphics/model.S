.section ".text"

// Format of pobj
// uint32_t @ 0x00:   number of triangles
// uint32_t[3]    : x y z coordinates of triangles until EoF

// This file loads models

vp_matrix: .skip 4*4*4
tmp_matrix: .skip 4*4*4

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r9, lr}
    mov r4, r0
    ldr r5, [r4], #4
    b 1f

    push {r0-r12}
      mov r0, #'X'
      bl uart_send_byte
      bl uart_send_newline
    pop {r0-r12}

    mov r0, #30
    ldr r1, =tmp_matrix
    bl get_rotation_y_matrix

    push {r0-r12}
      mov r0, #'Y'
      bl uart_send_byte
      bl uart_send_newline
    pop {r0-r12}

    ldr r0, =tmp_matrix
    ldr r1, =projection_matrix
    ldr r2, =vp_matrix
    bl mat4_mul_mat4

    push {r0-r12}
      mov r0, #'Z'
      bl uart_send_byte
      bl uart_send_newline
    pop {r0-r12}

    1:
      ldr r0, =projection_matrix
      mov r1, r4
      ldr r2, =dummy_triangle
      bl transform_triangle
      tst r1, r1   // should we render?
      beq 2f       // is zero?
      bpl 2f       // positive?

      sub r0, r2, #48
      sub r1, r2, #32
      sub r2, r2, #16
      ldr r3, [r4, #48]       // load color

      bl triangle             // rasterize
    2:
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
