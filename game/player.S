.section ".text"

/* Gameplay */

.globl player_health, player_score, player_powerup
player_health:        .word 10
player_score:         .word 0
player_powerup:       .word 0
player_powerup_time:  .word 0

/* Position and movement */

const_default_speed_limit:    .float 30
const_powerup_speed_limit:    .float 60
const_powerup_effective_time: .word  5000000  // 5 seconds
const_powerup_pickup_radius:  .float 15        

speed_limit:   .float 10
acceleration:  .float 3
turning_angle: .float 3
max_angle:     .float 360

.globl player_x, player_y, player_z, player_speed, player_angle
player_x:      .float -10
player_y:      .float 0
player_z:      .float -30
player_speed:  .float 0
player_angle:  .float 0

.globl camera_distance, kart_angle
camera_distance:    .float 15
kart_angle:         .float 0

.globl player_move
player_move:
  push {r0-r1, lr}

  vldr.f32 s3, player_x
  vldr.f32 s4, player_z
  vldr.f32 s5, player_speed

  vldr.f32 s0, player_angle      // r0 = angle
  vcvt.s32.f32 s0, s0
  vmov r0, s0

  mov r1, r0                // r1 = angle
  bl cos                    // r0 = cos(angle)
  vmov.f32 s0, r0           // s0 = cos(angle)

  mov r0, r1                // r0 = angle
  bl sin                    // r0 = sin(angle)
  vmov.f32 s1, r0           // s1 = sin(angle)

  vmul.f32 s1, s5, s1       // s1 = speed * sin(angle) = speed_x
  vmul.f32 s0, s5, s0       // s0 = speed * cos(angle) = speed_z
  ldr r10, =0x41a00000
  vmov.f32 s6, r10
  vdiv.f32 s0, s0, s6
  vdiv.f32 s1, s1, s6

  vadd.f32 s3, s3, s1       // x += speed_x
  vadd.f32 s4, s4, s0       // z += speed_z

  vstr.f32 s3, player_x
  vstr.f32 s4, player_z

  pop {r0-r1, pc}

.globl player_accelerate
player_accelerate:
  push {lr}

  vldr.f32 s0, player_speed         // s0 = player_speed
  vldr.f32 s1, speed_limit          // s1 = speed_limit
  vldr.f32 s2, acceleration         // s2 = acc

  vcmp.f32 s0, s1                   // if (speed < SPEED_LIMIT)
  fmstat
  vaddlt.f32 s0, s0, s2             //   speed += ACCELERATION
  vstrlt.f32 s0, player_speed       //   store new value

  pop {pc}

.globl player_deaccelerate
player_deaccelerate:
  push {r1, lr}
  
  vldr.f32 s0, player_speed         // s0 = speed
  mov r1, #0
  vmov.f32 s1, r1                   // s1 = 0
  vldr.f32 s2, acceleration         // s2 = acc

  vcmp.f32 s0, s1                   // if (speed > 0)
  fmstat
  vsubgt.f32 s0, s0, s2             //   speed -= ACCELERATION
  vstrgt.f32 s0, player_speed       //   store new value

  pop {r1, pc}

.globl player_turn_right
player_turn_right:
  push {r0, lr}

  vldr.f32 s0, player_angle         // s0 = angle
  vldr.f32 s1, max_angle            // s1 = max_angle
  vldr.f32 s2, turning_angle        // s2 = turning_angle
  vldr.f32 s4, kart_angle
  vldr.f32 s5, leaning_angle
  mov r0, #0
  vmov.f32 s3, r0                   // s3 = 0

  vcmp.f32 s0, s1                   // if (angle < 360)
  fmstat
  vaddlt.f32 s0, s0, s2             //   angle += TURNING_ANGLE
  vmovge.f32 s0, s3                 // else angle = 0

  vmov.f32 s4, s0
  vadd.f32 s4, s4, s5

  vstr.f32 s0, player_angle
  vstr.f32 s4, kart_angle

  pop {r0, pc}

.globl player_turn_left
player_turn_left:
  push {r0, lr}

  vldr.f32 s0, player_angle         // s0 = angle
  vldr.f32 s1, max_angle            // s1 = max_angle
  vldr.f32 s2, turning_angle        // s2 = turning_angle
  vldr.f32 s4, kart_angle
  vldr.f32 s5, leaning_angle
  mov r0, #0
  vmov.f32 s3, r0                   // s3 = 0

  vcmp.f32 s0, s3                   // if (angle > 0)
  fmstat
  vsubgt.f32 s0, s0, s2             //   angle -= TURNING_ANGLE
  vmovle.f32 s0, s1                 // else angle = 0

  vmov.f32 s4, s0
  vsub.f32 s4, s4, s5

  vstr.f32 s0, player_angle
  vstr.f32 s4, kart_angle

  pop {r0, pc}

/* Activates the speed powerup */
player_powerup_pickup:
  push {r0, lr}

  mov r0, #1
  str r0, player_powerup                  // Set powerup flag

  vldr.f32 s0, const_powerup_speed_limit  // Increase speed limit
  vstr.f32 s0, speed_limit



  bl time_stamp_get

        push {r0-r12, lr}
    bl uart_send_int_hex
    bl uart_send_newline
    pop {r0-r12, lr}

  str r0, player_powerup_time             // Store pick-up time

  pop {r0, pc}

/* Checks for expiry of the speed powerup */
.globl player_powerup_check_expiry
player_powerup_check_expiry:
  push {r0-r3, lr}

  ldr r2, player_powerup_time
  ldr r3, const_powerup_effective_time
  bl time_stamp_get                       // r0:r1 = current timestamp
  sub r2, r0, r2                          // r2 = time since powerup pickup
  cmp r2, r3                              // if (time since pickup < effective)
  blt 1f                                  //   return
                                          // else {
  mov r0, #0
  str r0, player_powerup                  // Clear powerup flag

  vldr.f32 s0, const_default_speed_limit  // Decrease speed limit
  vstr.f32 s0, speed_limit

  1:
  pop {r0-r3, pc}

.globl player_powerup_check_proximity
player_powerup_check_proximity:
  push {r0-r2, lr}

  ldr r0, =example_powerups_num
  ldr r0, [r0]

  ldr r2, =example_powerups                // address counter
  vldr.f32 s6, const_powerup_pickup_radius // pickup radius

  mov r1, #0
  1:
    cmp r1, r0                     // for (int i=0; i < powerups_num; i++) {
    bge 2f                         // 
    vldm.f32 r2, {s0-s1}           //   s0 = powerup_x, s1 = powerup_z
    vldr.f32 s2, player_x          //   s2 = player_x
    vldr.f32 s3, player_z          //   s3 = player_z

    bl distance                 //   s4 = distance between player and powerup

    vcmp.f32 s4, s6                //   if (distance <= PICKUP_RADIUS) {
    fmstat                         //     player.pickupPowerup(); 
    blle player_powerup_pickup     //   }
    add r2, r2, #8                     //   increment address to check next powerup
    add r1, r1, #1
    b 1b                           // }
  2:
  pop {r0-r2, pc}








