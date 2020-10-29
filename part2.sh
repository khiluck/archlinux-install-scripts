#!/bin/bash

# ВОТ ТУТ CHROOT !!! #

#Имя системы
echo "archlinux" > /etc/hostname

#установка раскладки клавиатуры
echo "KEYMAP=us" > /etc/vconsole.conf
#установка шрифта 
echo "FONT=ter-v22b" >> /etc/vconsole.conf
pacman -Sy --noconfirm terminus-font

#установка локали
#echo "LANG=ru_UA.UTF-8" > /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_COLLATE=C" » /etc/locale.conf
#echo "ru_UA.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
#sed -i `/#ru_UA.UTF-8/s/^#//g` /etc/locale.gen
locale-gen

#установка времени
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime


timedatectl set-ntp true
timedatectl status


#UTC синхронизация
hwclock --systohc --utc



#Grub install
#bootloader grub установка
pacman -Sy --noconfirm --needed grub
pacman -Sy --noconfirm --needed efibootmgr

mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot --recheck /dev/sda



#------ установка desktop ------#

# установка зависимостей
pacman -Sy --noconfirm --needed libnewt
pacman -Sy --noconfirm --needed dhcpcd
pacman -Sy --noconfirm --needed pacman-contrib
pacman -Sy --noconfirm --needed base-devel
pacman -Sy --noconfirm --needed git
pacman -Sy --noconfirm --needed vim
pacman -Sy --noconfirm --needed man

## создаем пользователя aurbuilder для компиляции yay, т.к. из под root это сделать нельзя!
newpass=$(< /dev/urandom tr -dc "@#*%&_A-Z-a-z-0-9" | head -c16)
    useradd -r -N -M -d /tmp/aurbuilder -s /usr/bin/nologin aurbuilder
    echo -e "$newpass\n$newpass\n"|passwd aurbuilder
    newpass=""
    mkdir /tmp/aurbuilder 1&>/dev/null
    chmod 777 /tmp/aurbuilder
#
	echo "aurbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aurbuilder
    echo "root ALL=(aurbuilder) NOPASSWD: ALL" >> /etc/sudoers.d/aurbuilder
##


#создание папок и скачивание yay и установка
    cd /tmp/aurbuilder
    sudo -u aurbuilder git clone https://aur.archlinux.org/package-query.git
    cd package-query
    sudo -u aurbuilder makepkg -si --noconfirm

# установка yay
      cd /tmp/aurbuilder
      sudo -u aurbuilder git clone https://aur.archlinux.org/yay.git
      cd yay
      sudo -u aurbuilder makepkg -si --noconfirm


# обновление с помощью yay
    sudo -u aurbuilder yay -Syu


## - Установка приложений - ##

#консоль
pacman -Sy --noconfirm --needed bash-completion usbutils lsof dmidecode dialog xclip wget

#архиваторы
pacman -Sy --noconfirm --needed zip unzip unrar p7zip lzop

#сетевые утилиты
pacman -Sy --noconfirm --needed rsync traceroute bind-tools nmap


## - Система - ##
#ядро
pacman -Sy --noconfirm --needed linux-headers

#services
pacman -Sy --noconfirm --needed networkmanager openssh cronie xdg-user-dirs haveged


#cpu microcode
pacman -Sy --noconfirm --needed intel-ucode
#pacman -Sy --noconfirm --needed amd-ucode

#пересобираем конфиг для grub, после установки ucode для процессора
grub-mkconfig -o /boot/grub/grub.cfg

#start services at boot
systemctl enable NetworkManager
systemctl disable dhcpcd
systemctl enable cronie
systemctl enable haveged

#filesystem support install
pacman -Sy --noconfirm --needed f2fs-tools dosfstools ntfs-3g btrfs-progs exfat-utils gptfdisk autofs fuse2 fuse3 fuseiso sshfs cifs-utils smbclient

#sound
pacman -Sy --noconfirm --needed alsa-utils alsa-plugins pulseaudio pulseaudio-alsa pulseaudio-bluetooth

#print support
pacman -Sy --noconfirm --needed cups ghostscript cups-pdf
#start cups service at boot
systemctl enable org.cups.cupsd


## - XOrg - ##

