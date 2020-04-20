#!/bin/bash

#раскладка
loadkeys us

#default text editor
export EDITOR=vim

#Разметка диска /dev/sda (к примеру)
#/dev/sda1	1GB - EFI System  	(/boot)		FAT32		
#/dev/sda2	4GB - Linux swap  	(swap)		swap		
#/dev/sda3	+GB - Linux filesystem	(root)		ext4		

#Форматирование разделов
mkfs.fat /dev/sda1
#mkswap /dev/sda2
mkfs.ext4 -F /dev/sda2

#Монтирование 
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
#swapon /dev/sda2

#Установка 
pacstrap /mnt base linux linux-firmware

#генерируем fstab
genfstab -U -p /mnt > /mnt/etc/fstab










