#!/bin/sh
# Comandos de VBoxManage usados en la Parte 2 del laboratorio
# Se ejecutaron en Windows con VirtualBox 7.2.22, cada uno en una sola linea

# Paso 1. Creacion de la maquina virtual Lab5-Alpine
VBoxManage createvm --name "Lab5-Alpine" --ostype "Linux_64" --register
VBoxManage modifyvm "Lab5-Alpine" --memory 1024 --vram 16 --cpus 1 --nic1 nat
VBoxManage createmedium disk --filename "C:\Users\SaritaUltra\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine.vdi" --size 10240 --format VDI
VBoxManage storagectl "Lab5-Alpine" --name "SATA" --add sata
VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\Users\SaritaUltra\VirtualBox VMs\Lab5-Alpine\Lab5-Alpine.vdi"
VBoxManage storagectl "Lab5-Alpine" --name "IDE" --add ide
VBoxManage storageattach "Lab5-Alpine" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "C:\Users\SaritaUltra\Downloads\alpine-standard-3.19.0-x86_64.iso"

# Paso 2. Despues de instalar Alpine se retira la ISO para arrancar desde el disco
VBoxManage storageattach "Lab5-Alpine" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium emptydrive
