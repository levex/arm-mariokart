.section ".text"

.balign 16
enemy_0:
  enemy_0_x: .float -5
  enemy_0_y: .float 0
  enemy_0_z: .float -30
  enemy_0_speed: .float 10.0
  enemy_0_tending: .word 0
  enemy_0_rotation: .word 0

.balign 16
enemy_1:
  enemy_1_x: .float 0
  enemy_1_y: .float 0
  enemy_1_z: .float 0
  enemy_1_speed: .float 15.0
  enemy_1_tending: .word 0

.balign 16
enemy_2:
  enemy_2_x: .float 0
  enemy_2_y: .float 0
  enemy_2_z: .float 0
  enemy_2_speed: .float 25.0
  enemy_2_tending: .word 0

.globl enemy_init
enemy_init:
  mov pc, lr

.globl enemy_progress_one
enemy_progress_one:
  push {lr}
  mov r1, r0
  ldr r2, [r1, #16] // r2 = tending part
  cmp r2, #0
  beq __part_zero
  cmp r2, #1
  beq __part_one
  cmp r2, #2
  beq __part_two
  cmp r2, #3
  beq __part_three
  pop {pc}

  __part_zero: // z += 5
    vldr.f32 s0, [r1, #8] // r3 = z
    ldr r4, =0x40a00000 // +5.0
    vmov.f32 s1, r4
    vadd.f32 s0, s0, s1
    vmov.f32 r3, s0
    str r3, [r1, #8]

    ldr r4, =0x42c80000 // 100.0
    vmov.f32 s0, r4 // s0 = 100.0
    vmov.f32 s1, r3 // r3 = new value
    vcmp.f32 s1, s0  // if our z reaches 100, then next stage
    fmstat
    movge r2, #1
    strge r2, [r1, #16]

    // rotation 0
    mov r2, #0
    str r2, [r1, #20]

    pop {pc}
  __part_one: // x += 5
    vldr.f32 s0, [r1, #0] // r3 = x
    ldr r4, =0x40a00000 // +5.0
    vmov.f32 s1, r4
    vadd.f32 s0, s0, s1
    vmov.f32 r3, s0
    str r3, [r1, #0]

    ldr r4, =0x42c80000 // 100.0
    vmov.f32 s0, r4 // s0 = 100.0
    vmov.f32 s1, r3 // r3 = new value
    vcmp.f32 s1, s0  // if our z reaches 100, then next stage
    fmstat
    movge r2, #2
    strge r2, [r1, #16]

    // rotation: 90
    mov r2, #90
    str r2, [r1, #20]

    pop {pc}
  __part_two: // z -= 5
    vldr.f32 s0, [r1, #8] // r3 = z
    ldr r4, =0x40a00000 // +5.0
    vmov.f32 s1, r4
    vsub.f32 s0, s0, s1
    vmov.f32 r3, s0
    str r3, [r1, #8]

    ldr r4, =0xc2c80000 // -100.0
    vmov.f32 s0, r4 // s0 = -100.0
    vmov.f32 s1, r3 // r3 = new value
    vcmp.f32 s1, s0  // if our z reaches -100, then next stage
    fmstat
    movle r2, #3
    strle r2, [r1, #16]

    // rotation: 180
    mov r2, #180
    str r2, [r1, #20]

    pop {pc}
  __part_three: // x -= 5
    vldr.f32 s0, [r1, #0] // r3 = x
    ldr r4, =0x40a00000 // +5.0
    vmov.f32 s1, r4
    vsub.f32 s0, s0, s1
    vmov.f32 r3, s0
    str r3, [r1, #0]

    ldr r4, =0xc2c80000 // 100.0
    vmov.f32 s0, r4 // s0 = 100.0
    vmov.f32 s1, r3 // r3 = new value
    vcmp.f32 s1, s0  // if our z reaches 100, then next stage
    fmstat
    movle r2, #0
    strle r2, [r1, #16]

    // rotation: 270
    ldr r2, =270
    str r2, [r1, #20]

    pop {pc}

.globl enemy_progress
enemy_progress:
  push {lr}
  ldr r0, =enemy_0
  bl enemy_progress_one
  pop {pc}

.balign 4
tending_points:
    //       x      y     z     pad
    .float    0.0, 0.0,    0.0, 0.0
    .float -100.0, 0.0, -100.0, 0.0
    .float -100.0, 0.0,  300.0, 0.0
    .float  300.0, 0.0,  300.0, 0.0
    .float  300.0, 0.0, -100.0, 0.0

/* renders an enemy in the r0 */
.globl enemy_render_one
enemy_render_one:
  push {lr}
  mov r4, r0
  ldr r0, [r4, #0]
  ldr r1, [r4, #4]
  ldr r2, [r4, #8]
  ldr r3, =tmp_matrix
  bl get_translation_matrix

  ldr r0, [r4, #20]
  ldr r1, =tmp2_matrix
  bl get_rotation_y_matrix

  ldr r0, =tmp2_matrix
  ldr r1, =tmp_matrix
  ldr r2, =model_matrix
  bl mat4_mul_mat4

  ldr r0, =cube_data
  bl model_display
  pop {pc}

.globl enemy_render
enemy_render:
  push {lr}
  ldr r0, =enemy_0
  bl enemy_render_one
  pop {pc}

