.macro put_pixel
//    ldr r10, pitch
    mov r10, #2560 // r10 = pitch
    mul r10, r1, r10 // r10 = y * pitch
    add r10, r0, lsl #2  // r10 = 4x + y * pitch

    str r2, [r12, r10]
.endm

/*
 * max3
 * returns maximum of three numbers
 * stored in r0, r1, r2
 * result is returned in r10
 */
.macro max3
    max2
    cmp r2, r10
    movgt r10, r2
.endm

/*
 * min3
 * returns minimum of three numbers
 * stored in r0, r1, r2
 * result is returned in r3
 */
.macro min3
    min2
    cmp r2, r10
    movlt r10, r2
.endm

/*
 * max2
 * return max of r0 r1 in r2
 */

.macro max2
    cmp r0, r1
    movlt r10, r1
    movge r10, r0
.endm

/*
 * min2
 * return min of r0 r1 in r2
 */

.macro min2
    cmp r0, r1
    movlt r10, r0
    movge r10, r1
.endm

