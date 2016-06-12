.section ".text"

// timer driver
// Spec: BCM2835-ARM-Peripherials.pdf
// Section 12.

.equ TIMER_BASE, 0x20003000

// Gets the current timestamp into r0:r1
.globl time_stamp_get
time_stamp_get:
    push {r10}
    ldr r10, =TIMER_BASE
    ldrd r0, r1, [r10, #4]
    pop {r10}
    mov pc, lr


// waits precisely r0 microseconds
.globl wait_realtime
wait_realtime:
    push {lr}
    mov r10, r0
    bl time_stamp_get
    mov r11, r0
    add r11, r11, r10 // r11 is now our goal time
    1: bl time_stamp_get
       cmp r0, r11
       blt 1b
    pop {pc}
