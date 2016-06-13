.section ".text"
.include "util/macros.S"

//  Triangle rasterizer
//  I guess function is pretty obivous from name

/*
 * Loads x or y coords of 3 vertices
 * in r0 r1 r2
 * into r0 r1 r2
 */

.macro sort_vertices
    cmp r3, r4
    movgt r10, r4
    movgt r4, r3
    movgt r3, r10
    movgt r10, r1
    movgt r1, r0
    movgt r0, r10

    cmp r3, r5
    movgt r10, r5
    movgt r5, r3
    movgt r3, r10
    movgt r10, r2
    movgt r2, r0
    movgt r0, r10

    cmp r4, r5
    movgt r10, r5
    movgt r5, r4
    movgt r4, r10
    movgt r10, r2
    movgt r2, r1
    movgt r1, r10
.endm

.macro draw_line
    cmp r0, r1
    bge 13f

    cmp r2, #0
    blt 13f

    cmp r2, #380
    bgt 13f

    mov r10, #2560 // r10 = pitch
    mul r10, r2, r10 // r10 = y * pitch

    cmp r1, #640
    addlt r11, r10, r1, lsl #2
    addge r11, r10, #2560
    cmp r0, #0
    addge r10, r0, lsl #2  // r10 = 4x + y * pitch

    add r10, r12
    add r11, r12

    sub r11, #64
    cmp r10, r11
    bge 11f

    10:
        vstm r10!, {d8-d15}
        cmp r10, r11
        blt 10b

    11:
    add r11, #64

    12:
        vstr s16, [r10]
        add r10, #1
        cmp r10, r11
        blt 12b

    13:
    // nop
.endm

draw_flat_triangle:
    push {r0-r9}

    mov r9, #0

    cmp r0, r1
    movgt r10, r1
    movgt r1, r0
    movgt r0, r10
    movgt r10, r4
    movgt r4, r3
    movgt r3, r10

    subs r6, r0, r2  // dx1
    neglt r6, r6
    orrlt r9, #(1 << 2)

    subs r7, r1, r2  // dx2
    neglt r7, r7
    orrlt r9, #(1 << 1)

    subs r8, r3, r5  // dy
    neglt r8, r8      // abs(dy)
    orrlt r9, #(1 << 0)

    mov r3, r0      // r3 = x1_end   = v1.x
    mov r0, r2      // r0 = x1_start = v3.x
    mov r2, r5      // r2 = y_start  = v3.y
    mov r5, r4      // r5 = y_end    = v1.y
    mov r4, r1      // r4 = x2_end   = v2.x
    mov r1, r0      // r1 = x2_start = v3.x

    draw_line

    mov r10, r6, asr #1  // r10 = err1
    mov r11, r7, asr #1  // r11 = err2

    1:
      cmp r2, r5
      beq 5f

      2:
        cmp r0, r3
        beq 3f

        cmp r10, #0
        addlt r10, r6
        blt 3f
        sub r10, r8
        tst r9, #(1 << 2)
        addeq r0, #1
        subne r0, #1
        b 2b

      3:
        cmp r1, r4
        beq 4f

        cmp r11, #0
        addlt r11, r7
        blt 4f
        sub r11, r8
        tst r9, #(1 << 1)
        addeq r1, #1
        subne r1, #1
        b 3b

      4:
      tst r9, #(1 << 0)
      addeq r2, #1

      push {r10-r11}
      draw_line
      pop {r10-r11}

      tst r9, #(1 << 0)
      subne r2, #1

      b 1b

    5:
    draw_line
    pop {r0-r9}
    mov pc, lr

/*
 *  Rasterizes a triangle from
 *  set of three vertices.
 *  Input is given as addresses of three vertices
 *  in r0 r1 r2 (A, B, C) and r3 (color)
*/

.globl triangle
triangle:
    push {r0-r9, lr}

    // zero out d8-d15 to prepare for line copying
    mov r10, r3
    mov r11, r3
    fmdrr d8, r10, r11
    fcpyd d9, d8
    fcpyd d10, d8
    fcpyd d11, d8
    fcpyd d12, d8
    fcpyd d13, d8
    fcpyd d14, d8
    fcpyd d15, d8

    ldr r3, [r0, #4]
    ldr r4, [r1, #4]
    ldr r5, [r2, #4]
    ldr r0, [r0]
    ldr r1, [r1]
    ldr r2, [r2]

    sort_vertices

    cmp r4, r5
    bne 1f
    mov r10, r4
    mov r4, r5
    mov r5, r3
    mov r3, r10
    mov r10, r1
    mov r1, r2
    mov r2, r0
    mov r0, r10
    bl draw_flat_triangle
    b 3f

    1:
    cmp r3, r4
    bne 2f
    bl draw_flat_triangle
    b 3f

    2:
    sub r10, r4, r3       // v2.y - v1.y
    sub r11, r5, r3       // v3.y - v1.y
    vmov s0, s1, r10, r11
    vcvt.f32.s32 s0, s0
    vcvt.f32.s32 s1, s1
    vdiv.f32 s2, s0, s1   // (v2.y - v1.y) / (v3.y - v1.y)
    sub r11, r2, r0       // r11 = v3.x - v1.x
    vmov s3, r11
    vcvt.f32.s32 s3, s3
    vmul.f32 s4, s2, s3   // ((v2.y - v1.y) / (v3.y - v1.y)) * (v3.x - v1.x)
    vcvt.s32.f32 s4, s4   // convert line length to int
    vmov r10, s4
    add r6, r0, r10       // x_mid = v1.x +- (length of line); y_mid = r5
    mov r7, r2            // save v3.x
    mov r8, r5            // save v3.y
    mov r2, r0
    mov r5, r3
    mov r0, r6
    mov r3, r4
    cmp r10, #0
    subge r0, #1
    addlt r0, #1
    bl draw_flat_triangle

    mov r2, r7  // restore v3.x
    mov r5, r8  // restore v3.y
    vmov r10, s4
    cmp r10, #0
    addge r0, #1
    sublt r0, #1
    bl draw_flat_triangle

    3:
    pop {r0-r9, pc}

.globl render_frame
render_frame:
    push {r0-r5, lr}
    ldr r4, =vertex_buffer_object
    ldr r5, [r4], #4

    cmp r5, #0
    popeq {r0-r5, pc}

    1:
      mov r0, r4              // v1 address
      add r1, r4, #16         // v2 address
      add r2, r4, #32         // v3 address
      ldr r3, [r4, #48]       // load color

      bl triangle

      add r4, #64
      subs r5, #1
      bne 1b

    pop {r0-r5, pc}

.section ".data"

// Assume we will never render more than 4096 triangles
.globl vertex_buffer_object
.balign 16
vertex_buffer_object: .skip 4 + 4*4*4*4096

