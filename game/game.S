.section ".text"
.include "graphics/colors.S"

.macro process_input
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
    //bl player_move
.endm

.macro render_scene
  /* render skybox */
  mov r0, #0
  mov r1, #0
  mov r3, #640
  mov r4, #380
  ldr r2, =sky_pbmp
  add r2, r2, #8
  bl fb_copy_rect

  /* render map */
  /* TODO */

  /* our camera is where the kart is */
  ldr r0, =player_x
  ldr r0, [r0]

  ldr r1, =player_y
  ldr r1, [r1]
  vmov.f32 s0, r1 // s0 = y
  ldr r3, =0x40a00000 // 5.0 in IEEE 754 SP float
  vmov.f32 s1, r3 // s1 = 5.0
  vadd.f32 s0, s0, s1    /* make sure the camera is a bit up */
  vmov.f32 r1, s0

  ldr r2, =player_z
  ldr r2, [r2]

  ldr r3, =eye

  str r0, [r3, #0]
  str r1, [r3, #4]
  str r2, [r3, #8]

  /* calculate view matrix */
  ldr r0, =eye
  ldr r1, =at
  ldr r2, =up
  ldr r3, =view_matrix
  bl view_matrix_gen

  /* calculate VP matrix */
  ldr r1, =projection_matrix
  ldr r0, =view_matrix
  ldr r2, =vp_matrix
  bl mat4_mul_mat4   // p x v ==> vp

  /* calculate model matrix for the kart */
  ldr r0, =player_angle
  vldr.f32 s0, [r0]
  vcvt.s32.f32 s0, s0
  vmov.s32 r0, s0
  ldr r1, =model_matrix
  bl get_rotation_y_matrix

  /* render kart */
  ldr r0, =cube_data
  bl model_display
.endm


.macro render_hud
  bl hud_clear
  /* Health */
  mov r0, #10
  ldr r1, =400
  mov r2, #color_red
  ldr r3, =health_str
  bl render_string

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

  /* Score */
  mov r0, #10
  ldr r1, =440
  ldr r3, =score_str
  bl render_string

  mov r0, #55
  ldr r3, =player_score
  ldr r3, [r3]
  bl render_int

  /* Health hearts */
  ldr r1, =400
  mov r3, #2              // Heart character

  ldr r5, =player_health  // Load player health
  ldr r5, [r5]

  mov r4, #0              // counter
  hearts:
  add r0, r0, #6          // x += 6
  bl render_char          // Render 1 heart
  add r4, r4, #1          // counter++
  cmp r4, r5              // while (counter < health)
  blt hearts

  /* Powerups */
  mov r0, #400
  ldr r1, =440
  ldr r3, =powerups_str
  bl render_string
.endm

.macro render_everything
  render_scene
  /* TODO, this should run every 5 frames or so */
  render_hud

  bl copy_back_buffer
.endm

.globl game_loop
game_loop:  
  process_input
  process_logic
  render_everything

  ldr r0, game_over
  cmp r0, #1         // while game_over == false
  bne game_loop

.globl game_over
game_over: .byte 0

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
