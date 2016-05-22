.section ".text"

// Framebuffer driver
// Requests a framebuffer address using the mailbox

gpu_framebuffer_struct:
    .word 640  /* width */
    .word 480  /* height */
    .word 480  /* virtual (???) width */
    .word 640  /* virtual (???) height */
    .word 000  /* pitch, not entirely sure what this is */
    .word 024  /* depth */
    .word 000  /* x_offset */
    .word 000  /* y_offset */
    .word 000  /* pointer to framebuffer, set by GPU */
    .word 000  /* size of framebuffer, set by GPU */
