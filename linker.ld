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
		*(.rodata)
	}
	. = ALIGN(4096);
	.data :
	{
		*(.data)
	}
	. = ALIGN(4096);
	.bss :
	{
		*(.bss)
	}
}
