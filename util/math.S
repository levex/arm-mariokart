.section ".text"

//Math functions

/* Matrix multiplication
*  r0 pointer to matrix A
*  r1 pointer to matrix B
*  r2 pointer to matrix C -- result matrix
*/

.globl mat_mult
mat_mult:
    push {lr}
    push {r3-r8}

    a_row .req r3
    b_col .req r4
    b_row .req r5
    result .req r8

    mov a_row, #0
    matrix:
        ldr r6, [r0]
        mov r7, #4
        mul r6, r7
        cmp a_row, r6
        beq end

        mov b_col, #0
    row:
        ldr r6, [r1, #4]
        mov r7, #4
        mul r6, r7
        cmp b_col, r6
        beq rowend

        mov b_row, #0
        mov result, #0   //result
    element:
        ldr r6, [r1] //B row counter
        mov r7, #4
        mul r6, r7
        cmp b_row, r6
        beq elementEnd

        mov r6, #3
        mul r6, a_row  //r7 = A row * 3
        add r6, b_row      //r7 = A row * 3 + B row
        add r6, #8         //r7 = &A + r7
        ldr r7, [r0, r6]  //r6 = A[A row * 3 + B row]

        mov r6, #3
        mul r6, b_row       //r7 = B row * 3
        add r6, b_col       //r7 = B row * 3 + B col
        add r6, #8          //r7 = &B + r7
        ldr r6, [r1, r6]  //r7 = B[B row * 3 + B col]

        mul r6, r7
        add result, r6      //add to the result

        add b_row, #4      //inc B row counter
        b element

    elementEnd:
        mov r6, #3
        mul r6, a_row
        add r6, b_col
        add r6, r2
        str result, [r6, #8]

        add b_col, #4
        b row

    rowend:
        add a_row, #4
        b matrix

    end:
    pop {r3-r8}
    pop {lr}
    bx lr


.globl mat_mult_test
mat_mult_test:
    push {lr}
    push {r0-r2}

    ldr r0, =matA
    ldr r1, =matB
    ldr r2, =matC
    bl mat_mult

    pop {r0-r2}
    pop {lr}
    bx lr

matA:
    .word 3, 3
    .word 1, 1, 1
    .word 1, 1, 1
    .word 1, 1, 1

matB:
    .word 3, 3
    .word 1, 1, 1
    .word 1, 1, 1
    .word 1, 1, 1

matC:
    .word 3, 3
    .word 0, 0, 0
    .word 0, 0, 0
    .word 0, 0, 0
