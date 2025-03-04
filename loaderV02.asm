org 0x1234

	; Draw Computer Monitor
    mov dh, 6
    mov dl, 25
    call set_cursor_position
    call draw_computer

    ; Draw Tabletop
    mov dh, 16
    mov dl, 23
    call set_cursor_position
    call draw_horizontal_border

    ; Draw OS logo in computer screen
    mov dh, 8
    mov dl, 30
    call set_cursor_position
    lea si, text_lines
    call print_lines
    ret

;;Methods

draw_computer:
    mov dh, 7
    mov dl, 25
    call set_cursor_position
    lea si, computer_lines
    call print_lines              ; Print the text lines
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
    push dx               ; Save DX (cursor position)
.next_line:
    lodsb                 ; Load the first byte (color) into AL
    mov bl, al            ; Store it in BL (text color)

    ; Check if this is `text_lines` or `computer_lines`
    cmp si, text_lines    ; Compare SI with the address of `text_lines`
    jb .use_col25         ; If before `text_lines`, use column 25
    mov dl, 30           ; Otherwise, set column 30 for text_lines
    jmp .set_position

.use_col25:
    mov dl, 25           ; Set column 25 for computer_lines

.set_position:
    call set_cursor_position

    ; Save SI before printing the line content
    push si
    call print_string
    pop si

    ; Advance to the next line
    inc dh
    call set_cursor_position

    ; Move SI to the start of the next line
    lodsb                 ; Load next byte
    cmp al, 0             ; Check for null terminator
    jne .skip_to_next_line ; If not null, continue skipping
    cmp byte [si], 0      ; Check for double null (end of all lines)
    je .done              ; If so, exit

    jmp .next_line

.skip_to_next_line:
    lodsb                 ; Load next byte
    cmp al, 0             ; Check for null terminator
    jne .skip_to_next_line ; Keep skipping
    cmp byte [si], 0      ; Check for double null (end)
    je .done
    jmp .next_line

.done:
    pop dx                ; Restore DX (cursor position)
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

computer_lines:
db 0x0F,222, 178, 219, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 223, 219, 178, 221, 0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221, 0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221, 0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221,  0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221, 0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221,0
db 0x0F,222, 178, 219, "                    ", 219, 178, 221,  0
db 0x0F,222, 178, 219, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220, 220,220, 220, 220, 220, 220, 220, 220, 220, 219, 178, 221, 0
db 0x0F,"       ", 220, 220, 219, 219, 219, 219, 219, 219, 219, 219, 220, 220, "       ",  0
db 0  ; Double null terminator for end of ASCII art

text_lines:
db 0x04,"          _____ ",0
db 0x0C,"    /\   / ____|",0
db 0x0D,"   /  \ | |  __ ",0
db 0x0E,"  / /\ \| | |_ |",0
db 0x0A," / ____ \ |__| |",0
db 0x0B,"/_/    \_\_____|",0
db 0 ; Double null terminator