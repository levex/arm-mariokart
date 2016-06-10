.section ".text"

/* Gameplay */

player_health: .word 10
player_score:  .word 999

/* Position and movement */

.EQU SPEED_LIMIT,    10
.EQU ACCELERATION,   1
.EQU TURNING_ANGLE,  1

player_x:      .word 0
player_y:      .word 0
player_z:      .word 0
player_speed:  .word 0
player_angle:  .word 0

.macro player_move
  ldr r3, =player_x
  ldr r3, [r3]

  ldr r4, =player_z
  ldr r4, [r4]

  ldr r5, =player_speed
  ldr r5, [r5]

  ldr r0, =player_angle
  ldr r0, [r0]              // r0 = angle
  mov r2, r0                // r2 = angle

  bl cos                    // r0 = cos(angle)
  mov r1, r0                // r1 = cos(angle)
  mov r0, r2                // r0 = angle
  bl sin                    // r0 = sin(angle)

  mul r0, r0, r5            // r0 = speed * sin(angle) = speed_x
  mul r1, r1, r5            // r1 = speed * cos(angle) = speed_z

  add r3, r3, r0            // x += speed_x
  add r4, r4, r1            // z += speed_z

  str r3, player_x
  str r4, player_z
.endm

.macro player_accelerate
  ldr r0, =player_speed
  ldr r0, [r0]

  mov r1, #SPEED_LIMIT
  cmp r0, r1                      // if (speed <= SPEED_LIMIT)
  addle r0, r0, #ACCELERATION     //   speed += ACCELERATION
  strle r0, =player_speed
.endm

.macro player_deaccelerate
  ldr r0, =player_speed
  ldr r0, [r0]

  mov r1, #0
  cmp r0, r1                      // if (speed > 0)
  subgt r0, r0, #ACCELERATION     //   speed -= ACCELERATION
  strgt r0, =player_speed
.endm

.macro player_turn_right
  ldr r3, =player_angle
  ldr r3, [r3]

  mov r4, #359          
  cmp r3, r4                      // if (angle < 359)
  addlt r3, r3, #TURNING_ANGLE    //   angle += TURNING_ANGLE
  movge r3, #0                    // else angle = 0

  str r3, player_angle
.endm

.macro player_turn_left
  ldr r3, =player_angle
  ldr r3, [r3]

  mov r4, #0          
  cmp r3, r4                      // if (angle > 0)
  subgt r3, r3, #TURNING_ANGLE    //   angle -= TURNING_ANGLE
  movle r3, #359                  // else angle = 359

  str r3, player_angle
.endm
