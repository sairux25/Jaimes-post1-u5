; src/ciclos.asm - Programa 3, mide el tiempo real de un bucle de trabajo fijo
; Ensamble con nasm -f bin ciclos.asm -o ../bin/ciclos.com

org 0x100

section .data
    msg_inicio db "Midiendo bucle de trabajo fijo...", 0Dh, 0Ah, "$"
    msg_t1     db "Hora inicial (hh:mm:ss:cc): $"
    msg_t2     db 0Dh, 0Ah, "Hora final (hh:mm:ss:cc): $"
    msg_fin    db 0Dh, 0Ah, "Medicion completa. Compare el campo cc (centesimas).", 0Dh, 0Ah, "$"
    sep        db ":$"

    hora1 db 0
    min1  db 0
    seg1  db 0
    cc1   db 0

    hora2 db 0
    min2  db 0
    seg2  db 0
    cc2   db 0

section .text
    mov ah, 09h
    mov dx, msg_inicio
    int 21h

    ; Se lee la hora inicial con la funcion 2Ch de INT 21h
    ; CH queda con las horas, CL con los minutos, DH con los segundos y DL con las centesimas
    mov ah, 2Ch
    int 21h
    mov [hora1], ch
    mov [min1], cl
    mov [seg1], dh
    mov [cc1], dl

    ; Bucle de trabajo con un numero fijo de iteraciones
    ; Su duracion real depende del valor cycles de dosbox.conf y no del codigo
    mov cx, 2000           ; vueltas del bucle externo
trabajo_ext:
    push cx
    mov cx, 0FFFFh         ; el bucle interno da unas 65535 vueltas
trabajo_int:
    inc ax                 ; operacion sencilla que solo sirve para gastar tiempo
    loop trabajo_int
    pop cx
    loop trabajo_ext

    ; Se lee la hora final
    mov ah, 2Ch
    int 21h
    mov [hora2], ch
    mov [min2], cl
    mov [seg2], dh
    mov [cc2], dl

    ; Se imprime la hora inicial
    mov ah, 09h
    mov dx, msg_t1
    int 21h
    mov al, [hora1]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [min1]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [seg1]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [cc1]
    call print_dec2

    ; Se imprime la hora final
    mov ah, 09h
    mov dx, msg_t2
    int 21h
    mov al, [hora2]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [min2]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [seg2]
    call print_dec2
    mov ah, 09h
    mov dx, sep
    int 21h
    mov al, [cc2]
    call print_dec2

    mov ah, 09h
    mov dx, msg_fin
    int 21h

    mov ax, 4C00h
    int 21h

; Subrutina que imprime AL (de 0 a 99) como dos digitos decimales usando AAM
print_dec2:
    aam                    ; AH queda con la decena y AL con la unidad
    xchg ah, al            ; ahora AL tiene la decena y AH la unidad
    push ax
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    mov al, ah
    add al, 30h
    mov dl, al
    mov ah, 02h
    int 21h
    ret
