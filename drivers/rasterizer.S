.section ".text"
.include "drivers/pixel.S"

//  Triangle rasterizer
//  I guess function is pretty obivous from name


.globl triangle_test
triangle_test:
    push {lr}
    ldr r0, =vertA
    ldr r1, =vertB
    ldr r2, =vertC
    bl triangle
    pop {lr}
    bx lr

/*
 *  Rasterizes a triangle from
 *  set of three vertices.
 *  Input is given as addresses of three vertices
 *  in r0 r1 r2 (A, B, C)
*/

.globl triangle
triangle:
    push {lr}
    push {r3-r11}

    push {r0-r2}
        bl load_3x
        bl max3
        mov r4, r3  // r4 = max x coord
    pop {r0-r2}
    push {r0-r2}
        bl load_3x
        bl min3
        mov r5, r3  // r5 = min x coord
    pop {r0-r2}
    push {r0-r2}
        bl load_3y
        bl max3
        mov r6, r3  // r6 = max y coord
    pop {r0-r2}
    push {r0-r2}
        bl load_3y
        bl min3
        mov r7, r3  // r7 = min y coord
    pop {r0-r2}

    //determine wounding of triangle
    bl edge_f
    lsr r11, r3, #31    //sign

    mov r8, r7  // r8 = row counter
    box_row:
        cmp r8, r6  // row <= max_y
        bgt box_end

        mov r9, r5  //r9 = col counter
    box_col:
        cmp r9, r4  //col < max_x
        bgt box_col_end

        push {r0-r1}
            mov r0, r9
            mov r1, r8
            bl create_pixel
        pop {r0-r1}

        push {r2} //r0 = A, r1 = B
            ldr r2, =vertP
            bl edge_f
        pop {r2}
        lsr r10, r3, #31
        cmp r10, r11
        bne box_next_pixel

        push {r0-r2} //r0 = r1 = B, r1 = r2 = C
            mov r0, r1
            mov r1, r2
            ldr r2, =vertP
            bl edge_f
        pop {r0-r2}
        lsr r10, r3, #31
        cmp r10, r11
        bne box_next_pixel

        push {r0-r2} //r1 = r0 = A, r0 = r2 = C
            mov r1, r0
            mov r0, r2
            ldr r2, =vertP
            bl edge_f
        pop {r0-r2}
        lsr r10, r3, #31
        cmp r10, r11
        bne box_next_pixel

        //check whether pixel belongs to
        //a triangle
        push {r0-r2}
            mov r0, r9
            mov r1, r8
            ldr r2, =0x0000FF00
            put_pixel
        pop {r0-r2}

    box_next_pixel:
        add r9, #1
        b box_col

    box_col_end:
        add r8, #1
        b box_row

    box_end:
    pop {r3-r11}
    pop {lr}
    bx lr

/*
 * Loads x coords of 3 vertices
   in r0 r1 r2
 * into r0 r1 r2
*/
.globl load_3x
load_3x:
    ldr r0, [r0]
    ldr r1, [r1]
    ldr r2, [r2]
    bx lr

.globl load_3y
load_3y:
    ldr r0, [r0, #4]
    ldr r1, [r1, #4]
    ldr r2, [r2, #4]
    bx lr

/*
* edge_f
* takes pointers to three points
* in r0 r1 r2 and pointer to matrix 
* in r3 and returns determinant
* of given matrix in r3
*/

.globl edge_f
edge_f:
    push {r4-r11}

    ldmia r0, {r4,r5}
    ldmia r1, {r6,r7}
    ldmia r2, {r8,r9}

    sub r10, r7, r9
    mul r10, r10, r4
    sub r11, r8, r6
    mul r11, r11, r5
    add r10, r10, r11
    mul r6, r6, r9
    mul r7, r7, r8
    add r10, r10, r6
    sub r10, r10, r7

    mov r3, r10

    pop {r4-r11}
    bx lr

/*
* create_pixel
* Creates a new pixel based on
* coords stored in r0 r1.
* Address is vertP
*/
.globl create_pixel
create_pixel:
    push {r2}

    ldr r2, =vertP
    str r0, [r2]
    str r1, [r2, #4]

    pop {r2}
    bx lr


//Triangle vertices - x | y coord
vertA:
    .word 70, 100

vertB:
    .word 140, 100

vertC:
    .word 100, 200

vertP:
    .word 0, 0

oneBottomMat:
    .word 3, 3
    .word 0, 0, 0
    .word 0, 0, 0
    .word 1, 1, 1
