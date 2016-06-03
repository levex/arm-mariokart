.section ".text"
.include "util/macros.S"


/* Draws a given integer to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - font color
*  r3 - integer
*/
.globl render_int
render_int:
  push {r0-r7, lr}

  mov r4, #10 // base

  mov r7, #0
  mov r5, r3
  cmp r5, #0
  bge 1f
  mov r3, #0x2D       // ascii code of '-'
  bl render_char
  neg r5, r5
  add r0, r0, #6

  1:
      mov r3, r5
      bl udiv
      mov r6, r3
      mul r3, r4, r6
      sub r3, r5, r3
      push {r3}
      add r7, #1
      cmp r6, #0
      beq 2f
      mov r5, r6
      b 1b

  2:
      pop {r3}
      cmp r3, #10
      addlt r3, #0x30  // if r3 < 10, add it to ascii code of '0' to get char
      subge r3, #10    // else remove 10
      addge r3, #0x41  // and add ascii code of 'A' to get hex value
      bl render_char
      add r0, r0, #6
      sub r7, #1
      cmp r7, #0
      bne 2b

  mov r0, #0    // Append null character
  str r0, [r5]

  pop {r0-r7, pc}

/* Draws a given string to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - font color
*  r3 - pointer to string
*/
.globl render_string
render_string:
  push {r0-r5, lr}

  mov r4, r3               // r4 = r3 (pointer to first character)
  mov r5, #0               // x_offset = 0
  1:
    ldrb r3, [r4], #1         // r3 = *(r4 ++);

    push {r0}
    add r0, r0, r5         
    bl render_char            // render current character at x + x_offset
    pop {r0}
    add r5, r5, #6            // x_offset += 6

    cmp r3, #0                // if (r3 != 0)
    bne 1b                    //   goto 1;

  pop {r0-r5, pc}


/* Draws a given character to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - font color
*  r3 - character
*/
.globl render_char
render_char:
  push {r0-r9, lr}

  ldr r9, =font5x8        // *font

  mov r10, #5             // number of bytes per char
  mul r3, r3, r10         // r3 = 5 * r3

  mov r7, #0              // current_x = 0
  1:
    add r10, r9, r7          // r10 = font8x8 + current_x
    add r10, r10, r3         // r10 = font8x8 + current_x + r3
    ldrb r4, [r10]           // r4 = character row data

    mov r6, #0x80            // mask = 10 00 00 00
    mov r8, #0               // current_y = 0
    2: 
      tst r4, r6               // r4 & mask (test the current bit)
      beq 3f                   // if bit was not set, skip pixel drawing
      push {r0-r1}
      add r0, r0, r7           // drawn_x = x + current_x
      add r1, r1, r8           // drawn_y = y + current_y
      put_pixel                // draw pixel at (r0, r1), color given in r2
      pop {r0-r1}

      3:
      lsr r6, #1             // shift mask 1 bit to the right
      add r8, r8, #1         // current_y++
      cmp r8, #8             // while current_y < 8
      blt 2b

    add r7, r7, #1           // current_x++
    cmp r7, #5               // while current_x < 5
    blt 1b

  pop {r0-r9, pc} 
