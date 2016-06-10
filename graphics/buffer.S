.section ".text"
.globl copy_back_buffer
copy_back_buffer:
    push {r0-r1, lr}
    ldr r0, curr_y_offset
    cmp r0, #0
    beq 1f

    /* y_offset is not zero */
    mov r0, #0
    bl mbp_set_virtual_offset_y
    ldr r0, =curr_y_offset
    mov r1, #0
    str r1, [r0]
    ldr r0, =fb_addr
    ldr r12, [r0]
    pop {r0-r1, pc}

    1: /* y_offset = 0 */
     mov r0, #480
     bl mbp_set_virtual_offset_y // trashes r0 and r1
     ldr r0, =curr_y_offset
     mov r1, #480
     str r1, [r0] // set current y_offset to 480
     ldr r0, [r0]
     add r12, r0, #1228800 // set r12
     pop {r0-r1, pc}

.globl curr_y_offset
.balign 4
curr_y_offset: .word 0

.section ".data"

.globl back_buffer
back_buffer: .skip 640*480*4

.globl depth_buffer
depth_buffer: .skip 640*480*4
