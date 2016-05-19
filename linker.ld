ENTRY(_start)

SECTIONS
{
	/* raspi loads us to 0x8000 */
        . = 0x8000;
	.text :
	{
		KEEP(*(.text.boot))
		*(.text)
	}
	. = ALIGN(4096);
	.rodata :
	{
		KEEP(*(.rodata))
	}
	. = ALIGN(4096);
	.data :
	{
		KEEP(*(.data))
	}
	. = ALIGN(4096);
	.bss :
	{
		KEEP(*(.bss))
	}
}
