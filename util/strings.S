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
score_str: .asciz "Score:"

.align
.globl health_str
health_str: .asciz "Health:"

.align
.globl speed_str
speed_str: .asciz "Speed:"

.align
.globl powerups_str
powerups_str: .asciz "Powerups:"
