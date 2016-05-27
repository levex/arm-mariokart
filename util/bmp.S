.section ".text"

/* bmp.S
 * 
 * displays a BMP file on the screen
 *
 */


// Return the start of pixel data in r0
// Takes the bmp in r0
.globl bmp_get_pixel_data_start
bmp_get_pixel_data_start:
    ldr r0, [r0, #0x0A]
    mov pc, lr

// Return the size of DiB header in r0
// Takes the bmp in r0
.globl bmp_get_size_of_dib_header
bmp_get_size_of_dib_header:
    ldr r0, [r0, #0x0E]
    mov pc, lr

// Checks if the bmp's size is 40, which is the header we support
.globl bmp_check_correct_header
bmp_check_correct_header:
   push {lr}
   bl bmp_get_size_of_dib_header
   cmp r0, #108
   movne r0, #0
   moveq r0, #1
   pop {pc}

// returns the width of the bmp file
.globl bmp_get_width
bmp_get_width:
   ldr r0, [r0, #0x12]
   mov pc, lr

// returns the height of the bmp file
.globl bmp_get_height
bmp_get_height:
   ldr r0, [r0, #0x16]
   mov pc, lr

// r0 == BMP data
// r2 == COLOR     both in and out
.globl bmp_index_color_palette
bmp_index_color_palette:
   add r0, r0, #14 // advance through BITMAPFILEHEADER
   add r0, r0, #108 // advance through DiB header
   lsl r2, #2
  // bl uart_send_int_hex
  // bl uart_send_newline
  // push {r0}
  //   mov r0, r2
  //   bl uart_send_int_hex
  //   bl uart_send_newline
  // pop {r0}
  // push {r0}
  //   add r0, r0, r2
  //   bl uart_send_int_hex
  //   bl uart_send_newline
  // pop {r0}
   ldr r2, [r0, r2] // load color
   mov pc, lr


// draws a BMP file at (0,0)
.globl bmp_draw
bmp_draw:
   push {lr}
   mov r1, r0 // save bmp ptr in r1
   bl bmp_check_correct_header // check if we can process this header
   cmp r0, #0 // @TODO: optimize, likely comparing with 0 is useless
   beq 1f // failed

   mov r0, r1
   bl bmp_get_width
   mov r2, r0  // store width as r2
   bl uart_send_int_dec
   bl uart_send_newline

   mov r0, r1
   bl bmp_get_height
   mov r3, r0  // store height as r3
   bl uart_send_int_dec
   bl uart_send_newline

   mov r4, #0  // r4 = x
   mov r5, #0  // r5 = y
   mov r0, r1 
   bl bmp_get_pixel_data_start
   mov r7, r0 // r7 = base of pixel data
   add r7, r7, r1 // make offset absolute
3:
   mul r6, r5, r2 // r6 = y * width
   add r6, r6, r4 // r6 = y * width + x
   ldr r8, [r7, r6] // r8 = data[(y * width + x) * 4]
   and r8, r8, #0x000000FF
   mov r9, r2    // r9 = r2 = width
   mov r2, r8   // r2 = data[y * width + x]
   mov r0, r1 // set bmp
   bl bmp_index_color_palette
   push {r0, r1}
     mov r0, r4   // r0 = x
     mov r1, r5   // r1 = y
     // r2 = real color
     bl fb_put_pixel // put pixel
   pop {r0, r1}
   mov r2, r9  // r2 = r9 = width
   add r4, r4, #1 // x = x + 1
   cmp r4, r2     // if x == width
     movgt r4, #0   //    x = 0
     addgt r5, r5, #1 //  y += 1
   cmp r5, r3     // if y == height
     bne 3b         //    get out

   b 2f // correct header
1:
   ldr r0, =failed_bmp_drawing
   bl uart_send_string
2:
   pop {lr}
   mov pc, lr

failed_bmp_drawing: .asciz "BMP failed to draw\n"
