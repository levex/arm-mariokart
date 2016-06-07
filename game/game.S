.section ".text"
.include "graphics/colors.S"
.include "game/player.S"

.macro process_input
  bl led_ok_turn_off
  bl poll_gpio

  //On accelerate button pressed
  //player_accelerate

  //On de-accelerate button pressed
  //player_deaccelerate

  //On right button pressed
  //player_turn_right

  //On left button pressed
  //player_turn_left

  //On action button pressed
  //player_use_powerup
.endm

.macro process_logic
  player_move
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

  /* render kart */
  //ldr r0, =cube_data
  //bl model_display
  bl rotating_cube_demo
.endm


.macro render_hud
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
  ldr r3, [r3]
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
  ldr r12, =back_buffer
  render_scene
  bl copy_back_buffer
  /* TODO, this should run every 5 frames or so */
  ldr r12, =fb_addr
  ldr r12, [r12]
  render_hud
.endm

.globl game_loop
game_loop:  
  //bl fb_clear
  process_input
  process_logic
  render_everything

  ldr r0, game_over
  cmp r0, #1         // while game_over == false
  bne game_loop

.globl game_over
game_over: .byte 0

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
