; src/saludo.asm - Programa 1, salida de texto en DOS
; Ensamble con nasm -f bin saludo.asm -o ../bin/saludo.com

org 0x100              ; los programas .COM inician en CS:0100h

section .data
    nombre db "Laboratorio 5 - DOSBox y Ensamblador", 0Dh, 0Ah
           db "Estudiante: Sara Jaimes", 0Dh, 0Ah
           db "Unidad 5 - Arquitectura de Computadores", 0Dh, 0Ah, "$"

section .text
    ; Se muestra el mensaje con la funcion 09h de INT 21h
    mov ah, 09h        ; funcion que imprime una cadena terminada en $
    mov dx, nombre     ; DX guarda la direccion donde inicia la cadena
    int 21h            ; llamada al sistema operativo DOS

    ; Se termina el programa y se devuelve el control a DOS
    mov ax, 4C00h      ; funcion 4Ch con codigo de salida 00h en AL
    int 21h
