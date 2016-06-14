.section ".text"

// Format of pobj
// uint32_t @ 0x00:   number of triangles
// uint32_t[3]    : x y z coordinates of triangles until EoF

// This file loads models

.balign 16
.globl vp_matrix
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
.globl tmp_matrix
tmp_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
.globl tmp2_matrix
tmp2_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
.globl model_matrix
model_matrix: .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0
            .float 0, 0, 0, 0

.balign 16
.globl view_matrix
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
.globl translation_matrix_kart
translation_matrix_kart:
            .float 1, 0, 0, 0
            .float 0, 1, 0, 0
            .float 0, 0, 1, 0
            .float 0, 0, 0, 1

.globl eye, at, up
.balign 16
eye: .float 0, 0, 15
at:  .float 0, 0, 0
up:  .float 0, 1, 0

.globl rotating_cube_demo
rotating_cube_demo:
    push {r0-r12}
    // ldr r0, =eye
    // ldr r1, =at
    // ldr r2, =up
    // ldr r3, =view_matrix
    // bl view_matrix_gen
    mov r5, #0
    1:
      ldr r10, =vertex_buffer_object
      mov r11, #0
      str r11, [r10]

      mov r0, #0
      mov r1, #0
      mov r3, #640
      mov r4, #380
      ldr r2, =sky_pbmp
      add r2, r2, #8
      bl fb_copy_rect

      // ldr r0, =eye
      // ldr r1, =at
      // ldr r2, =up
      // ldr r3, =view_matrix
      // ldr r10, =0x3627c5ac
      // vmov s30, r10
      // vldr.f32 s31, [r0, #8]
      // vsub.f32 s31, s30
      // vstr.f32 s31, [r0, #8]
      // vldr.f32 s31, [r1, #8]
      // vsub.f32 s31, s30
      // vstr.f32 s31, [r1, #8]
      // bl view_matrix_gen

      //push {r0-r12, lr}
      //mov r0, r3
      //bl print_matrix
      //pop {r0-r12, lr}

      ldr r1, =projection_matrix
      ldr r0, =view_matrix
      ldr r2, =vp_matrix
      bl mat4_mul_mat4   // p x v ==> vp

      mov r0, #0
      ldr r1, =0xc0400000
      ldr r2, =0xbf800000
      ldr r3, =model_matrix
      bl get_translation_matrix

      ldr r0, =road_data
      bl model_display


      mov r0, r5
      ldr r1, =tmp_matrix
      bl get_rotation_y_matrix

      ldr r0, =0xc0a00000
      ldr r1, =0xc0400000
      ldr r2, =0xc1a00000
      ldr r3, =tmp2_matrix
      bl get_translation_matrix

      ldr r1, =tmp2_matrix
      ldr r0, =tmp_matrix
      ldr r2, =model_matrix
      bl mat4_mul_mat4

      ldr r0, =cube_data
      bl model_display

      ldr r0, =0x40a00000
      ldr r1, =0xc0400000
      ldr r2, =0xc1a00000
      ldr r3, =tmp2_matrix
      bl get_translation_matrix

      ldr r1, =tmp2_matrix
      ldr r0, =tmp_matrix
      ldr r2, =model_matrix
      bl mat4_mul_mat4

      ldr r0, =cube_data
      bl model_display

      bl poll_gpio
      tst r0, #(1 << 0)
      addne r5, r5, #1

      cmp r5, #360
      movge r5, #0

      bl render_frame

      b 1b
    pop {r0-r12}

// Displays the r0 model
.globl model_display
model_display:
    push {r0-r5, lr}
    mov r4, r0
    ldr r5, [r4], #4

    ldr r1, =vp_matrix
    ldr r0, =model_matrix
    ldr r2, =mvp_matrix
    bl mat4_mul_mat4

    ldr r2, =vertex_buffer_object
    mov r10, r2
    ldr r3, [r2], #4
    add r2, r2, r3, lsl #6
    mov r3, r10

    1:
      ldr r0, =mvp_matrix
      mov r1, r4   // current vertex

      bl transform_triangle

      add r4, #64
      subs r5, #1
      bne 1b           //   get out

    pop {r0-r5, pc}

