;; display 2nd message from sector 50
org 0x7c00
jmp short start
nop
bsOEM	db "OS623 v.0.2"               ; OEM String

start:
	; Clear screen with green background
    call clear_screen

    ; Load second sector to draw logo
    call load

    ; Print "Press any key to continue" message
    mov bl, 0x09
    mov dh, 3
    mov dl, 25
    call set_cursor_position
    lea si, press_any_key
    call print_string

    ; Wait for key press
    xor ah, ah
    int 16h

    ; Clear screen again
    call clear_screen

    ; Display message at row 0, column 0
    mov dh, 0
    mov dl, 0
    call set_cursor_position
    lea si, msg
    call print_string

    ; Print $ on the next line (row 1, column 0)
    mov dh, 1            ; Row 1
    mov dl, 0            ; Column 0
    call set_cursor_position
    lea si, dollar_sign
    call print_string

    ; Halt execution
    cli
    hlt

;; Methods    
	
clear_screen:
    ; Clears the screen with a specified background color (BH)
    mov bh, 0x0F       ; White on black
    mov ah, 06h        ; Scroll screen function
    xor al, al         ; Clear all lines
    xor cx, cx         ; Top-left corner (row 0, col 0)
    mov dx, 0x184F     ; Bottom-right corner (row 24, col 79)
    int 10h
    ret

print_string:
    ; Prints a null-terminated string at (DH, DL)
.next_char:
    lodsb              ; Load a byte from [SI] into AL
    cmp al, 0          ; Check if it's the null terminator
    je .done
    call print_char
    jmp .next_char
.done:
    ret

print_char:
    ; Prints a single character at (DH, DL)
    mov ah, 09h        ; Write character/attribute
    mov cx, 1          ; Single character
    int 10h
    inc dl             ; Move to the next column
    call set_cursor_position
    ret

set_cursor_position:
    ; Sets cursor position (DH = row, DL = column)
    xor bh, bh
    mov ah, 02h
    int 10h
    ret

; Data section
press_any_key db "Press any key to continue...",0
msg db 'AG, OS by Ashlee Gerard, version 0.2 (C) 2025',0 
dollar_sign db '$',0

mlen equ $-msg

;;;load 2nd sector and run logical 50 == C1:H0:H15
load:
	mov bx, 0x0000			;es:bx input buffer, temporary set 0x0000:1234
	mov es, bx
	mov bx, 0x1234
	mov ah, 02h				;Function 02h (read sector)
	mov al, 1				;Read one sector
	mov ch, 1				;Cylinder#
	mov cl, 15				;Sector#
	mov dh, 0				;Head#  
	mov dl, 0				;Drive# A, 08h=C
	int 13h

	jmp word 0x0000:0x1234	;Run program on sector 1, ex:bx

	int 20h

	ret

padding	times 510-($-$$) db 0		;to make MBR 512 bytes
bootSig	db 0x55, 0xaa		;signature (optional)

