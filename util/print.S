
/* Prints a matrix over UART. Arguments:
 * r0 - pointer to matrix
 */
.globl print_matrix
print_matrix:
	push {lr}
	push {r1-r4}

	ldr r1, [r0]     ; rows
	ldr r2, [r0, #4] ; columns
	
	mov r3, #0
	for_row:
		cmp r3, r1
		bge endfor_row

		mov r4, #0
		for_column:
			cmp r4, r2
			bge endfor_column

			mul r5, r2, r3       ; r5 = columns * row   
			add r5, r5, r4       ; r5 = columns * row + column

			push {r0}
			ldr r0, [r0, r5]     ; matrix element
            b uart_send_int_dec
            pop {r0}

            add r4, r4, #1
            b for_column
        endfor_column:
        b uart_send_newline
        add r3, r3, #1
        b for_row

    endfor_row:
    
	pop {r1-r4}
	pop {lr}
	bx lr
