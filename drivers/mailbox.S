.section ".text"

// Mailbox driver
// Spec (unofficial): http://elinux.org/RPi_Framebuffer
// Registers:
.equ MAIL0_READ       , 0x00
.equ MAIL0_PEAK       , 0x10
.equ MAIL0_SENDER     , 0x14
.equ MAIL0_STATUS     , 0x18
.equ MAIL0_CONFIG     , 0x1C
.equ MAIL0_WRITE      , 0x20
// Base address
.equ MAIL0_ADDR       , 0x2000B880
// MAIL_STATUS:
.equ MAIL_STATUS_EMPTY , (1 << 30)
.equ MAIL_STATUS_FULL  , (1 << 31)

/*
 * mail_read_status - read STATUS register into r0
 */
.globl mail_read_status
mail_read_status:
    push {r1, lr}

    bl memory_barrier

    ldr r1, =MAIL0_ADDR
    ldr r0, [r1, #MAIL0_STATUS]

    pop {r1, pc}

.globl mail_wait_till_ready_send
mail_wait_till_ready_send:
    push {r0, lr}

    1: bl mail_read_status
       tst r0, #MAIL_STATUS_FULL
       bne 1b

    pop {r0, pc}

/*
 * mail_write_mailbox - Writes r1 to the mailbox
 */
.globl mail_write_mailbox
 mail_write_mailbox:
    push {r0, lr}

    bl mail_wait_till_ready_send
    ldr r0, =MAIL0_ADDR
    str r1, [r0, #MAIL0_WRITE]

    pop {r0, pc}

.globl mail_wait_till_ready_receive
mail_wait_till_ready_receive:
    push {r0, lr}

    1: bl mail_read_status
       tst r0, #MAIL_STATUS_EMPTY
       bne 1b

    pop {r0, pc}

/*
 * mail_read_mailbox - Reads the pointer into r0
 */
.globl mail_read_mailbox
mail_read_mailbox:
    push {r1, lr}

    1: bl mail_wait_till_ready_receive
       ldr r0, =MAIL0_ADDR
       ldr r0, [r0, #MAIL0_READ]
       mov r1, r0

       /* check channel, i.e. #1 */
       and r1, r1, #0x0000000f
       cmp r1, #1 /* we are only interested in the framebuffer */
       bne 1b /* if wrong channel, wait till we get a good one */

    /* otherwise, we got our reply, LSR 4 to get full data */
    lsr r0, r0, #4

    pop {r1, pc}

/*
 * mailbox_send_tag
 */

.equ MBP_SET_VIRTUAL_OFFSET_TAG, 0x00048009

/* mbp_set_request - set tag to request mode */
.globl mbp_set_request
mbp_set_request:
  ldr r0, =mbtb_rcde
  mov r1, #0
  str r1, [r0]
  mov pc, lr

/* mbp_set_tag_id - sets the tag id to r1 */
.globl mbp_set_tag_id
mbp_set_tag_id:
  ldr r0, =mbtb_t_id
  str r1, [r0]
  mov pc, lr

/* sets the y_offset to r0 */
.globl mbp_set_virtual_offset_y
mbp_set_virtual_offset_y:
  ldr r1, =mailbox_tag_buffer
  str r0, [r1, #24] /* store y_offset */

  mov r0, #8*4
  str r0, [r1, #0] /* store size */

  mov r0, #0
  str r0, [r1, #4] /* store request code */
  str r0, [r1, #20] /* store X */
  str r0, [r1, #28] /* store end */

  ldr r0, =MBP_SET_VIRTUAL_OFFSET_TAG
  str r0, [r1, #8] /* store tag id */

  mov r0, #8
  str r0, [r1, #12] /* store value size */
  str r0, [r1, #16] /* store value length */

  mov pc, lr

/* sends the buffer to the mailbox */
.globl mbp_send_buffer
mbp_send_buffer:
  ldr r1, =mailbox_tag_buffer
  b mail_write_mailbox
  /* lr is not modified, hence no need to save it */

.balign 32
mailbox_tag_buffer:
  /* 0 */  mbtb_size: .word 8*4
  /* 4 */  mbtb_rcde: .word 0 /* 0x00 */
  /* 8 */  mbtb_t_id: .word 0
  /* 12 */ mbtb_t_vs: .word 0 /* value size */
  /* 16 */  mbtb_t_vl: .word 0 /* value length */
  /* 20 */  mbtb_t_vx: .word 0 /* X */
  /* 24 */  mbtb_t_vy: .word 0 /* Y */
  /* 28 */  mbtb_t_en: .word 0 /* end tag */
