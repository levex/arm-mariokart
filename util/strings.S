/*.section ".data"

.balign 4

.balign 16
.globl hello
hello: .asciz "Hello, Lev!\n"

.balign 16
.globl framebuffer_acquired_str
framebuffer_acquired_str: .asciz "\nFramebuffer acquired!\n"

.balign 16
.globl alphabet
alphabet: .asciz "\nThe brown fox jumped over the lazy dog. ! ? : <3\n"

.balign 4
*/
