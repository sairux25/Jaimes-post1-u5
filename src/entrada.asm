; src/entrada.asm - Programa 2, lee un caracter del teclado y muestra su eco
; Ensamble con nasm -f bin entrada.asm -o ../bin/entrada.com

org 0x100

section .data
    prompt  db "Ingrese una letra (se mostrara su codigo ASCII): $"
    msg_ok  db 0Dh, 0Ah, "Caracter recibido: $"
    msg_cod db 0Dh, 0Ah, "Codigo ASCII (hex): $"
    nl      db 0Dh, 0Ah, "$"

section .text
    ; Se muestra el mensaje que pide la letra
    mov ah, 09h
    mov dx, prompt
    int 21h

    ; Se lee un caracter sin que DOS lo muestre automaticamente
    mov ah, 07h            ; funcion 07h lee un caracter sin eco
    int 21h                ; AL queda con el codigo ASCII leido
    mov bl, al             ; se guarda el caracter en BL

    ; Se muestra el caracter leido
    mov ah, 09h
    mov dx, msg_ok
    int 21h
    mov ah, 02h            ; funcion 02h muestra el caracter que esta en DL
    mov dl, bl
    int 21h

    ; Se muestra el codigo ASCII en hexadecimal
    mov ah, 09h
    mov dx, msg_cod
    int 21h

    ; Se separan los nibbles alto y bajo del codigo ASCII
    mov al, bl
    shr al, 4              ; el nibble alto queda en AL
    call print_hex_nibble
    mov al, bl
    and al, 0Fh            ; el nibble bajo queda en AL
    call print_hex_nibble

    ; Salto de linea y fin del programa
    mov ah, 09h
    mov dx, nl
    int 21h
    mov ax, 4C00h
    int 21h

; Subrutina que imprime el nibble de AL como un digito hexadecimal
print_hex_nibble:
    cmp al, 9
    jle .digito
    add al, 7              ; para A a F se suma 7 y asi llegar a la letra 41h
.digito:
    add al, 30h            ; se convierte a ASCII, 0 es 30h y A es 41h
    mov ah, 02h
    mov dl, al
    int 21h
    ret
