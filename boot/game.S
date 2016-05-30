.section ".text"

.global game_over
game_over = 0

.macro process_input

.endm

.macro process_logic

.endm

.macro render_scene
.endm


.macro render_hud
  /* Health */
  mov r0, #10
  ldr r1, =390
  ldr r2, =color_red
  ldr r3, =score_str
  bl render_string

  /* Speed */
  mov r0, #10
  ldr r1, =420
  ldr r2, =color_red
  ldr r3, =score_str
  bl render_string

  /* Speed bar */
  mov r4, #0

  mov r0, #20
  ldr r1, =420
  ldr r2, =color_blue
  mov r3, #0 // Full block character
  speed_bar:
  add r0, r0, #5
  bl render_char
  ldr r5, =player_speed
  cmp r4, r5
  ble speed_bar

  /* Score */
  mov r0, #10
  ldr r1, =440
  ldr r2, =color_red
  ldr r3, =score_str
  bl render_string
.endm

.macro render_everything
  render_scene
  render_hud
.endm

.globl game_loop
game_loop:
  process_input
  process_logic
  render_everything

  ldr r0, =game_over
  cmp r0, #1 // while game_over == false
  bne game_loop
