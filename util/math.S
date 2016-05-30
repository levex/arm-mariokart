.section ".text"

//Math functions


// Trigonometric functions

// takes angle in r0, returns r0 = sin(r0)
.globl sin
sin:
    ldr r10, =sine_lookup
    lsl r0, #2
    ldr r0, [r10, r0]
    mov pc, lr

// takes angle in r0, returns r0 = cos(r0)
.globl cos
cos:
    ldr r10, =cosine_lookup
    lsl r0, #2
    ldr r0, [r10, r0]
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

    mov r4, #1
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

    mov r4, #1
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
    eor r3, r3, #0x80000000 // r3 = -sin(xrot)

    mov r4, #1
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
    mov r5, #1

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

/*
 * Transforms a vertex based on the matrix
 *
 * r1 - Pointer to Transformation matrix
 * r2 - Pointer to Vertex
 */
.globl transform_vertex
transform_vertex:
    push {lr}

    ldr r3, [r1]  // r3 = a
    ldr r4, [r2]  // r4 = x
    mul r0, r3, r4 // r0 = ax

    ldr r3, [r1, #4] // r3 = b
    ldr r4, [r2, #4] // r4 = y
    mla r0, r3, r4, r0 // r0 = by + ax

    ldr r3, [r1, #8] // r3 = c
    ldr r4, [r2, #8] // r4 = z
    mla r0, r3, r4, r0 // r0 = by + ax + cz
    
    ldr r3, [r1, #12] // r3 = d
    add r0, r0, r3    // r0 = d + by + ax + cz
    mov r5, r0        // r5 = v1

    // second element now
    ldr r3, [r1, #16] // r3 = e
    ldr r4, [r2]      // r4 = x
    mul r0, r3, r4    // r0 = ex

    ldr r3, [r1, #20] // r3 = f
    ldr r4, [r2, #4] // r4 = y
    mla r0, r3, r4, r0 // r0 = fy + ex

    ldr r3, [r1, #24] // r3 = g
    ldr r4, [r2, #8] // r4 = z
    mla r0, r3, r4, r0 // r0 = gz + fy + ex

    ldr r3, [r1, #28] // r3 = h
    add r0, r0, r3    // r0 = h + gz + fy + ex
    mov r6, r0     // r6 = v2

    // third element
    ldr r3, [r1, #32] // r3 = i
    ldr r4, [r2]      // r4 = x
    mul r0, r3, r4    // r0 = ix

    ldr r3, [r1, #36] // r3 = j
    ldr r4, [r2, #4]  // r4 = y
    mla r0, r3, r4, r0  // r0 = jy + ix

    ldr r3, [r1, #40] // r3 = k
    ldr r4, [r2, #8]  // r4 = z
    mla r0, r3, r4, r0  // r0 = kz + jy + ix

    ldr r3, [r1, #44] // r3 = l
    add r0, r0, r3    // r0 = l + kz + jy + ix
    mov r7, r0        // r7 = v3

    // forth element
    mov r8, #1         // r8 = v4

    str r5, [r2]
    str r6, [r2, #4]
    str r7, [r2, #8]
    str r8, [r2, #12]
    
    pop {pc}


/* Matrix multiplication
*  r0 pointer to matrix A
*  r1 pointer to matrix B
*  r2 pointer to matrix C -- r8 matrix
*/

.globl mat_mult
mat_mult:
    push {lr}
    push {r3-r8}

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
    pop {r3-r8}
    pop {lr}
    bx lr


/* Matrix addition
*  r0 - matrix A
*  r1 - matrix B
*  r2 - matrix C - result
*/

.globl mat_add
mat_add:
    push {lr}
    push {r3-r7}

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
    pop {r3-r7}
    pop {lr}
    bx lr

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
    bx lr

matA:
    .word 3, 3
    .word 1, 1, 1
    .word 1, 1, 1
    .word 1, 1, 1

matB:
    .word 3, 3
    .word 2, 2, 2
    .word 3, 3, 3
    .word 1, 1, 1

matC:
    .word 3, 3
    .word 0, 0, 0
    .word 0, 0, 0
    .word 0, 0, 0
