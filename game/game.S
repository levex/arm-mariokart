.section ".text"
.include "graphics/colors.S"

.macro process_input
  ldr r0, =player_angle
  ldr r0, [r0]
  ldr r1, =kart_angle
  str r0, [r1]

  bl poll_gpio          // r0 == button state

  tst r0, #(1 << 1)        // if (break button pressed)
  blne player_deaccelerate //   de-accelerate
  bleq player_accelerate   // else accelerate

  tst r0, #(1 << 2)        // if (turn right button pressed)
  blne player_turn_right   //   turn right

  tst r0, #(1 << 0)        // if (turn left button pressed)
  blne player_turn_left    //   turn left
.endm

.macro process_logic
  bl player_move
  bl player_powerup_check_proximity
  bl player_powerup_check_expiry
  bl enemy_progress
.endm

.macro render_scene
  /*reset triangle count*/
  ldr r0, =vertex_buffer_object
  mov r1, #0
  str r1, [r0]

  /* render skybox */
  mov r0, #0
  mov r1, #0
  ldr r2, =sky_pbmp
  add r2, r2, #8
  mov r3, #640
  mov r4, #380
  bl fb_copy_rect

  /* render map */
  /* TODO */

/* calculate camera coordinates*/
  ldr r0, =player_angle
  ldr r0, [r0]
  vmov.s32 s0, r0
  vcvt.s32.f32 s0, s0

  ldr r0, =camera_distance
  ldr r0, [r0]
  vmov.s32 s5, r0

  vmov.f32 r0, s0
  bl sin
  vmov.f32 s2, r0       //s2 = sin(player_angle)
  vmul.f32 s2, s2, s5   //s2 = x difference

  vmov.f32 r0, s0
  bl cos
  vmov.f32 s3, r0       //s3 = cos(player_angle)
  vmul.f32 s3, s3, s5   //s3 = z difference

  ldr r0, =player_x
  ldr r0, [r0]
  vmov.f32 s0, r0
  vsub.f32 s0, s0, s2
  vmov.f32 r0, s0

  ldr r1, =player_y
  ldr r1, [r1]
  vmov.f32 s0, r1 // s0 = y
  ldr r3, =0x40a00000 // 5.0 in IEEE 754 SP float
  vmov.f32 s1, r3 // s1 = 5.0
  vadd.f32 s0, s0, s1    /* make sure the camera is a bit up */
  vmov.f32 r1, s0

  ldr r2, =player_z
  ldr r2, [r2]
  vmov.f32 s0, r2
  //ldr r3, =0xc1700000
  //vmov.f32 s1, r3
  //vadd.f32 s0, s1
  vsub.f32 s0, s3
  vmov.f32 r2, s0

  ldr r3, =eye

  str r0, [r3, #0]
  str r1, [r3, #4]
  str r2, [r3, #8]

  ldr r3, =at

  /*set where are we looking at*/
  ldr r0, =player_x
  ldr r0, [r0]

  ldr r1, =player_y
  ldr r1, [r1]

  ldr r2, =player_z
  ldr r2, [r2]

  str r0, [r3, #0]
  str r1, [r3, #4]
  str r2, [r3, #8]

  /* calculate view matrix */
  ldr r0, =eye
  ldr r1, =at
  ldr r2, =up
  ldr r3, =view_matrix
  bl view_matrix_gen

  ldr r0, =view_matrix
  //bl print_matrix

  /* calculate VP matrix */
  ldr r1, =projection_matrix
  ldr r0, =view_matrix
  ldr r2, =vp_matrix
  bl mat4_mul_mat4   // p x v ==> vp

  mov r0, #0
  ldr r1, =0xc0400000
  ldr r2, =0xbf800000
  ldr r3, =model_matrix
  bl get_translation_matrix

  ldr r0, =example_map
  bl model_display

  /* calculate model matrix for the kart and the camera*/
  /*rotation*/
  ldr r0, =kart_angle
  vldr.f32 s0, [r0]
  vcvt.s32.f32 s0, s0
  vmov.s32 r0, s0
  ldr r1, =tmp_matrix
  bl get_rotation_y_matrix

  /*translation*/
  ldr r0, =player_x
  ldr r0, [r0]

  ldr r1, =player_y
  ldr r1, [r1]

  ldr r2, =player_z
  ldr r2, [r2]

  ldr r3, =tmp2_matrix
  bl get_translation_matrix

  /*model mat*/
  ldr r1, =tmp2_matrix
  ldr r0, =tmp_matrix
  ldr r2, =model_matrix
  bl mat4_mul_mat4

    /* render kart */
//  ldr r0, =coffin_kart
  ldr r0, =kart
  bl model_display

  bl enemy_render

  bl render_frame
.endm


.macro render_hud
  bl hud_clear

  /* Health */
  mov r0, #10
  ldr r1, =400
  mov r2, #color_red
  ldr r3, =health_str
  bl render_string

  /* Health hearts */
  mov r0, #55
  mov r3, #2              // Heart character

  ldr r5, =player_health  // Load player health
  ldr r5, [r5]

  mov r4, #0              // counter
  2:
  add r0, r0, #6          // x += 6
  bl render_char          // Render 1 heart
  add r4, r4, #1          // counter++
  cmp r4, r5              // while (counter < health)
  blt 2b

  /* Speed */
  mov r0, #10
  ldr r1, =420
  ldr r3, =speed_str
  bl render_string

  mov r0, #55
  ldr r3, =player_speed
  vldr.f32 s0, [r3]
  vcvt.s32.f32 s0, s0
  vmov.s32 r3, s0
  bl render_int

  mov r0, #80
  ldr r3, =speed_units_str
  bl render_string

  /* Powerups */
  mov r0, #10
  ldr r1, =440
  ldr r3, =powerup_str
  bl render_string
 
  ldr r3, =player_powerup
  ldr r3, [r3]
  mov r0, #1
  cmp r3, r0
  bne 1f                      // if (player_powerup) {
  mov r0, #340
  mov r2, #color_red
  ldr r3, =powerup_speed_str  //   render powerup
  bl render_string            // }
  1:
.endm

.macro render_everything
  render_scene
  /* TODO, this should run every 5 frames or so */
  render_hud

  bl copy_back_buffer
.endm

.globl game_loop
game_loop:
  bl time_stamp_get
  mov r3, r0
  //bl player_turn_right
  push {r0-r5}
  process_input
  process_logic
  render_everything
  pop {r0-r5}

  bl time_stamp_get
  mov r4, r0
  ldr r5, =0x411A
  sub r4, r4, r3
  subs r0, r5, r4
  blgt wait_realtime

  ldr r0, game_over
  cmp r0, #1         // while game_over == false
  bne game_loop

  1: b 1b

.globl game_over
game_over: .word 0

.globl road_data
.balign 16
road_data:
.word 10
.float -10, 0, 0, 1
.float -3.5, 0, 0, 1
.float -10, 0, -350, 1
.word 0x00666666, 0, 0, 0

.float -10, 0, -350, 1
.float -3.5, 0, 0, 1
.float -3.5, 0, -350, 1
.word 0x00666666, 0, 0, 0

.float -3.5, 0, 0, 1
.float -3, 0, 0, 1
.float -3.5, 0, -350, 1
.word 0x00FFFFFF, 0, 0, 0

.float -3.5, 0, -350, 1
.float -3, 0, 0, 1
.float -3, 0, -350, 1
.word 0x00FFFFFF, 0, 0, 0

.float -3, 0, 0, 1
.float 3, 0, 0, 1
.float -3, 0, -350, 1
.word 0x00AAAAAA, 0, 0, 0

.float -3, 0, -350, 1
.float 3, 0, 0, 1
.float 3, 0, -350, 1
.word 0x00AAAAAA, 0, 0, 0

.float 3, 0, 0, 1
.float 3.5, 0, 0, 1
.float 3, 0, -350, 1
.word 0x00FFFFFF, 0, 0, 0

.float 3, 0, -350, 1
.float 3.5, 0, 0, 1
.float 3.5, 0, -350, 1
.word 0x00FFFFFF, 0, 0, 0

.float 3.5, 0, -350, 1
.float 3.5, 0, 0, 1
.float 10, 0, 0, 1
.word 0x00666666, 0, 0, 0

.float 3.5, 0, -350, 1
.float 10, 0, 0, 1
.float 10, 0, -350, 1
.word 0x00666666, 0, 0, 0

.globl cube_data
.balign 16
cube_data:
.word 12
// Front Face: red
// CCW
.float -1, 1, 1, 1  // A
.float -1, -1, 1, 1  // B
.float 1, -1, 1, 1  // C
.word  0x00FF0000, 0, 0, 0  // pad

// CCW
.float -1, 1, 1, 1  // A
.float 1, -1, 1, 1  // C
.float 1, 1, 1, 1  // D
.word  0x00FF0000, 0, 0, 0  // pad

// Right Face: green
// CCW
.float 1, -1, 1, 1  // C
.float 1, -1, -1, 1  // G
.float 1, 1, 1, 1  // D
.word  0x0000FF00,0,0, 0  // pad

// CCW
.float 1, 1, 1, 1  // D
.float 1, -1, -1, 1  // G
.float 1, 1, -1, 1  // H
.word  0x0000FF00,0,0, 0  // pad

// Back Face
.float 1, 1, -1, 1  // H
.float 1, -1, -1, 1  // G
.float -1, -1, -1, 1  // F
.word  0x000000FF,0,0, 0  // pad

.float 1, 1, -1, 1  // H
.float -1, -1, -1, 1  // F
.float -1, 1, -1, 1  // E
.word  0x000000FF,0,0, 0  // pad

// Left Face
.float -1, 1, -1, 1  // E
.float -1, -1, -1, 1  // F
.float -1, -1, 1, 1  // B
.word  0x0000FFFF,0,0, 0  // pad

.float -1, -1, 1, 1  // B
.float -1, 1, 1, 1  // A
.float -1, 1, -1, 1  // E
.word  0x0000FFFF,0,0, 0  // pad

// Top Face
.float -1, 1, -1, 1  // E
.float -1, 1, 1, 1  // A
.float 1, 1, 1, 1  // D
.word  0x00FFFF00,0,0, 0  // pad

.float -1, 1, -1, 1  // E
.float 1, 1, 1, 1  // D
.float 1, 1, -1, 1  // H
.word  0x00FFFF00,0,0, 0  // pad

// Bottom Face
.float -1, -1, 1, 1  // B
.float -1, -1, -1, 1  // F
.float 1, -1, -1, 1  // G
.word  0x00FFFFFF,0,0, 0  // pad

.float -1, -1, 1, 1  // B
.float 1, -1, -1, 1  // G
.float 1, -1, 1, 1  // C
.word  0x00FFFFFF,0,0, 0  // pad

.globl cube_data2
cube_data2:
.word 12
.word 100, 100, 100, 1  // A
.word 100, 200, 100, 1  // B
.word 200, 200, 100, 1  // C
.word 0x00FF0000,0,0, 0  // pad

.word 100, 100, 100, 1  // A
.word 200, 200, 100, 1  // C
.word 200, 100, 100, 1  // D
.word 0x00FF0000,0,0, 0  // pad

.word 200, 200, 100, 1  // C
.word 200, 200, 200, 1  // G
.word 200, 100, 100, 1  // D
.word 0x0000FF00,0,0, 0  // pad

.word 200, 100, 100, 1  // D
.word 200, 200, 200, 1  // G
.word 200, 100, 200, 1  // H
.word 0x0000FF00,0,0, 0  // pad

.word 200, 100, 200, 1  // H
.word 200, 200, 200, 1  // G
.word 100, 200, 200, 1  // F
.word 0x000000FF,0,0, 0  // pad

.word 200, 100, 200, 1  // H
.word 100, 200, 200, 1  // F
.word 100, 100, 200, 1  // E
.word 0x000000FF,0,0, 0  // pad

.word 100, 100, 200, 1  // E
.word 100, 200, 200, 1  // F
.word 100, 200, 100, 1  // B
.word 0x0000FFFF,0,0, 0  // pad

.word 100, 100, 200, 1  // E
.word 100, 200, 100, 1  // B
.word 100, 100, 100, 1  // A
.word 0x0000FFFF,0,0, 0  // pad

.word 100, 100, 200, 1  // E
.word 100, 100, 100, 1  // A
.word 200, 100, 100, 1  // D
.word 0x00FFFF00,0,0, 0  // pad

.word 100, 100, 200, 1  // E
.word 200, 100, 100, 1  // D
.word 200, 100, 200, 1  // H
.word 0x00FFFF00,0,0, 0  // pad

.word 100, 200, 100, 1  // B
.word 100, 200, 200, 1  // F
.word 200, 200, 200, 1  // G
.word 0x00FFFFFF,0,0, 0  // pad

.word 100, 200, 100, 1  // B
.word 200, 200, 200, 1  // G
.word 200, 200, 100, 1  // C
.word 0x00FFFFFF,0,0, 0  // pad
