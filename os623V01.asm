; OS623 Master Boot Record Sector version 0.1
; Bootable MBR: Display logo, wait for key press, show message, halt
; Assemble with: nasm -f bin -o os623V01.bin os623V01.asm

bits 16
org 0x7c00

jmp start
nop

bsOEM db "OS623 v.0.1" ; OEM String

start:
    ; Clear screen with green background
    call clear_screen

    ; Draw bordered logo at row 8, centered at column 25
    mov dh, 8
    mov dl, 25
    call set_cursor_position
    call draw_bordered_logo

    mov dh, 18
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

clear_screen:
    ; Clears the screen with a specified background color (BH)
    mov bh, 0x0F       ; White on black
    mov ah, 06h        ; Scroll screen function
    xor al, al         ; Clear all lines
    xor cx, cx         ; Top-left corner (row 0, col 0)
    mov dx, 0x184F     ; Bottom-right corner (row 24, col 79)
    int 10h
    ret

draw_bordered_logo:
    ; Draw top border
    call draw_horizontal_border
    
    ; Ensure the cursor starts at row 9 after the border
    mov dh, 9
    mov dl, 25
    call set_cursor_position
    lea si, text_lines
    call print_lines              ; Print the text lines with side borders
    ; Draw bottom border
    call draw_horizontal_border
    ret

draw_horizontal_border:
    ; Draws a horizontal border at the current row (DH)
    mov ah, 09h                   ; Write character/attribute
    mov al, 205                   ; ASCII '═'
    mov bh, 0                     ; Video page 0
    mov bl, 0x09                  ; Purple on black
    mov dl, 25                    ; Starting column
    mov cx, 30                    ; Number of characters
    int 10h
    ret

print_lines:
.next_line:
    ; Print left border
    call print_border

    ; Get the first byte of the line (color) from [si]
    lodsb               ; Load the first byte (color) into AL
    mov bl, al          ; Store it in bl to set the color for this line

    ; Save SI before printing the line content
    push si
    call print_string
    pop si

    ; Print right border
    call print_border

    ; Advance to the next line
    inc dh
    mov dl, 25
    call set_cursor_position

    ; Move SI to the start of the next line
    lodsb               ; Load next byte
    cmp al, 0           ; Check for null terminator
    jne .skip_to_next_line ; Skip until null is found
    cmp byte [si], 0    ; Check for double null (end of all lines)
    je .done

    ; Reset to next line
    jmp .next_line

.skip_to_next_line:
    lodsb               ; Load next byte
    cmp al, 0           ; Check for null terminator
    jne .skip_to_next_line ; Skip until null is found
    cmp byte [si], 0    ; Check for double null (end of all lines)
    je .done
    jmp .next_line

.done:
    ret

print_border:
    mov bl, 0x09
    mov al, 186         ; ASCII '║'
    call print_char
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
msg db 'AG, OS by Ashlee Gerard, version 0.1 (C) 2025',0 
dollar_sign db '$',0
press_any_key db "Press any key to continue...",0

mlen equ $-msg

text_lines:
db 0x04,"                _____       ",0
db 0x0C,"          /\   / ____|      ",0
db 0x0E,"         /  \ | |  __       ",0
db 0x02,"        / /\ \| | |_ |      ",0
db 0x01,"       / ____ \ |__| |      ",0
db 0x09,"      /_/    \_\_____|      ",0
db 0x05,"                            ",0
db 0 ; Double null terminator

padding times 510 - ($ - $$) db 0 ; Align to 510 bytes
bootSig dw 0xAA55 ; Boot signature