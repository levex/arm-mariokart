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
tmp2_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
model_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
view_matrix: .float 1, 0, 0, 0
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

.globl rotating_cube_demo
rotating_cube_demo:
    push {r0-r12}
    mov r3, #0
    1:
      bl fb_clear

      ldr r1, =projection_matrix
      ldr r0, =view_matrix
      ldr r2, =vp_matrix
      bl mat4_mul_mat4   // p x v ==> vp
      
      mov r0, r3
      ldr r1, =model_matrix
      bl get_rotation_y_matrix

      ldr r0, =cube_data
      bl model_display

      add r3, r3, #1
      cmp r3, #360
      movge r3, #0

      bl copy_back_buffer

      ldr r0, =1000
      bl delay
      b 1b
    pop {r0-r12}

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r9, lr}
    mov r4, r0
    ldr r5, [r4], #4

    //ldr r0, =0xc0a00000
    //mov r1, #0
    //mov r2, #0
    //ldr r3, =tmp2_matrix
    //bl get_translation_matrix


    //ldr r0, =tmp_matrix
    //ldr r1, =tmp2_matrix
    //ldr r2, =model_matrix
    //bl mat4_mul_mat4

    ldr r1, =vp_matrix
    ldr r0, =model_matrix
    ldr r2, =mvp_matrix
    bl mat4_mul_mat4

    1:
      ldr r0, =mvp_matrix
      mov r1, r4   // current vertex
      ldr r2, =dummy_triangle
      bl transform_triangle
      tst r1, r1// should we render?
      beq 2f       // is zero?
      bpl 2f       // positive?

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
