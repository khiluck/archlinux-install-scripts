#!/bin/bash

###	 ПОДГОТОВКА  ###
	
# раскладка
loadkeys us

# установка шрифта, чтоб я мог что-то видеть во время установки)
pacman -Sy terminus-font
setfont ter-v18b

# редактор по умолчанию
export EDITOR=vim


###  УСТАНОВКА  ###

# на какой диск ставим ? должны быть подготовлены разделы, отформатированы и примонтированны
# (может позже добавлю это в скрипт)
# основной раздел в /mnt и загрузочный раздел в /mnt/boot

#ставим базовый набор
pacstrap /mnt base linux linux-firmware

#генерируем fstab
genfstab -U -p /mnt > /mnt/etc/fstab

#cpu microcode, перед установкой загрузчика, он подхватит сам
pacstrap /mnt intel-ucode
#pacstrap /mnt amd-ucode

#bootloader grub установка
pacstrap /mnt grub
pacstrap /mnt efibootmgr

arch-chroot /mnt
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --recheck /dev/sda
exit


# добавляем имя компа
echo "archlinux" > /mnt/etc/hostname

#установка раскладки клавиатуры
echo "KEYMAP=us" > /mnt/etc/vconsole.conf
#установка шрифта 
pacstrap /mnt terminus-font
echo "FONT=ter-v18b" >> /mnt/etc/vconsole.conf

#установка локали
echo "LANG=ru_UA.UTF-8" > /mnt/etc/locale.conf
echo "LC_COLLATE=C" » /mnt/etc/locale.conf
sed -i `/#ru_UA.UTF-8/s/^#//g` /mnt/etc/locale.gen
arch-chroot /mnt
locale-gen
exit
echo Локаль установилась ?
read -p

#установка времени
ln -sf /mnt/usr/share/zoneinfo/Europe/Kiev /mnt/etc/localtime
#UTC синхронизация
arch-chroot /mnt
hwclock --systohc --utc
exit

#установка пароля root
arch-chroot /mnt 
echo Enter new password for root:
passwd root
exit



