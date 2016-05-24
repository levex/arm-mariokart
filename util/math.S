.section ".text"

//Math functions

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


.globl mat_det_test
mat_det_test:
    push {lr}
    push {r0-r2}

    ldr r0, =matB
    bl mat_det_ext

    mov r0, r1
    add r0, #48
    bl uart_send_byte

    pop {r0-r2}
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


/* Computes determinant of 3x3
*  matrix with bottom row with only
*  ones.
*  Address of matrix is stored in r0
*  result is stored in r1
*/

.globl mat_det_ext
mat_det_ext:
    push {lr}
    push {r2-r8}

    add r0, #8

    ldmia r0, {r2,r3,r4,r5,r6,r7}
    mul r2, r2, r6
    mul r5, r5, r4
    mul r3, r3, r7
    add r2, r5
    add r2, r3

    ldmia r0, {r3,r4,r5,r6,r7,r8}
    mul r5, r5, r7
    mul r4, r4, r6
    mul r3, r3, r8
    add r3, r4
    add r3, r5

    sub r1, r2, r3

    pop {r2-r8}
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
    push {lr}

    push {r2}
    bl max2
    mov r0, r2
    pop {r2}
    mov r1, r2
    push {r2}
    bl max2
    mov r3, r2
    pop {r2}

    pop {lr}
    bx lr

/*
* min3
* returns minimum of three numbers
* stored in r0, r1, r2
* result is returned in r3
*/
.globl min3
min3:
    push {lr}

    push {r2}
    bl min2
    mov r0, r2
    pop {r2}
    mov r1, r2
    push {r2}
    bl min2
    mov r3, r2
    pop {r2}

    pop {lr}
    bx lr


/*
 * max2
 * return max of r0 r1 in r2
*/

.globl max2
max2:
    push {lr}

    cmp r0, r1
    ble max2_end_r1
    mov r2, r0
    b max2_end

    max2_end_r1:
        mov r2, r1

    max2_end:
    pop {lr}
    bx lr

/*
 * min2
 * return min of r0 r1 in r2
*/

.globl min2
min2:
    push {lr}

    cmp r0, r1
    ble min2_r0
    mov r2, r1
    b min2_end

    min2_r0:
        mov r2, r0

    min2_end:
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
