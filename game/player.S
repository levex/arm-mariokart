.section ".text"

.EQU ACCELERATION_LIMIT, 10

player_health: .word 10
player_speed: .word 6
player_score: .word 999

player_x: .word 0
player_y: .word 0
player_z: .word 0

player_direction_x: .word 0
player_direction_y: .word 0
player_direction_z: .word 0

player_acceleration: .word 0

.macro player_move
  ldr r0, =player_direction_x
  ldr r0, [r0]

  ldr r1, =player_direction_y
  ldr r1, [r1]

  ldr r2, =player_direction_z
  ldr r2, [r2]

  ldr r3, =player_x
  ldr r3, [r3]

  ldr r4, =player_y
  ldr r4, [r4]

  ldr r5, =player_z
  ldr r5, [r5]

  ldr r6, =player_acceleration
  ldr r6, [r6]

  mul r0, r0, r6 // vel_x = direction_x * acceleration
  mul r1, r1, r6 // vel_y = direction_y * acceleration
  mul r2, r2, r6 // vel_z = direction_z * acceleration

  add r3, r3, r0 // x += vel_x
  add r4, r4, r1 // y += vel_y
  add r5, r5, r2 // z += vel_z

  str r3, player_x
  str r4, player_y
  str r5, player_z
.endm

.macro player_accelerate
  ldr r0, =player_acceleration
  ldr r0, [r0]

  mov r1, #ACCELERATION_LIMIT
  cmp r0, r1                      // if (acceleration < ACCELERATION_LIMIT)
  addlt r0, r0, #1                //   acceleration += 1
  strlt r0, =player_acceleration
.endm

.macro player_deaccelerate
  ldr r0, =player_acceleration
  ldr r0, [r0]

  mov r1, #ACCELERATION_LIMIT
  neg r1
  cmp r0, r1                      // if (acceleration > -ACCELERATION_LIMIT)
  subgt r0, r0, #1                //   acceleration -= 1
  strlt r0, =player_acceleration
.endm

.macro player_turn_right
.endm

.macro player_turn_left
.endm
