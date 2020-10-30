#!/bin/bash

cat << EOF2 > /etc/pacman.d/mirrorlist
Server = https://archlinux.ip-connect.vn.ua/$repo/os/$arch
#Server = http://mirror.mirohost.net/archlinux/$repo/os/$arch
Server = https://mirror.mirohost.net/archlinux/$repo/os/$arch
#Server = http://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
Server = https://mirrors.nix.org.ua/linux/archlinux/$repo/os/$arch
EOF2

#установка шрифтов, чтоб я мог что-то видеть
pacman -Sy --noconfirm terminus-font
setfont ter-v22b

#установка локали
echo "LANG=ru_UA.UTF-8" > /etc/locale.conf
echo "ru_UA.UTF-8 UTF-8" >> /etc/locale.gen
#sed -i `/#ru_UA.UTF-8/s/^#//g` /etc/locale.gen
locale-gen

#раскладка
loadkeys us

#default text editor
export EDITOR=vim

#Разметка диска /dev/sda (к примеру)
#/dev/sda1	1GB - EFI System  	(/boot)		FAT32		
#/dev/sda2	+GB - Linux filesystem	(root)		ext4		

#Форматирование разделов
mkfs.fat /dev/sda1
mkfs.ext4 -F /dev/sda2

#Монтирование 
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot


#Установка 
pacstrap /mnt base linux linux-firmware

#генерируем fstab
genfstab -U -p /mnt > /mnt/etc/fstab










