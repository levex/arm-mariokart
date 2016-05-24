.section ".text"

// Triangle rasterizer
// I guess function is pretty obivous from name

/*
 * Attempt to rasterize a triangle from
 * set of three vertices
*/
.globl triangle
triangle:
    push {lr}
    push {r0-r11}

    bl load_3x
    bl max3
    mov r4, r3  // r4 = max x coord
    bl load_3x
    bl min3
    mov r5, r3  // r5 = min x coord
    bl load_3y
    bl max3
    mov r6, r3  // r6 = max y coord
    bl load_3y
    bl min3
    mov r7, r3  // r7 = min y coord

    mov r8, r7  // r8 = row counter
    box_row:
        cmp r8, r6  // row <= max_y
        bgt box_end

        mov r9, r5  //r9 = col counter
    box_col:
        cmp r9, r4  //col < max_x
        bgt box_col_end

        mov r0, r9
        mov r1, r8
        bl create_pixel

        mov r10, #0

        ldr r0, =vertC
        ldr r1, =vertA
        ldr r2, =vertP
        bl edge_f
        cmp r3, r10
        bgt box_next_pixel

        ldr r0, =vertB
        ldr r1, =vertC
        ldr r2, =vertP
        bl edge_f
        cmp r3, r10
        bgt box_next_pixel

        ldr r0, =vertA
        ldr r1, =vertB
        ldr r2, =vertP
        bl edge_f
        cmp r3, r10
        bgt box_next_pixel

        //check whether pixel belongs to
        //a triangle
        mov r0, r9
        mov r1, r8
        ldr r2, =0x0000FF00
        bl fb_put_pixel

    box_next_pixel:
        add r9, #1
        b box_col

    box_col_end:
        add r8, #1
        b box_row

    box_end:
    pop {r0-r11}
    pop {lr}
    bx lr

/*
 * Loads x coords of 3 vertices 
 * into r0 r1 r2
*/
.globl load_3x
load_3x:
    push {lr}
    ldr r0, =vertA
    ldr r0, [r0]
    ldr r1, =vertB
    ldr r1, [r1]
    ldr r2, =vertC
    ldr r2, [r2]
    pop {lr}
    bx lr

.globl load_3y
load_3y:
    push {lr}
    ldr r0, =vertA
    ldr r0, [r0, #4]
    ldr r1, =vertB
    ldr r1, [r1, #4]
    ldr r2, =vertC
    ldr r2, [r2, #4]
    pop {lr}
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
    push {lr}
    push {r4-r9}

    ldmia r0, {r4,r5}
    ldmia r1, {r6,r7}
    ldmia r2, {r8,r9}

    add r3, #8
    str r4, [r3]
    str r5, [r3, #12]

    add r3, #4
    str r6, [r3]
    str r7, [r3, #12]

    add r3, #4
    str r8, [r3]
    str r9, [r3, #12]

    sub r3, #16
    push {r0-r1}
    mov r0, r3
    bl mat_det_ext
    mov r3, r1
    pop {r0-r1}

    pop {r4-r9}
    pop {lr}
    bx lr

/*
* create_pixel
* Creates a new pixel based on
* coords stored in r0 r1.
* Address is vertP
*/
.globl create_pixel
create_pixel:
    push {lr}
    push {r2}

    ldr r2, =vertP
    str r0, [r2]
    str r1, [r2, #4]

    pop {r2}
    pop {lr}
    bx lr


//Triangle vertices - x | y coord
vertA:
    .word 100, 100

vertB:
    .word 70, 130

vertC:
    .word 130, 130

vertP:
    .word 0, 0

barioCoord:
    .word 0, 0, 0

oneBottomMat:
    .word 3, 3
    .word 0, 0, 0
    .word 0, 0, 0
    .word 1, 1, 1
