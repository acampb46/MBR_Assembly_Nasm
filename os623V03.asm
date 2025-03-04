org 0x7c00
jmp short start
nop
bsOEM   db "OS623 v.0.3"               ; OEM String

start:
    ; Clear screen with green background
    call clear_screen

    ; Print "Press any key to continue" message
    mov bl, 0x09
    mov dh, 3
    mov dl, 25
    call set_cursor_position
    lea si, press_any_key
    call print_string

    ; Load second sector to draw logo
    call load_logo
    
    pop ds

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

;times 0x125 - ($ - $$) db 0

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

;;;load 2nd sector and run
load_logo:
    mov bx, 0x0001          ;es:bx input buffer, temporary set 0x0001:2345
    mov es, bx
    mov bx, 0x2345
    mov ah, 02h             ;Function 02h (read sector)
    mov al, 1               ;Read one sector
    mov ch, 1               ;Cylinder#
    mov cl, 2               ;Sector# --> 2 has program
    mov dh, 0               ;Head# --> logical sector 1
    mov dl, 0               ;Drive# A, 08h=C
    int 13h
    jmp word 0x0001:0x2345  ;Run program on sector 1, ex:bx
    int 20h
    ret



; Data section
press_any_key db "Press any key to continue...",0
msg db 'AG, OS by Ashlee Gerard, version 0.3 (C) 2025',0 
dollar_sign db '$',0

padding times 510-($-$$) db 0       ;to make MBR 512 bytes
bootSig db 0x55, 0xaa       ;signature (optional)