pacman -Sy --noconfirm --needed xorg-server xorg-xinit xorg

#fonts
pacman -Sy --noconfirm --needed ttf-linux-libertine ttf-inconsolata noto-fonts
pacman -Sy --noconfirm --needed font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1
pacman -Sy --noconfirm --needed gnu-free-fonts

#microsoft ttf fonts
sudo -u aurbuilder yay -S --noconfirm --needed ttf-ms-fonts

# big pack of google ttf fonts
#sudo -u aurbuilder yay -S --noconfirm --needed ttf-google-fonts-git

# terminus ttf fonts
sudo -u aurbuilder yay -S --noconfirm --needed terminus-font-ttf

# input drivers
pacman -Sy --noconfirm --needed xf86-input-libinput

# video drivers
# GPU info
#lspci | grep -e VGA -e 3D
#show all open-source drivers
#pacman -Ssq xf86-video
#устанавливаем нужные
pacman -Sy --noconfirm --needed xf86-video-intel

#если амд - xf86-video-amdgpu
#если нвидиа, то - nvidia (проприетарные)
#pacman -Sy --noconfirm --needed nvidia


## - ФИНАЛЬНЫЕ НАСТРОЙКИ СИСТЕМЫ - ##

# #редактор по умолчанию
# echo "export EDITOR=vim" > /etc/profile.d/editor.sh
# chmod 755 /etc/profile.d/editor.sh

# #Aliases
# echo "alias sudo='sudo '" >> /etc/profile.d/alias.sh
# echo "alias vi='vim'" >> /etc/profile.d/alias.sh
# echo "alias ls='ls --color=auto -l --time-style long-iso'" >> /etc/profile.d/alias.sh
# echo "alias ll='ls --color=auto -la --time-style long-iso'" >> /etc/profile.d/alias.sh
# echo "alias grep='grep --color=auto'" >> /etc/profile.d/alias.sh
# echo "alias egrep='egrep --color=auto'" >> /etc/profile.d/alias.sh
# echo "alias fgrep='fgrep --color=auto'" >> /etc/profile.d/alias.sh
# echo "alias ip='ip -c'" >> /etc/profile.d/alias.sh

# echo "alias pacman='pacman --color auto'" >> /etc/profile.d/alias.sh
# echo "alias pactree='pactree --color'" >> /etc/profile.d/alias.sh
# echo "alias yay='sudo -u aurbuilder yay'" >> /etc/profile.d/alias.sh
# echo "alias vdir='vdir --color=auto'" >> /etc/profile.d/alias.sh
# echo "alias watch='watch --color'" >> /etc/profile.d/alias.sh

# echo 'man() {' >> /etc/profile.d/alias.sh
# 			echo '	env \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_mb=$(printf "\e[1;31m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_md=$(printf "\e[1;31m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_me=$(printf "\e[0m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_se=$(printf "\e[0m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_ue=$(printf "\e[0m") \' >> /etc/profile.d/alias.sh
# 			echo '		LESS_TERMCAP_us=$(printf "\e[1;32m") \' >> /etc/profile.d/alias.sh
# 			echo '			man "$@"' >> /etc/profile.d/alias.sh
# 			echo '}' >> /etc/profile.d/alias.sh


# # ps1
# cat > /etc/profile.d/ps1.sh << "EOF"
# #!/bin/bash
# clrreset='\e[0m'
# clrwhite='\e[1;37m'
# clrgreen='\e[1;32m'
# clrred='\e[1;31m'
# export PS1="\[$clrwhite\]\w \`if [ \$? = 0 ]; then echo -e '\[$clrgreen\]'; else echo -e '\[$clrred\]'; fi\`\\$ \[$clrreset\]"
# EOF
# chmod 755 /etc/profile.d/ps1.sh

# grep -q -F 'source /etc/profile.d/ps1.sh' /etc/bash.bashrc || echo 'source /etc/profile.d/ps1.sh' >> /etc/bash.bashrc


###

#установка пароля root
echo "Enter password for root:"
passwd root

## добавление нового пользователя ##
useradd -m -N aex
echo "Enter password for user aex:"
passwd aex

#добавление пользователя в группу sudo
echo "aex ALL=(ALL) ALL" > /etc/sudoers.d/aex
echo "aex ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aex

# 
