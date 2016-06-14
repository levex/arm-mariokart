.section ".text"

//Math functions


// Trigonometric functions

// takes angle in r0, returns r0 = sin(r0)
.globl sin
sin:
    ldr r10, =sine_lookup
    ldr r0, [r10, r0, LSL #2]
    mov pc, lr

// takes angle in r0, returns r0 = cos(r0)
.globl cos
cos:
    ldr r10, =cosine_lookup
    ldr r0, [r10, r0, LSL #2]
    mov pc, lr

// Determines the distance between two 2D points
// s0 -> x1
// s1 -> y1
// s2 -> x2
// s3 -> y2
// s4 <- distance
// clobbers: s4 - s5
.globl distance
distance:
  vsub.f32 s4, s0, s2      // s4 = x1 - x2
  vsub.f32 s5, s1, s3      // s5 = y1 - y2

  vmul.f32 s4, s4, s4      // s4 = (x1 - x2) ^ 2
  vmul.f32 s5, s5, s5      // s5 = (y1 - y2) ^ 2

  vadd.f32 s4, s4, s5      // s4 = (x1 - x2) ^ 2 + (y1 - y2) ^ 2
  vsqrt.f32 s4, s4         // s4 = sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
  mov pc, lr

// Determines the dot product of two vectors
// r0 -> first vector
// r1 -> second vector
// s0 <- dot product
// clobbers: s0 - s6
.globl vec_dot
vec4_dot:
  vldm.f32 r0, {s1-s3}
  vldm.f32 r1, {s4-s6}

  vmul.f32 s0, s1, s4
  vmla.f32 s0, s2, s5
  vmla.f32 s0, s3, s6

  mov pc, lr

/* Returns a rotation around Z matrix. Arguments:
*  r0 - rotation amount in Z direction
*  r1 - pointer to 4x4 matrix reprenenting the rotation
*/
.globl get_rotation_z_matrix
get_rotation_z_matrix:
    push {r2-r5, lr}

    mov r3, r0        // save zrot as r3
    bl sin
    mov r2, r0        // r2 = sin(zrot)
    mov r0, r3        // r0 = zrot
    bl cos            // r0 = cos(zrot)

    mov r3, r2
    eor r3, r3, #0x80000000 // r3 = -sin(zrot)

    mov r4, #0x3f800000
    mov r5, #0

    str r0, [r1]       // cos(zrot)
    str r3, [r1, #4]   // -sin(zrot)
    str r5, [r1, #8]   // 0
    str r5, [r1, #12]  // 0

    str r2, [r1, #16]  // sin(zrot)
    str r0, [r1, #20]  // cos(zrot)
    str r5, [r1, #24]  // 0
    str r5, [r1, #28]  // 0

    str r5, [r1, #32]  // 0
    str r5, [r1, #36]  // 0
    str r4, [r1, #40]  // 1
    str r5, [r1, #44]  // 0

    str r5, [r1, #48]  // 0
    str r5, [r1, #52]  // 0
    str r5, [r1, #56]  // 0
    str r4, [r1, #60]  // 1

    pop {r2-r5, pc}

/* Returns a rotation around Y matrix. Arguments:
*  r0 - rotation amount in Y direction
*  r1 - pointer to 4x4 matrix reprenenting the rotation
*/
.globl get_rotation_y_matrix
get_rotation_y_matrix:
    push {r2-r5, lr}

    mov r3, r0        // save yrot as r3
    bl sin
    mov r2, r0        // r2 = sin(yrot)
    mov r0, r3        // r0 = xrot
    bl cos            // r0 = cos(yrot)

    mov r3, r2
    eor r3, r3, #0x80000000 // r3 = -sin(yrot)

    mov r4, #0x3f800000
    mov r5, #0

    str r0, [r1]       // cos(yrot)
    str r5, [r1, #4]   // 0
    str r2, [r1, #8]   // sin(yrot)
    str r5, [r1, #12]  // 0

    str r5, [r1, #16]  // 0
    str r4, [r1, #20]  // 1
    str r5, [r1, #24]  // 0
    str r5, [r1, #28]  // 0

    str r3, [r1, #32]  // -sin(yrot)
    str r5, [r1, #36]  // 0
    str r0, [r1, #40]  // cos(yrot)
    str r5, [r1, #44]  // 0

    str r5, [r1, #48]  // 0
    str r5, [r1, #52]  // 0
    str r5, [r1, #56]  // 0
    str r4, [r1, #60]  // 1

    pop {r2-r5, pc}

/* Returns a rotation around X matrix. Arguments:
*  r0 - rotation amount in X direction
*  r1 - pointer to 4x4 matrix reprenenting the rotation
*/
.globl get_rotation_x_matrix
get_rotation_x_matrix:
    push {r2-r5, lr}

    mov r3, r0        // save xrot as r3
    bl sin
    mov r2, r0        // r2 = sin(xrot)
    mov r0, r3        // r0 = xrot
    bl cos            // r0 = cos(xrot)

    mov r3, r2
    eor r3, r3, #(1 << 31)

    mov r4, #0x3f800000
    mov r5, #0

    str r4, [r1]       // 1
    str r5, [r1, #4]   // 0
    str r5, [r1, #8]   // 0
    str r5, [r1, #12]  // 0

    str r5, [r1, #16]  // 0
    str r0, [r1, #20]  // cos(xrot)
    str r3, [r1, #24]  // -sin(xrot)
    str r5, [r1, #28]  // 0

    str r5, [r1, #32]  // 0
    str r2, [r1, #36]  // sin(xrot)
    str r0, [r1, #40]  // cos(xrot)
    str r5, [r1, #44]  // 0

    str r5, [r1, #48]  // 0
    str r5, [r1, #52]  // 0
    str r5, [r1, #56]  // 0
    str r4, [r1, #60]  // 1

    pop {r2-r5, pc}


/* writes the perspective matrix to location r0 */
.globl projection_matrix
.balign 16
projection_matrix:
  .float   1.433439,           0,          0,          0
  .float          0,    2.414213,          0,          0
  //.float          0,           0,   1.222222, -22.222222  // zfar=100
  .float          0,           0,  -1.068966,  -20.689655  // zfar=300
  .float          0,           0,         -1,           0

//.globl view_matrix 
//.balign 16
//view_matrix:
//  .float  1,  0,  0,   0
//  .float  0,  1,  0,   0
//  .float  0,  0,  1, -15
//  .float  0,  0,  0,   1

// r0 -> eye
// r1 -> at
// r2 -> up
// r3 -> dest
.globl view_matrix_gen 
view_matrix_gen:
  vldm.f32 r0, {s0-s2}   // eye{s0(x), s1(y), s2(z)}
  vldm.f32 r1, {s3-s5}   // at{s3(x), s4(y), s5(z)}
  vldm.f32 r2, {s6-s8}   // up{s6(x), s7(y), s8(z)}

  // cross(a, b) = {ay*bz-az*by,  az*bx-ax*bz, ax*by-ay*bx}

  // {s9, s10, s11} = (eye - at)
  vsub.f32 s9, s0, s3
  vsub.f32 s10, s1, s4
  vsub.f32 s11, s2, s5
  // find length
  vmul.f32 s12, s9, s9
  vmla.f32 s12, s10, s10
  vmla.f32 s12, s11, s11
  vsqrt.f32 s12, s12 // s12 = length(eye-at)
  // normalize
  vdiv.f32 s9, s9, s12
  vdiv.f32 s10, s10, s12
  vdiv.f32 s11, s11, s12
  // vz{s9, s10, s11} = norm(eye - at)

  // vx=normalize(cross(up, vz))
  vmul.f32 s3, s7, s11  // s3 = uy * vzz
  vmls.f32 s3, s8, s10  // s3 = uy * vzz - uz * vzy
  vmul.f32 s4, s8, s9   // s4 = uz * vzx
  vmls.f32 s4, s6, s11  // s4 = uz * vzx - ux * vzz
  vmul.f32 s5, s6, s10  // s5 = ux * vzy
  vmls.f32 s5, s7, s9   // s5 = ux * vzy - uy * vzx
  // find length
  vmul.f32 s12, s3, s3
  vmla.f32 s12, s4, s4
  vmla.f32 s12, s5, s5
  vsqrt.f32 s12, s12
  // normalize
  vdiv.f32 s3, s3, s12
  vdiv.f32 s4, s4, s12
  vdiv.f32 s5, s5, s12
  // vx{s3, s4, s5} = norm(cross(up, vz))

  // vy = cross(vz, vx)
  vmul.f32 s6, s10, s5  // ay * bz
  vmls.f32 s6, s11, s4  // ay * bz - az * by
  vmul.f32 s7, s11, s3  // az * bx
  vmls.f32 s7, s9, s5   // - ax * bz
  vmul.f32 s8, s9, s4   // ax * by
  vmls.f32 s8, s10, s3  // - ay * bx
  // no need to normalize, vz and vx are already normalized

  // vx{s3, s4, s5} = norm(cross(up, vz))
  // vy{s6, s7, s8}
  // vz{s9, s10, s11} = norm(eye - at)
  // eye{s0(x), s1(y), s2(z)}

  // invert eye
  mov r10, #0
  vmov.f32 s15, r10
  vmls.f32 s15, s0, s3
  vmls.f32 s15, s1, s4
  vmls.f32 s15, s2, s5
  vmov.f32 s16, r10
  vmls.f32 s16, s0, s6
  vmls.f32 s16, s1, s7
  vmls.f32 s16, s2, s8
  vmov.f32 s17, r10
  vmls.f32 s17, s0, s9
  vmls.f32 s17, s1, s10
  vmls.f32 s17, s2, s11
  vmov.f32 s0, s15
  vmov.f32 s1, s16
  vmov.f32 s2, s17

  vmov.f32 s12, s3
  vmov.f32 s13, s6
  vmov.f32 s14, s9
  vmov.f32 s15, s0
  vstm.f32 r3!, {s12-s15}

  vmov.f32 s12, s4
  vmov.f32 s13, s7
  vmov.f32 s14, s10
  vmov.f32 s15, s1
  vstm.f32 r3!, {s12-s15}

  vmov.f32 s12, s5
  vmov.f32 s13, s8
  vmov.f32 s14, s11
  vmov.f32 s15, s2
  vstm.f32 r3!, {s12-s15}

  vmov.f32 s12, r10
  vmov.f32 s13, s12
  vmov.f32 s14, s12
  mov r10, #0x3f800000
  vmov.f32 s15, r10
  vstm.f32 r3!, {s12-s15}

  sub r3, r3, #64

  mov pc, lr

/* Returns a translation matrix. Arguments:
*  r0 - translation amount in X direction
*  r1 - translation amount in Y direction
*  r2 - translation amount in Z direction
*  r3 - pointer to 4x4 matrix reprenenting the translation
*/
.globl get_translation_matrix
get_translation_matrix:
    push {r4-r5}

    mov r4, #0
    mov r5, #0x3f800000

    str r5, [r3]       // 1
    str r4, [r3, #4]   // 0
    str r4, [r3, #8]   // 0
    str r0, [r3, #12]  // X

    str r4, [r3, #16]  // 0
    str r5, [r3, #20]  // 1
    str r4, [r3, #24]  // 0
    str r1, [r3, #28]  // Y

    str r4, [r3, #32]  // 0
    str r4, [r3, #36]  // 0
    str r5, [r3, #40]  // 1
    str r2, [r3, #44]  // Z

    str r4, [r3, #48]  // 0
    str r4, [r3, #52]  // 0
    str r4, [r3, #56]  // 0
    str r5, [r3, #60]  // 1

    pop {r4-r5}
    mov pc, lr

/* Returns a scaling matrix. Arguments:
*  r0 - scaling amount in X direction
*  r1 - scaling amount in Y direction
*  r2 - scaling amount in Z direction
*  r3 - pointer to 4x4 matrix reprenenting the scaling
*  Trashes: r4-r7
*/
.globl get_scaling_matrix
get_scaling_matrix:
    mov r4, #0
    mov r5, #0
    mov r6, #0
    mov r7, #0

    str r0, [r3], #4     // X
    stmia r3!, {r4-r7}   // (0 0 0 0)T
    str r1, [r3], #4     // Y
    stmia r3!, {r4-r7}   // (0 0 0 0)T
    str r2, [r3], #4     // Z
    stmia r3!, {r4-r7}   // (0 0 0 0)T
    mov r2, #1           // 1
    str r2, [r3]         // TODO: there has to be a better way

    mov pc, lr


.macro copy_polygon
    mov r4, #8
    ldr r10, =input_polygon
    ldr r11, =output_polygon

    1:
      vldm.f32 r11!, {s0-s15}
      vstm.f32 r10!, {s0-s15}
      subs r4, #1
      bne 1b

    ldr r10, =input_polygon_vertices
    ldr r11, output_polygon_vertices
    str r11, [r10]
.endm

clip_polygon_w:
    mov r7, #0
    ldr r8, input_polygon_vertices
    mov r9, #0
    ldr r10, =input_polygon

    vmov.f32 s30, r7
    ldr r11, =0x3727c5ac // 1e-5
    vmov.f32 s31, r11
    vcmp.f32 s23, s31
    fmstat
    ldrlt r5, =0xbf800000
    ldrge r5, =0x3f800000
    vmov.f32 s25, r5

    ldr r11, =output_polygon

    1:
        vldm.f32 r10!, {s16-s19}
        vcmp.f32 s19, s31
        fmstat
        ldrlt r5, =0xbf800000
        ldrge r5, =0x3f800000
        vmov.f32 s24, r5

        vmul.f32 s26, s24, s25
        vcmp.f32 s26, s30
        fmstat
        bge 2f

        // s30 = intersection factor
        vsub.f32 s30, s31, s23
        vsub.f32 s29, s23, s19
        vdiv.f32 s30, s30, s29

        // newPoint = prev + f * (curr-prev)
        vsub.f32 s26, s16, s20
        vsub.f32 s27, s17, s21
        vsub.f32 s28, s18, s22
        vsub.f32 s29, s19, s23

        vmul.f32 s26, s26, s30
        vmul.f32 s27, s27, s30
        vmul.f32 s28, s28, s30
        vmul.f32 s29, s29, s30

        vadd.f32 s26, s20, s26
        vadd.f32 s27, s21, s27
        vadd.f32 s28, s22, s28
        vadd.f32 s29, s23, s29

        add r9, #1
        vstm.f32 r11!, {s26-s29}
        vmov.f32 s30, r7

        2:
        vcmp.f32 s24, s30
        fmstat
        addgt r9, #1
        vstmgt.f32 r11!, {s16-s19}

        vmov.f32 s25, s24
        vmov.f32 s20, s16
        vmov.f32 s21, s17
        vmov.f32 s22, s18
        vmov.f32 s23, s19

        subs r8, #1
        bne 1b

    ldr r11, =output_polygon_vertices
    str r9, [r11]
    copy_polygon
    mov pc, lr

clip_polygon_axis:
    mov r7, #0
    ldr r8, input_polygon_vertices
    mov r9, #0
    ldr r10, =input_polygon

    vmov.f32 s30, r7

    cmp r0, #1
    vmovlt.f32 s1, s20
    vmoveq.f32 s1, s21
    vmovge.f32 s1, s22
    vcmp.f32 s1, s23
    fmstat
    ldrgt r5, =0xbf800000
    ldrle r5, =0x3f800000
    vmov.f32 s25, r5
    ldr r11, =output_polygon
    1:
        vldm.f32 r10!, {s16-s19}
        cmp r0, #1
        vmovlt.f32 s0, s16
        vmoveq.f32 s0, s17
        vmovge.f32 s0, s18
        vcmp.f32 s0, s19
        fmstat
        ldrgt r5, =0xbf800000
        ldrle r5, =0x3f800000
        vmov.f32 s24, r5

        vmul.f32 s26, s24, s25
        vcmp.f32 s26, s30
        fmstat
        bge 2f

        // s30 = intersection factor
        vsub.f32 s30, s23, s1
        vsub.f32 s29, s19, s0
        vsub.f32 s29, s30, s29
        vdiv.f32 s30, s30, s29

        // newPoint = prev + f * (curr-prev)
        vsub.f32 s26, s16, s20
        vsub.f32 s27, s17, s21
        vsub.f32 s28, s18, s22
        vsub.f32 s29, s19, s23

        vmul.f32 s26, s26, s30
        vmul.f32 s27, s27, s30
        vmul.f32 s28, s28, s30
        vmul.f32 s29, s29, s30

        vadd.f32 s26, s20, s26
        vadd.f32 s27, s21, s27
        vadd.f32 s28, s22, s28
        vadd.f32 s29, s23, s29

        add r9, #1
        vstm.f32 r11!, {s26-s29}
        vmov.f32 s30, r7


        2:
        vcmp.f32 s24, s30
        fmstat
        addgt r9, #1
        vstmgt.f32 r11!, {s16-s19}

        vmov.f32 s25, s24
        vmov.f32 s20, s16
        vmov.f32 s21, s17
        vmov.f32 s22, s18
        vmov.f32 s23, s19
        vmov.f32 s1, s0

        subs r8, #1
        bne 1b

    ldr r11, =output_polygon_vertices
    str r9, [r11]
    copy_polygon

    mov r8, r9
    mov r9, #0
    ldr r10, =input_polygon

    cmp r8, #0
    moveq pc, lr

    cmp r0, #1
    vmovlt.f32 s1, s20
    vmoveq.f32 s1, s21
    vmovge.f32 s1, s22
    vneg.f32 s3, s1
    vcmp.f32 s3, s23
    fmstat
    ldrgt r5, =0xbf800000
    ldrle r5, =0x3f800000
    vmov.f32 s25, r5

    ldr r11, =output_polygon

    3:
        vldm.f32 r10!, {s16-s19}
        cmp r0, #1
        vmovlt.f32 s0, s16
        vmoveq.f32 s0, s17
        vmovge.f32 s0, s18
        vneg.f32 s2, s0
        vcmp.f32 s2, s19
        fmstat
        ldrgt r5, =0xbf800000
        ldrle r5, =0x3f800000
        vmov.f32 s24, r5

        vmul.f32 s26, s24, s25
        vcmp.f32 s26, s30
        fmstat
        bge 4f

        // s30 = intersection factor
        vadd.f32 s30, s23, s1
        vadd.f32 s29, s19, s0
        vsub.f32 s29, s30, s29
        vdiv.f32 s30, s30, s29

        // newPoint = prev + f * (curr-prev)
        vsub.f32 s26, s16, s20
        vsub.f32 s27, s17, s21
        vsub.f32 s28, s18, s22
        vsub.f32 s29, s19, s23

        vmul.f32 s26, s26, s30
        vmul.f32 s27, s27, s30
        vmul.f32 s28, s28, s30
        vmul.f32 s29, s29, s30

        vadd.f32 s26, s20, s26
        vadd.f32 s27, s21, s27
        vadd.f32 s28, s22, s28
        vadd.f32 s29, s23, s29

        add r9, #1
        vstm.f32 r11!, {s26-s29}
        vmov.f32 s30, r7

        4:
        vcmp.f32 s24, s30
        fmstat
        addgt r9, #1
        vstmgt.f32 r11!, {s16-s19}

        vmov.f32 s25, s24
        vmov.f32 s20, s16
        vmov.f32 s21, s17
        vmov.f32 s22, s18
        vmov.f32 s23, s19
        vmov.f32 s1, s0

        subs r8, #1
        bne 3b

    ldr r11, =output_polygon_vertices
    str r9, [r11]
    copy_polygon
    mov pc, lr

/*
 * Transforms a vertex based on the matrix
 *
 * r0 - Pointer to MVP matrix
 * r1 - Pointer to Vertex
 * r2 - Pointer to output vertex
 * r3 - Pointer to triangle counter
 */
.globl transform_triangle
transform_triangle:
  push {r0, r4-r9, lr}
  vldm.f32 r0, {s0-s15}
  mov r10, #3
  ldr r11, =input_polygon_vertices
  str r10, [r11]
  ldr r11, =input_polygon
  1:
    vldm.f32  r1!, {s16 - s19}

    vmul.f32  s20,  s0, s16
    vmul.f32  s21,  s4, s16
    vmul.f32  s22,  s8, s16
    vmul.f32  s23,  s12, s16

    vmla.f32  s20,  s1, s17
    vmla.f32  s21,  s5, s17
    vmla.f32  s22,  s9, s17
    vmla.f32  s23,  s13, s17

    vmla.f32  s20,  s2, s18
    vmla.f32  s21,  s6, s18
    vmla.f32  s22, s10, s18
    vmla.f32  s23, s14, s18

    vmla.f32  s20, s3, s19
    vmla.f32  s21, s7, s19
    vmla.f32  s22, s11, s19
    vmla.f32  s23, s15, s19

    vstm.f32  r11!, {s20 - s23}

    subs r10, #1
    bne 1b
/*
  bl clip_polygon_w
  ldr r10, input_polygon_vertices
  cmp r10, #0
  beq 4f
*/
  mov r0, #0
  bl clip_polygon_axis
  ldr r10, input_polygon_vertices
  cmp r10, #0
  beq 4f

  mov r0, #1
  bl clip_polygon_axis
  ldr r10, input_polygon_vertices
  cmp r10, #0
  beq 4f

  mov r0, #2
  bl clip_polygon_axis
  ldr r10, input_polygon_vertices
  cmp r10, #0
  beq 4f

  sub r10, #2
  ldr r11, =input_polygon
  vldm.f32 r11!, {s16 - s19}
  vldm.s32 r1!, {s12 - s15}

  ldr r0, =0x3f800000 // 1.0f
  vmov s24, r0

  ldr r0, =0x43a00000 // 320.0f
  vmov s25, r0

  ldr r0, =0x433e0000 // 190.0f
  vmov s26, r0

  /* flip y */
  ldr r0, =0x43be0000 // 380.0f
  vmov s27, r0

  /* normalize by w */
  vdiv.f32 s16, s16, s19 // x0 = x0 / w0
  vdiv.f32 s17, s17, s19 // y0 = y0 / w0
  vdiv.f32 s18, s18, s19 // z0 = z0 / w0
  vmov.f32 s19, s24      // w0 = 1

  vadd.f32 s16, s16, s24 // x0 += 1
  vadd.f32 s17, s17, s24 // y0 += 1
  vmul.f32 s16, s16, s25 // x0 *= 320
  vmul.f32 s17, s17, s26 // y0 *= 190
  vsub.f32 s17, s27, s17  // flip y0

  vcvt.s32.f32 s0, s16
  vcvt.s32.f32 s1, s17
  vcvt.s32.f32 s2, s18
  vcvt.s32.f32 s3, s19

  2:
    vldm.f32 r11, {s4-s11}
    add r11, #16

    /* normalize by w */
    vdiv.f32 s4, s4, s7 // x1 = x1 / w1
    vdiv.f32 s5, s5, s7 // y1 = y1 / w1
    vdiv.f32 s6, s6, s7 // z1 = z1 / w1
    vmov.f32 s7, s24    // w1 = 1

    vdiv.f32 s8, s8, s11   // x2 = x2 / w2
    vdiv.f32 s9, s9, s11   // y2 = y2 / w2
    vdiv.f32 s10, s10, s11 // z2 = z2 / w2
    vmov.f32 s11, s24      // w2 = 1

    vadd.f32 s4, s4, s24 // x1 += 1
    vadd.f32 s5, s5, s24 // y1 += 1
    vmul.f32 s4, s4, s25 // x1 *= 320
    vmul.f32 s5, s5, s26 // y1 *= 190
    vsub.f32 s5, s27, s5  // flip y1

    vadd.f32 s8, s8, s24 // x2 += 1
    vadd.f32 s9, s9, s24 // y2 += 1
    vmul.f32 s8, s8, s25 // x2 *= 320
    vmul.f32 s9, s9, s26 // y2 *= 190
    vsub.f32 s9, s27, s9  // flip y2

    /* do backface culling */
    vmul.f32 s31, s16, s5 //   x0 * y1
    vmla.f32 s31, s8, s17 // + x2 * y0
    vmla.f32 s31, s4, s9  // + x1 * y2
    vmls.f32 s31, s16, s9 // - x0 * y2
    vmls.f32 s31, s4, s17 // - x1 * y0
    vmls.f32 s31, s8, s5  // - x2 * y1
    vmov.f32 r9, s31

    cmp r9, #0
    bge 3f

    /* convert to signed integer */
    vcvt.s32.f32 s4, s4
    vcvt.s32.f32 s5, s5
    vcvt.s32.f32 s6, s6
    vcvt.s32.f32 s7, s7
    vcvt.s32.f32 s8, s8
    vcvt.s32.f32 s9, s9
    vcvt.s32.f32 s10, s10
    vcvt.s32.f32 s11, s11

    vstm.s32 r2!, {s0 - s15}

    ldr r9, [r3]
    add r9, #1
    str r9, [r3]

    3:
    subs r10, #1
    bne 2b

  4:
  pop {r0, r4-r9, pc}

.balign 16
input_polygon: .skip 4*4*32

.balign 16
output_polygon: .skip 4*4*32

.balign 16
input_polygon_vertices: .word 0

.balign 16
output_polygon_vertices: .word 0

// Multiply a mat4 with an mat4
// r0 location of first matrix
// r1 location of second matrix
// r2 location of output matrix
// resulting matrix is also kept in {s0-s15}
.globl mat4_mul_mat4
mat4_mul_mat4:
  vldm.f32 r0, {s0-s15}
  // s0  s1  s2  s3
  // s4  s5  s6  s7
  // s8  s9  s10 s11
  // s12 s13 s14 s15
  mov r10, #4
1:
  vldm.f32 r1!, {s16-s19}   // {s16, s17, s18, s19}

  vmul.f32 s20,  s0, s16
  vmla.f32 s20,  s4, s17
  vmla.f32 s20,  s8, s18
  vmla.f32 s20, s12, s19

  vmul.f32 s21,  s1, s16
  vmla.f32 s21,  s5, s17
  vmla.f32 s21,  s9, s18
  vmla.f32 s21, s13, s19

  vmul.f32 s22,  s2, s16
  vmla.f32 s22,  s6, s17
  vmla.f32 s22, s10, s18
  vmla.f32 s22, s14, s19

  vmul.f32 s23,  s3, s16
  vmla.f32 s23,  s7, s17
  vmla.f32 s23, s11, s18
  vmla.f32 s23, s15, s19

  vstm.f32 r2!, {s20-s23}

  subs r10, #1
  bne 1b

  sub r1, r1, #64
  sub r2, r2, #64

  mov pc, lr

/* Matrix multiplication
*  r0 pointer to matrix A
*  r1 pointer to matrix B
*  r2 pointer to matrix C -- r8 matrix
*/

.globl mat_mult
mat_mult:
    push {r3-r8, lr}

    mov r3, #0  //A row counter
    mmult_a_row:
        ldr r6, [r0]
        cmp r3, r6, LSL #4
        beq mmult_end

        mov r4, #0  //B col counter
    mmult_b_col:
        ldr r6, [r1, #4]
        cmp r4, r6, LSL #4
        beq mmult_b_col_end

        mov r5, #0   //B row counter
        mov r8, #0   //result accumulator
    mmult_element:
        ldr r6, [r1]
        cmp r5, r6, LSL #4
        beq mmult_element_end

        mov r6, #3
        mul r6, r3  //r7 = A row * 3
        add r6, r5      //r7 = A row * 3 + B row
        add r6, #8         //r7 = &A + r7
        ldr r7, [r0, r6]  //r6 = A[A row * 3 + B row]

        mov r6, #3
        mul r6, r5       //r7 = B row * 3
        add r6, r4       //r7 = B row * 3 + B col
        add r6, #8          //r7 = &B + r7
        ldr r6, [r1, r6]  //r7 = B[B row * 3 + B col]

        mul r6, r7
        add r8, r6      //add to the r8

        add r5, #4      //inc B row counter
        b mmult_element

    mmult_element_end:
        mov r6, #3
        mul r6, r3
        add r6, r4
        add r6, r2
        str r8, [r6, #8]

        add r4, #4  //increment B col counter
        b mmult_b_col

    mmult_b_col_end:
        add r3, #4  //increment A row counter
        b mmult_a_row

    mmult_end:
    pop {r3-r8, pc}


/* Matrix addition
*  r0 - matrix A
*  r1 - matrix B
*  r2 - matrix C - result
*/

.globl mat_add
mat_add:
    push {r3-r7, lr}

    mov r3, #0
    add_row_loop:
        ldr r5, [r0]
        cmp r3, r5, LSL #2
        beq add_end

        mov r4, #0
    add_col_loop:
        ldr r5, [r0, #4]
        cmp r4, r5, LSL #2
        beq add_end_col

        mov r5, #3
        mul r5, r3
        add r5, r4
        add r5, #8

        ldr r6, [r0, r5]
        ldr r7, [r1, r5]
        add r6, r7
        str r6, [r2, r5]

        add r4, #4
        b add_col_loop

    add_end_col:
        add r3, #4
        b add_row_loop

    add_end:
    pop {r3-r7, pc}

/*
 * udiv - does unsigned division of r0 / r1
 *
 * result is stored in r0
 */
.globl udiv
udiv:
    push {r1-r3}

    clz r2, r1
    clz r3, r0
    subs r2, r3
    lsl r3, r1, r2
    mov r1, r0
    mov r0, #0
    blt 3f

    1:
        cmp r1, r3
        blt 2f

        add r0, r0, #1
        subs r1, r3
        lsleq r0, r2
        beq 3f
    2:
        subs r2, #1
        lsrge r3, #1
        lslge r0, #1
        bge 1b


    3:
    pop {r1-r3}
    mov pc, lr

