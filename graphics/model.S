.section ".text"

// Format of pobj
// uint32_t @ 0x00:   number of triangles
// uint32_t[3]    : x y z coordinates of triangles until EoF

// This file loads models

.balign 16
vp_matrix: .float 0, 0, 0, 0
           .float 0, 0, 0, 0
           .float 0, 0, 0, 0
           .float 0, 0, 0, 0

.balign 16
mvp_matrix:
.float 1.433439,        0,         0,  5.733757
.float        0, 2.414213,         0,         0
.float        0,        0, -1.068966, -4.655172
.float        0,        0,        -1,        15

.balign 16
tmp_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
view_matrix: .float 1, 0, 0, 4
            .float 0, 1, 0, 0
            .float 0, 0, 1, -15
            .float 0, 0, 0, 1

.balign 16
id_matrix: .float  1, 0, 0, 0
            .float 0, 1, 0, 0
            .float 0, 0, 1, 0
            .float 0, 0, 0, 1

.balign 16
eye: .float 0, 0, -15
at:  .float 0, 0, 0
up:  .float 0, 1, 0

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r9, lr}
    mov r4, r0
    ldr r5, [r4], #4

//    push {r0-r12}
//    bl uart_send_newline

    ldr r0, =eye
    ldr r1, =at
    ldr r2, =up
    ldr r3, =view_matrix
    bl view_matrix_gen

    push {r0-r11}
        ldr r0, =view_matrix
        bl print_matrix
    pop {r0-r11}

    ldr r0, =0xc0a00000
    mov r1, #0
    mov r2, #0
    ldr r3, =tmp_matrix
    bl get_translation_matrix
//
    ldr r1, =projection_matrix
    ldr r0, =view_matrix
    ldr r2, =vp_matrix
    bl mat4_mul_mat4   // p x v ==> vp
//
    ldr r1, =vp_matrix
    ldr r0, =tmp_matrix
    ldr r2, =mvp_matrix
    bl mat4_mul_mat4

//    pop {r0-r12}

    1:
      ldr r0, =mvp_matrix
      mov r1, r4   // current vertex
      ldr r2, =dummy_triangle
      bl transform_triangle
      //cmp r1, #0 // should we render?
      //beq 2f       // is zero?
      //blt 2f       // positive?

      //push {r0-r12}
      //    sub r0, r2, #48
      //    bl print_vertex
      //    sub r0, r2, #32
      //    bl print_vertex
      //    sub r0, r2, #16
      //    bl print_vertex
      //pop {r0-r12}

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
.balign 16
dummy_triangle: .word 0, 0, 0, 0
                .word 0, 0, 0, 0
                .word 0, 0, 0, 0
                .word 0, 0, 0, 0
                .word 0, 0, 0, 0
                .word 0, 0, 0, 0
                .word 0, 0, 0, 0

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
