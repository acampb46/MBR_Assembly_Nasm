bits 16
org 0x2345       ; Start of the second sector

push cs          ; Save the current code segment
pop ds           ; Set ds to the current segment where data resides

    ; Draw Computer Monitor
    mov dh, 6
    mov dl, 25
    call set_cursor_position
    call draw_computer

    ; Draw OS logo in computer screen
    mov dh, 8
    mov dl, 30
    call set_cursor_position
    lea si, text_lines
    call print_lines

    call load_date

    ret

;;Methods

draw_computer:
    mov dh, 7
    mov dl, 25
    call set_cursor_position
    lea si, computer_lines
    call print_lines              ; Print the text lines
    ret

print_lines:
    push dx               ; Save DX (cursor position)
.next_line:
    lodsb                 ; Load the first byte (color) into AL
    mov bl, al            ; Store it in BL (text color)

    ; Check if this is text_lines or computer_lines
    cmp si, text_lines    ; Compare SI with the address of text_lines
    jb .use_col25         ; If before text_lines, use column 25
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

        ;;;load 3rd sector and run
load_date:
    mov bx, 0x0002          ;es:bx input buffer, temporary set 0x0002:3456
    mov es, bx
    mov bx, 0x3456
    mov ah, 02h             ;Function 02h (read sector)
    mov al, 1               ;Read one sector
    mov ch, 1               ;Cylinder#
    mov cl, 5               ;Sector# --> 2 has program
    mov dh, 0               ;Head# --> logical sector 1
    mov dl, 0               ;Drive# A, 08h=C
    int 13h
    jmp word 0x0002:0x3456  ;Run program on sector 3, ex:bx
    int 20h
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
