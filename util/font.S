.section ".text"
.include "util/macros.S"

/* Draws a given string to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - pointer to string
*/
.globl render_string
render_string:
  push {r3, lr}

  mov r4, r2               // r4 = r2 (pointer to first character)
  1:
    ldrb r2, [r4], #1      // r2 = *(r4 ++);

    mov r3, #0             // x_offset = 0
    push {r0}
    add r0, r0, r3         
    bl render_char         // render current character at x + x_offset
    pop {r0}
    add r3, r3, #8         // x_offset += 8

    cmp r2, #0             // if (r2 == 0)
    beq 2f                 //   goto 2;
    b 1b                   // else goto 1

  2:
    pop {r3, pc}


/* Draws a given character to the screen. Arguments:
*  r0 - x
*  r1 - y
*  r2 - character
*/
.globl render_char
render_char:
  push {r3-r8}

  ldr r3, =font8x8
  ldr r4, [r3, r2]       // r4 = font8x8[r2] (first 4 bytes)
  //ldr r5, [r3, r2, #4]   // r5 = font8x8[r2] (last 4 bytes)
  // FIXME: Norbert I have no idea what you meant here

  mov r7, #0             // current_y = 0
  1: 
    cmp r7, #4               // if (current_y >= 4)
    movge r4, r5             //   r4 = r5 (use last 4 bytes)
    mov r6, #0x80            // mask = 1000 0000
    mov r8, #0               // current_x = 0
    2: 
      tst r4, r6             // r4 & mask (test the current bit)
      mov r3, #0xFFFFFF00    // if bit was set, set color to white
      moveq r3, #0x00000000  // if bit was not set, set color to black
      add r0, r0, r8         // drawn_x = x + current_x
      add r1, r1, r7         // drawn_y = y + current_y
      put_pixel              // draw pixel r3 at (r0, r1)
      lsr r6, #1             // shift mask 1 bit to the right
      add r8, r8, #1         // current_x++
      cmp r8, #8             // while current_x < 8
      blt 2b

    add r7, r7, #1           // current_y++
    cmp r7, #8               // while current_y < 8
    blt 1b

  pop {r3-r8}  
  mov pc, lr
