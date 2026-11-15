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

## Decisión Técnica — Modo de red para una VM de laboratorio personal
Para una VM de práctica que solo usa la estudiante en su propio equipo, el modo más apropiado por defecto es NAT. En este modo VirtualBox funciona como un router privado. La VM recibe una dirección de una red interna, en este caso 10.0.2.15, y sale a internet a través del anfitrión, pero ningún otro dispositivo de la red local la puede ver. Las conexiones solo pueden empezar desde la VM hacia afuera y las respuestas vuelven por el mismo camino, así que nadie puede iniciar una conexión hacia ella a menos que se configure un reenvío de puertos.

Host-Only sería preferible cuando se quiere experimentar con configuraciones de red sin exponer la VM a ningún tráfico externo, ni siquiera de salida. En el curso podría servir para probar servicios entre el anfitrión y la VM, como una conexión SSH desde Windows a 192.168.56.101, o para practicar con direcciones IP y rutas sin riesgo de afectar otra red. Lo que se pierde es el acceso a internet, como se vio en la prueba donde ping a 8.8.8.8 respondió Network unreachable, y sin internet tampoco se pueden instalar paquetes con apk.

Bridge es la opción de mayor riesgo para este escenario. En la prueba la VM recibió la dirección 192.168.1.4 del router de la casa, en la misma red que el anfitrión, y quedó alcanzable por cualquier dispositivo conectado a esa red. Alpine tiene activo sshd desde la instalación. Aunque por defecto no permite entrar como root con contraseña, el servicio queda expuesto y cualquier error de configuración o falla de seguridad en sshd podría aprovecharse desde otro equipo de la red. Eso aumenta la superficie de ataque sin ningún beneficio para una VM de práctica, por eso Bridge solo se justifica cuando otros equipos de la red sí necesitan llegar a la VM.

## Decisión Técnica — Disco fijo frente a dinámico y asignación de CPU y RAM
Según la tabla del Paso 6, el disco fijo fue el más rápido, con 0,44 segundos frente a 0,45 del dinámico. La diferencia es pequeña porque dd escribe primero en la caché de memoria de la VM, pero la razón de la ventaja es que el archivo del disco fijo ya ocupa todo su tamaño en el anfitrión desde que se crea. Cuando la VM escribe, VirtualBox solo tiene que guardar los datos en un espacio que ya existe. En el disco dinámico, cada vez que la VM escribe en una zona nueva VirtualBox tiene que hacer crecer el archivo .vdi, pedir más espacio al sistema de archivos de Windows y actualizar la tabla que relaciona los bloques, y ese trabajo extra cuesta tiempo.

A pesar de eso, el disco dinámico sigue siendo la opción por defecto en un laboratorio con muchos estudiantes y equipos limitados, porque solo ocupa lo que el sistema invitado realmente usa. En este laboratorio Lab5-Alpine.vdi está declarado de 10 GB pero ocupaba 271 MB, mientras que el disco fijo de 4 GB ocupó 4098 MB desde el primer momento sin tener ningún dato. Si cada estudiante creara discos fijos los discos de los equipos se llenarían rápido, y la pequeña pérdida de velocidad no importa para una VM de práctica.

Asignar 2 CPUs y 2048 MB es razonable porque en un equipo típico de 4 a 8 CPUs y 8 a 16 GB de RAM deja la mayor parte de los recursos para el anfitrión, y con eso Alpine funciona con holgura, como mostró free con más de 1800 MB disponibles. En el equipo usado, con 20 núcleos y 31 GB, la proporción es todavía menor. Asignar todos los CPUs o la mayoría de la RAM sería una mala práctica porque el anfitrión es el que ejecuta la VM. Si se queda sin recursos se vuelve lento todo el sistema, incluido el propio VirtualBox, y Windows puede empezar a usar el archivo de paginación, lo que hace más lentas a las dos máquinas.

## Checkpoint 7 — Decisiones técnicas de red y almacenamiento
Captura: capturas/p2_cp7_tamano_vdi.png

Para respaldar la segunda decisión se listó el tamaño real de los discos de la VM en la carpeta de VirtualBox. Lab5-Alpine-fixed.vdi ocupa 4098 MB aunque solo tiene un archivo de prueba, mientras que Lab5-Alpine.vdi ocupa 271 MB aunque está declarado de 10 GB. Los dos archivos con nombre entre llaves son los discos de diferencias que crearon los snapshots, con 28 MB y 27 MB.

## Checkpoint 8 — Exportación OVA y repositorio consolidado
Capturas: capturas/p2_cp8_ova.png y [PENDIENTE: captura de la vista del repositorio en GitHub]

Con la VM apagada se exportó Lab5-Alpine en formato OVA con un manifiesto. El comando terminó con el mensaje Successfully exported 1 machine(s) y el archivo Lab5-Alpine-export.ova quedó con 168 793 088 bytes, unos 161 MB. Es mucho menos que la suma de los discos porque el OVA guarda los discos comprimidos y no incluye los bloques vacíos, así que los 4 GB del disco fijo casi no ocupan espacio dentro del archivo. El .ova quedó en la carpeta VirtualBox VMs del anfitrión y no se sube al repositorio, igual que los archivos .vdi, por eso están en el .gitignore.

# Conclusiones

DOSBox y VirtualBox permiten ejecutar otro sistema dentro de Windows, pero lo hacen de forma muy distinta. DOSBox es un emulador. Imita en software un procesador x86 antiguo y cada instrucción del programa la interpreta el propio DOSBox. Por eso la velocidad del programa depende del valor de cycles y no del procesador real. El mismo ciclos.com tardó 270,12 segundos con 1000 cycles, 32,90 con 8000 y 13,13 con 20000, y mientras tanto DOSBox-X solo usaba alrededor del 0,5 % de la CPU del equipo. El valor de cycles es entonces un límite que pone el emulador y no una medida del trabajo del procesador.

VirtualBox en cambio virtualiza. El sistema invitado usa la misma arquitectura que el anfitrión y sus instrucciones se ejecutan directamente en el procesador real, con VirtualBox controlando los recursos que se le prestan. Por eso Alpine funcionó con una velocidad normal y lo que se configura no es una velocidad sino cuántos CPUs, cuánta RAM y qué discos ve la VM. Esos cambios se hicieron con la VM apagada y se comprobaron dentro de ella con nproc y free.

En la red se vio que cada modo cambia quién puede llegar a la VM. Con NAT la VM salió a internet con la dirección 10.0.2.15 sin ser visible desde la red de la casa. Con Host-Only solo se comunicó con el anfitrión, y con Bridge quedó en la misma red que los demás equipos. Los snapshots mostraron que se puede volver a un estado anterior en segundos, ya que al restaurar snap_base desapareció curl, y que cada snapshot crea un disco de diferencias pequeño en lugar de copiar todo el disco. Finalmente la comparación de discos mostró que el disco fijo es apenas más rápido, pero el dinámico ahorra mucho espacio, y la exportación OVA permite llevar toda la VM en un solo archivo a otro equipo.
