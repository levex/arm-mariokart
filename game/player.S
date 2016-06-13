.section ".text"

/* Gameplay */

.globl player_health, player_score
player_health: .word 10
player_score:  .word 999

/* Position and movement */

const_speed_limit: .float 10
const_acceleration: .float 1
const_turning_angle: .float 1
const_max_angle: .float 360

.globl player_x, player_y, player_z, player_speed, player_angle
player_x:      .float 0
player_y:      .float 0
player_z:      .float -15
player_speed:  .float 0
player_angle:  .float 0

.globl player_move
player_move:
  push {r0-r1, lr}

  vldr.f32 s3, player_x
  vldr.f32 s4, player_z
  vldr.f32 s5, player_speed

  ldr r0, player_angle      // r0 = angle
  mov r1, r0                // r1 = angle
  bl cos                    // r0 = cos(angle)
  vmov.f32 s0, r0           // s0 = cos(angle)

  mov r0, r1                // r0 = angle
  bl sin                    // r0 = sin(angle)
  vmov.f32 s1, r0           // s1 = sin(angle)

  vmul.f32 s1, s5, s1       // s1 = speed * sin(angle) = speed_x
  vmul.f32 s0, s5, s0       // s0 = speed * cos(angle) = speed_z

  vadd.f32 s3, s3, s1            // x += speed_x
  vadd.f32 s4, s4, s0            // z += speed_z

  vstr.f32 s3, player_x
  vstr.f32 s4, player_z

  pop {r0-r1, pc}

.globl player_accelerate
player_accelerate:
  vldr.f32 s0, player_speed // s0 = player_speed
  vldr.f32 s1, const_speed_limit  // s1 = speed_limit
  vldr.f32 s2, const_acceleration // s2 = acc

  vcmp.f32 s0, s1                      // if (speed <= SPEED_LIMIT)
  fmstat
  vaddle.f32 s0, s0, s2  //   speed += ACCELERATION
  vstrle.f32 s0, player_speed // store new value
  mov pc, lr

.globl player_deaccelerate
player_deaccelerate:
  push {r1}
  
  vldr.f32 s0, player_speed  // s0 = speed
  mov r1, #0
  vmov.f32 s1, r1  // s1 = 0
  vldr.f32 s2, const_acceleration   // s2 = acc

  vcmp.f32 s0, s1                      // if (speed > 0)
  fmstat
  vsubgt.f32 s0, s0, s2      //   speed -= ACCELERATION
  vstrgt.f32 s0, player_speed  // store new value

  pop {r1}
  mov pc, lr

.globl player_turn_right
player_turn_right:
  push {r0}

  vldr.f32 s0, player_angle // s0 = angle
  vldr.f32 s1, const_max_angle // s1 = max_angle
  vldr.f32 s2, const_turning_angle // s2 = turning_angle
  mov r0, #0
  vmov.f32 s3, r0   // s3 = 0

  vcmp.f32 s0, s1     // if (angle < 360)
  fmstat
  vaddlt.f32 s0, s0, s2 //   angle += TURNING_ANGLE
  vmovge.f32 s0, s3                    // else angle = 0

  vstr.f32 s0, player_angle

  pop {r0}
  mov pc, lr


.globl player_turn_left
player_turn_left:
  push {r0}

  vldr.f32 s0, player_angle // s0 = angle
  vldr.f32 s1, const_max_angle // s1 = max_angle
  vldr.f32 s2, const_turning_angle // s2 = turning_angle
  mov r0, #0
  vmov.f32 s3, r0   // s3 = 0

  vcmp.f32 s0, s3     // if (angle > 0)
  fmstat
  vsubgt.f32 s0, s0, s2 //   angle -= TURNING_ANGLE
  vmovle.f32 s0, s1                    // else angle = 0

  vstr.f32 s0, player_angle

  pop {r0}
  mov pc, lr
