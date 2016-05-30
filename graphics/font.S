.section ".text"
.include "util/macros.S"

/* Draws a given string to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - font color
*  r3 - pointer to string
*/
.globl render_string
render_string:
  push {r4, lr}

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

  pop {r4, pc}


/* Draws a given character to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - font color
*  r3 - character
*/
.globl render_char
render_char:
  push {r4-r9, lr}

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

  pop {r4-r9, pc} 
