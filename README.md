# Laboratorio Unidad 5 — Emuladores y Virtualización
Estudiante Sara Jaimes. Arquitectura de Computadores, Unidad 5.

Este repositorio contiene el desarrollo de las dos partes del laboratorio de emulación y virtualización. En la Parte 1 se configura DOSBox como entorno de desarrollo en ensamblador x86 de 16 bits, se escriben y ensamblan programas con NASM, se verifican con el depurador DEBUG y se mide el efecto del parámetro cycles sobre la velocidad de emulación. En la Parte 2 se crea una máquina virtual con Alpine Linux en VirtualBox, se configuran sus modos de red, se gestionan snapshots, se reasignan sus recursos, se compara un disco fijo frente a uno dinámico y se exporta en formato OVA.

Entorno utilizado

Sistema anfitrión Windows 11 Pro. Emulador DOSBox-X 2026.08.31. Ensamblador NASM para DOS versión 3.00.

# PARTE 1 — DOSBox y ensamblador

## Checkpoint 1 — Estructura del directorio
Captura: capturas/p1_cp1_estructura.png

El directorio de trabajo se organizó en tres carpetas. En src se guardan los archivos fuente .asm, en bin los ejecutables .com que produce NASM y en capturas la evidencia de cada checkpoint. El repositorio se inicializó con Git sobre la rama main.

## Checkpoint 2 — DOSBox operativo con NASM
Captura: capturas/p1_cp2_dosbox_nasm.png

DOSBox se inicia con el archivo dosbox.conf del repositorio y al abrir aparece directamente el prompt C:\> porque la carpeta del proyecto se monta como unidad C. El comando nasm -v muestra la versión 3.00 del ensamblador sin errores.

## Checkpoint 3 — Programa saludo.com
Captura: capturas/p1_cp3_saludo.png

El programa saludo.asm usa la función 09h de la interrupción 21h, que imprime en pantalla una cadena terminada en el carácter $. Se ensambló desde la carpeta src y NASM generó bin/saludo.com sin mensajes de error. Al ejecutarlo se muestran las tres líneas con los datos del laboratorio y de la estudiante.

## Checkpoint 4 — Programa entrada.com
Captura: capturas/p1_cp4_entrada.png

El programa entrada.asm muestra un mensaje, lee una tecla con la función 07h de la interrupción 21h y después muestra el carácter con la función 02h. Para el código ASCII separa el byte en dos nibbles y cada uno se convierte en un dígito hexadecimal con una subrutina. En la prueba se presionó la letra J y el programa mostró el código 4A, que es el valor ASCII de esa letra.
