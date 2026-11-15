# Laboratorio Unidad 5 — Emuladores y Virtualización
Estudiante Sara Jaimes. Arquitectura de Computadores, Unidad 5.

Este repositorio contiene el desarrollo de las dos partes del laboratorio de emulación y virtualización. En la Parte 1 se configura DOSBox como entorno de desarrollo en ensamblador x86 de 16 bits, se escriben y ensamblan programas con NASM, se verifican con el depurador DEBUG y se mide el efecto del parámetro cycles sobre la velocidad de emulación. En la Parte 2 se crea una máquina virtual con Alpine Linux en VirtualBox, se configuran sus modos de red, se gestionan snapshots, se reasignan sus recursos, se compara un disco fijo frente a uno dinámico y se exporta en formato OVA.

Entorno utilizado

Sistema anfitrión Windows 11 Pro. Emulador DOSBox-X 2026.08.31. Ensamblador NASM para DOS versión 3.00.

Virtualizador VirtualBox 7.2.22. Máquina virtual Lab5-Alpine con Alpine Linux 3.19 edición Standard, 1024 MB de RAM, 1 CPU y disco VDI dinámico de 10 GB.

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

## Checkpoint 5 — Depuración con DEBUG
Capturas: capturas/p1_cp5_debug_1.png a p1_cp5_debug_3.png. 

Al cargar saludo.com en DEBUG el comando r muestra IP en 0100, que es donde empiezan los programas .COM, y CX en 0075, que corresponde a los 117 bytes del archivo. El comando u 100 10F muestra las cinco instrucciones del programa y desde 010C aparecen instrucciones sin sentido porque ahí ya empieza el texto del mensaje.

| Instrucción ejecutada con t | AX | DX | IP siguiente |
|---|---|---|---|
| Estado inicial | 0000 | 0000 | 0100 |
| MOV AH,09 | 0900 | 0000 | 0102 |
| MOV DX,010C | 0900 | 010C | 0105 |
| INT 21 | 0924 | 010C | 0107 |

Con el primer t solo cambia la parte alta de AX, y con el segundo DX queda apuntando a 010C, la dirección del mensaje. En el tercer t se ejecuta INT 21 y el mensaje aparece en pantalla. Después AX queda en 0924 porque DOS deja en AL el valor 24, que es el código del carácter $. Las banderas no cambiaron en ningún paso porque estas instrucciones no hacen operaciones aritméticas. Por último g ejecutó el resto del programa, que terminó normalmente con código 0000, y q cerró DEBUG.

## Checkpoint 6 — Programa ciclos.com
Captura: capturas/p1_cp6_ciclos_8000.png

El programa ciclos.asm lee la hora del sistema con la función 2Ch de la interrupción 21h antes y después de un bucle que siempre da el mismo número de vueltas, 2000 del bucle externo por 65535 del interno. Con cycles en 8000 la hora inicial fue 09:46:42:51 y la final 09:47:15:41, así que el bucle tardó 32,90 segundos, es decir 3290 centésimas.

## Checkpoint 7 — Comparación de cycles
Capturas: capturas/p1_cp6_ciclos_8000.png, capturas/p1_cp7_ciclos_1000.png y capturas/p1_cp7_ciclos_20000.png

Se ejecutó ciclos.com tres veces cambiando solo el valor de cycles en dosbox.conf y reiniciando DOSBox-X entre cada corrida. El programa fue el mismo en las tres, con el mismo número de vueltas del bucle.

| Corrida | Cycles | Hora inicial | Hora final | Duración observada (centésimas) |
|---|---|---|---|---|
| 1 | 8000 | 09:46:42:51 | 09:47:15:41 | 3290 |
| 2 | 1000 | 09:51:46:96 | 09:56:17:08 | 27012 |
| 3 | 20000 | 09:57:00:91 | 09:57:14:04 | 1313 |

Con cycles en 1000 el bucle tardó más de cuatro minutos y con 20000 apenas trece segundos. Las tres corridas mostraron la misma salida y solo cambió el tiempo, lo que confirma que cycles controla la velocidad de la emulación y no el resultado del programa. Al terminar las pruebas el archivo dosbox.conf quedó otra vez con cycles en 8000.

## Decisión Técnica — Valor de cycles para el laboratorio
Para este laboratorio el valor correcto es un número fijo de cycles, en este caso 8000. Con cycles=max DOSBox-X emula tantas instrucciones por segundo como permita el procesador del equipo anfitrión, que hoy es muchísimo más rápido que un PC de la época. Así ciclos.com terminaría casi al instante sin importar las 2000 por 65535 vueltas del código, y la diferencia entre la hora inicial y la final sería de muy pocas centésimas o incluso cero. La medición perdería sentido porque el tiempo ya no dependería del hardware de referencia que se quiere emular sino de la potencia de cada computador. Con cycles=auto pasa algo parecido, porque DOSBox-X cambia el valor según la carga del programa y dos corridas en el mismo equipo pueden dar tiempos distintos.

