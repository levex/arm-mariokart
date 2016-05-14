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
}
