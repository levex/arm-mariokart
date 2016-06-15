.section ".data"

.globl fault_reset_str, fault_undefined_str, fault_swi_str
.globl fault_prefetch_abort_str, fault_data_abort_str, fault_reserved_str
.globl fault_irq_str, fault_fiq_str

.align
fault_reset_str: .asciz "Reset fault happened\n"
.align
fault_undefined_str: .asciz "Undefined isntructionfault happened\n"
.align
fault_swi_str: .asciz "SWI fault happened\n"
.align
fault_prefetch_abort_str: .asciz "Prefetch abort fault happened\n"
.align
fault_data_abort_str: .asciz "Data abort fault happened\n"
.align
fault_reserved_str: .asciz "Reserved (WTF) fault happened\n"
.align
fault_irq_str: .asciz "IRQ fault happened\n"
.align
fault_fiq_str: .asciz "FIQ fault happened\n"

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