Un valor fijo como 8000 hace que todos los estudiantes ejecuten el mismo número de instrucciones emuladas por milisegundo. Mientras el equipo alcance a sostener ese ritmo, ciclos.com tarda prácticamente lo mismo en cualquier computador, como los 32,90 segundos medidos en la corrida 1, y los resultados de distintos estudiantes se pueden comparar. Por eso se dejó 8000 en dosbox.conf desde el Paso 2.

Fuera de este laboratorio cycles=max o cycles=auto sí son la opción correcta cuando importa que el programa responda rápido y no su temporización. Por ejemplo al usar un editor, un compilador o una hoja de cálculo para DOS, o al ensamblar programas grandes con NASM, conviene aprovechar toda la velocidad del anfitrión, ya que estos programas no usan la velocidad del procesador para medir el tiempo como sí lo hacían muchos juegos de la época.

## Decisión Técnica — Cycles frente a los ciclos reales del procesador
Comparar el valor 8000 de cycles con los GHz del procesador anfitrión sería un error de categoría porque miden cosas distintas. Cycles cuenta cuántas instrucciones x86 de 16 bits emula DOSBox-X en cada milisegundo de tiempo virtual, y de hecho la barra de título muestra 8000 cycles/ms. Los GHz del anfitrión cuentan ciclos de reloj físicos del silicio, que son miles de millones por segundo. Una instrucción emulada no equivale a un ciclo real.

Para emular cada instrucción, DOSBox-X tiene que leerla, decodificarla y reproducir su efecto por software, y eso le cuesta al anfitrión un número variable de instrucciones nativas y de ciclos reales. Por eso el procesador real gasta muchos más ciclos de los que sugiere cycles. Esto implica que cycles no dice cuánta CPU usa el proceso dosbox-x.exe. Con el mismo valor de cycles el uso real puede cambiar según el procesador, el core configurado o el tipo de instrucciones del programa, y con un valor muy alto el proceso puede llegar a ocupar un núcleo completo del anfitrión.

Para estimar los ciclos reales que consume ciclos.com habría que medir el proceso dosbox-x.exe desde Windows mientras corre el bucle, en lugar de leer el valor de cycles del archivo de configuración. El Administrador de tareas, en la pestaña Detalles, muestra el porcentaje de CPU y el tiempo de CPU acumulado del proceso. Una herramienta más precisa es Process Explorer, que puede mostrar los ciclos de CPU consumidos por cada proceso. En Linux se podría usar perf stat, que cuenta directamente los ciclos de reloj que usa un programa.

## Checkpoint 8 — Decisiones técnicas de cycles
Capturas: capturas/p1_cp8_ciclos.png y capturas/p1_cp8_adm_tareas.png

Para comprobar la segunda decisión se ejecutó otra vez ciclos.com con cycles en 8000 y mientras corría el bucle se abrió el Administrador de tareas de Windows. El bucle volvió a tardar 32,90 segundos, igual que en la corrida 1, y durante ese tiempo DOSBox-X solo usaba el 0,5 % de la CPU del equipo, que tiene 20 núcleos. Esto muestra que el valor de cycles no indica cuánto trabaja realmente el procesador del anfitrión.

# PARTE 2 — VirtualBox y máquinas virtuales

## Checkpoint 1 — VM creada y configurada
Captura: capturas/p2_cp1_vm_config.png

La máquina virtual se creó con VBoxManage desde PowerShell. Se registró con el nombre Lab5-Alpine y el tipo Other Linux de 64 bits, con 1024 MB de RAM, 16 MB de video, una CPU y la red en modo NAT. Se creó un disco VDI de asignación dinámica de 10 GB conectado a un controlador SATA, y la imagen ISO de Alpine Linux 3.19 quedó en la unidad de DVD de un controlador IDE. Todos los comandos usados están en el archivo VBoxManage_commands.sh.

## Checkpoint 2 — Alpine Linux instalado y operativo
Captura: capturas/p2_cp2_alpine_red.png

La VM arrancó desde la ISO en modo live y la instalación se hizo con setup-alpine usando el nombre lab5-vm, la red por DHCP, la zona horaria America/Bogota, chrony como cliente NTP, openssh como servidor SSH y el disco sda en modo sys. El teclado se configuró como latam porque el equipo anfitrión usa un teclado latinoamericano. Al terminar se apagó la VM y se retiró la ISO de la unidad óptica para que arrancara desde el disco.

