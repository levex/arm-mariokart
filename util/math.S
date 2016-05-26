.section ".text"

//Math functions


/* Returns a translation matrix. Arguments:
*  r0 - translation amount in X direction
*  r1 - translation amount in Y direction
*  r2 - translation amount in Z direction
*  r3 - pointer to 4x4 matrix reprenenting the translation
*/
.globl get_translation_matrix
get_translation_matrix:
    push {lr}
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
    pop {lr}
    bx lr

/* Returns a scaling matrix. Arguments:
*  r0 - scaling amount in X direction
*  r1 - scaling amount in Y direction
*  r2 - scaling amount in Z direction
*  r3 - pointer to 4x4 matrix reprenenting the scaling
*/
.globl get_scaling_matrix
get_scaling_matrix:
    push {lr}
    push {r4}

    mov r4, #0
    mov r5, #1

    str r0, [r3]       // X
    str r4, [r3, #4]   // 0
    str r4, [r3, #8]   // 0
    str r4, [r3, #12]  // 0

    str r4, [r3, #16]  // 0
    str r1, [r3, #20]  // Y
    str r4, [r3, #24]  // 0
    str r4, [r3, #28]  // 0

    str r4, [r3, #32]  // 0
    str r4, [r3, #36]  // 0
    str r2, [r3, #40]  // Z
    str r4, [r3, #44]  // 0

    str r4, [r3, #48]  // 0
    str r4, [r3, #52]  // 0
    str r4, [r3, #56]  // 0
    str r5, [r3, #60]  // 1

    pop {r4}
    pop {lr}
    bx lr

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
* max3
* returns maximum of three numbers
* stored in r0, r1, r2
* result is returned in r3
*/
.globl max3
max3:
    cmp r0, r1
    movlt r3, r1
    movge r3, r0
    cmp r2, r3
    movgt r3, r2

    bx lr

/*
* min3
* returns minimum of three numbers
* stored in r0, r1, r2
* result is returned in r3
*/
.globl min3
min3:
    cmp r0, r1
    movlt r3, r0
    movge r3, r1
    cmp r2, r3
    movlt r3, r2

    bx lr


/*
 * max2
 * return max of r0 r1 in r2
*/

.globl max2
max2:
    cmp r0, r1
    movlt r2, r1
    movge r2, r0

    bx lr

/*
 * min2
 * return min of r0 r1 in r2
*/

.globl min2
min2:
    cmp r0, r1
    movlt r2, r0
    movge r2, r1

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
