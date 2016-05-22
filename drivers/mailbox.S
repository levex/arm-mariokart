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
.equ MAIL_STATUS_FULL  , (1 << 31)
.equ MAIL_STATUS_EMPTY , (1 << 30)

/*
 * mail_read_status - read STATUS register into r0
 */
.globl mail_read_status
mail_read_status:
    ldr r0, =(MAIL0_ADDR + MAIL0_STATUS)
    ldr r0, [r0]
    mov pc, lr

.globl mail_wait_till_ready_send
mail_wait_till_ready_send:
    push {r0, lr}

    1: bl mail_read_status
    tst r0, #MAIL_STATUS_FULL
    beq 1b

    pop {r0, lr}
    mov pc, lr

/*
 * mail_write_mailbox - Writes r1 to the mailbox
 */
.globl mail_write_mailbox
 mail_write_mailbox:
    push {r0, lr}

    bl mail_wait_till_ready_send
    ldr r0, =(MAIL0_ADDR + MAIL0_WRITE)
    str r1, [r0]

    pop {r0, lr}
    mov pc, lr