Después de iniciar sesión como root, ip addr show eth0 mostró la dirección 10.0.2.15 que entrega el NAT de VirtualBox, y ping -c 3 8.8.8.8 recibió los tres paquetes sin pérdidas, lo que confirma que la VM tiene salida a internet.

## Checkpoint 3 — Modos de red
Capturas: capturas/p2_cp3_red_nat.png, capturas/p2_cp3_red_hostonly.png, capturas/p2_cp3_hostonly_ping_anfitrion.png y capturas/p2_cp3_red_bridge.png

Se probaron los tres modos de red. Para cada cambio se apagó la VM, se cambió el modo con VBoxManage modifyvm y se volvió a iniciar. El adaptador Host-Only de VirtualBox ya existía con la IP 192.168.56.1, así que no fue necesario crearlo.

| Modo | IP de la VM | Resultado |
|---|---|---|
| NAT | 10.0.2.15 | La VM tiene internet |
| Host-Only | 192.168.56.101 | El anfitrión llega a la VM pero la VM no tiene internet |
| Bridge | 192.168.1.4 | La VM tiene internet y queda en la misma red de la casa |

En NAT la VM queda en una red privada que crea VirtualBox y sale a internet a través del anfitrión. En Host-Only queda en una red aislada con el anfitrión, por eso Windows sí le responde pero la VM no tiene ruta hacia internet. En Bridge la VM recibe la IP del router de la casa, en la misma red 192.168.1.0 donde está el anfitrión con 192.168.1.2. Al terminar la VM se dejó otra vez en NAT.

## Checkpoint 4 — Snapshots
Capturas: capturas/p2_cp4_herramientas_instaladas.png, capturas/p2_cp4_snapshots_lista.png y capturas/p2_cp4_restaurado_sin_curl.png

Con la VM encendida se tomó el snapshot snap_base con Alpine recién instalado. Luego se instalaron curl, wget, nano y htop con apk y se tomó el snapshot snap_con_herramientas. El árbol de snapshots quedó así.

```
Lab5-Alpine
└── snap_base            Alpine Linux 3.19 recien instalado, sin modificaciones
    └── snap_con_herramientas   Alpine con curl, wget, nano y htop instalados
```

Después se apagó la VM y se restauró snap_base. Al iniciarla volvió con la sesión de root abierta, porque el snapshot se tomó en caliente y guardó también la memoria. Los comandos apk info -e curl y which curl no devolvieron nada y curl --version respondió not found, lo que confirma que la VM volvió al estado anterior sin tener que desinstalar nada a mano.

## Checkpoint 5 — Recursos de la VM reasignados
Capturas: capturas/p2_cp5_modifyvm.png y capturas/p2_cp5_nproc_free.png

Con la VM apagada se consultó la configuración con showvminfo, que mostraba 1024 MB de memoria y 1 CPU. Luego se ejecutó VBoxManage modifyvm con 2 CPUs y 2048 MB sin errores, y al consultar de nuevo ya aparecían los valores nuevos. Al iniciar la VM, nproc mostró 2 procesadores y free -m mostró 1976 MB de memoria total. Este número es un poco menor que 2048 porque el kernel de Linux se reserva una parte de la memoria para sí mismo al arrancar.

## Checkpoint 6 — Disco fijo frente a disco dinámico
Capturas: capturas/p2_cp6_fdisk.png, capturas/p2_cp6_formato_montaje.png y capturas/p2_cp6_benchmark_dd.png

Con la VM apagada se creó Lab5-Alpine-fixed.vdi, un disco de 4 GB con asignación fija, y se conectó al puerto 1 del controlador SATA. En cuanto se creó ya ocupaba 4098 MB en el disco del anfitrión, mientras que Lab5-Alpine.vdi, que es dinámico y de 10 GB, ocupaba solo 271 MB. Dentro de Alpine el disco nuevo apareció como /dev/sdb. Se creó una partición primaria con fdisk, se formateó con mkfs.ext4 y se montó en /mnt/fijo. Luego se escribieron 200 MB con dd en cada disco.

| Tipo de disco | Comando | Tiempo real |
|---|---|---|
| Fijo (Lab5-Alpine-fixed.vdi) | dd sobre /mnt/fijo/test.img | 0,44 s |
| Dinámico (Lab5-Alpine.vdi) | dd sobre /root/test.img | 0,45 s |

El disco fijo fue un poco más rápido, aunque la diferencia es de apenas una centésima. Esto pasa porque dd escribe primero en la memoria caché del sistema y con 2 GB de RAM los 200 MB caben completos, así que la medición depende más de la memoria que del disco. Como la VM tiene snapshots, las escrituras del disco principal van a un disco de diferencias dentro de la carpeta Snapshots, que también crece de forma dinámica.
