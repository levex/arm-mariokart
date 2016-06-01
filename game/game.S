.section ".text"
.include "graphics/colors.S"

.macro process_input
  bl led_ok_turn_off
  bl poll_gpio
.endm

.macro process_logic

.endm

.macro render_scene
.endm


.macro render_hud
  /* Health */
  mov r0, #10
  ldr r1, =400
  mov r2, #color_red
  ldr r3, =health_str
  bl render_string

  /* Health hearts */
  mov r0, #55
  ldr r1, =400
  mov r2, #color_red
  mov r3, #2              // Heart character

  ldr r5, =player_health  // Load player health
  ldr r5, [r5]

  // TODO: Maybe generate a heart string instead
  mov r4, #0              // counter
  hearts:
  add r0, r0, #6          // x += 6
  bl render_char          // Render 1 heart
  add r4, r4, #1          // counter++
  cmp r4, r5              // while (counter < health)
  blt hearts

  /* Speed */
  mov r0, #10
  ldr r1, =420
  mov r2, #color_red
  ldr r3, =speed_str
  bl render_string

  /* Score */
  mov r0, #10
  ldr r1, =440
  mov r2, #color_red
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

  
  ldr r0, game_over
  cmp r0, #1         // while game_over == false
  bne game_loop

.global game_over
game_over: .byte 0
