.macro put_pixel
//    ldr r10, pitch
    mov r10, #2560 // r10 = pitch
    mul r10, r1, r10 // r10 = y * pitch
    add r10, r0, lsl #2  // r10 = 4x + y * pitch

    str r2, [r12, r10]
.endm

