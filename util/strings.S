.section ".data"

.align
.globl hello_str
hello_str: .asciz "Hello, Lev!\n"

.align
.globl framebuffer_acquired_str
framebuffer_acquired_str: .asciz "\nFramebuffer acquired!\n"

/* Game strings */
.align
.globl score_str
score_str: .asciz "Elapsed time:"

.align
.globl health_str
health_str: .asciz "Health:"

.align
.globl speed_str
speed_str: .asciz "Speed:"

.align
.globl speed_units_str
speed_units_str: .asciz "Mph"

.align
.globl powerup_str
powerup_str: .asciz "Powerup:"

.align
.globl powerup_speed_str
powerup_speed_str: .asciz "Speed Boost"

.globl countdown_3_str, countdown_2_str, countdown_1_str, countdown_0_str
.align
countdown_3_str: .asciz "3..."
.align
countdown_2_str: .asciz "2..."
.align
countdown_1_str: .asciz "1..."
.align
countdown_0_str: .asciz "Go!"

