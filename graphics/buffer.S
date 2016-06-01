.section ".data"

.globl copy_back_buffer
copy_back_buffer:
    push {lr}
    mov r0, #0
    mov r1, #0
    ldr r2, =back_buffer
    mov r3, #640
    mov r4, #380
    ldr r12, =fb_addr
    ldr r12, [r12]
    bl fb_copy_rect
    ldr r12, =back_buffer
    pop {pc}

.globl back_buffer
back_buffer: .skip 640*480*4

.globl depth_buffer
depth_buffer: .skip 640*480*4
