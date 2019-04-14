#!/bin/bash
# TODO: [WIP]
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.3.log")
exec 2> >(tee "stderr.3.log")

USER=hoa

systemctl enable --now systemd-timesyncd.service
timedatectl set-ntp true
timedatectl show-timesync --all
timedatectl status
timedatectl timesync-status

pacman -S --noconfirm fish
useradd -mU -s /usr/bin/fish -G wheel,input,sys "$USER" || echo "Added"

pacman -S --noconfirm openssh sshfs
systemctl enable sshd.socket sshd@.service

pacman -S --noconfirm unrar unzip tmux tree fwupd openbsd-netcat p7zip stow nfs-utils crda fzf

pacman -S --noconfirm xorg-server xorg-xrandr xorg-xdpyinfo mesa-demos
pacman -S --noconfirm ttf-liberation powerline-fonts ttf-croscore ttf-carlito ttf-caladea ttf-fira-code adobe-source-code-pro-fonts otf-ipafont

pacman -S --noconfirm cups foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds
systemctl enable org.cups.cupsd.service

pacman -S --noconfirm plasma-desktop plasma-nm plasma-workspace sddm sddm-kcm \
    phonon-qt5-gstreamer phonon-qt5-vlc kinfocenter kscreen kscreenlocker \
    kmenuedit kwalletmanager ksysguard kwin breeze breeze-gtk kwrite kactivities \
    kde-cli-tools kde-gtk-config kdecoration kdeplasma-addons kgamma5 khotkeys \
    latte-dock powerdevil bluedevil yakuake plasma-pa discover \
    konsole yakuake dolphin ark spectacle okular gwenview adapta-gtk-theme \
    chromium firefox mcomix keepassx kdeconnect \
    pulseaudio pulseaudio-bluetooth pavucontrol-qt pulseaudio-alsa \
    alsa gstreamer gst-plugins-good gst-plugins-ugly gst-libav \
    gstreamer-vaapi libva-intel-driver mpv  \
    transmission-qt remmina
systemctl enable sddm.service

pacman -S --noconfirm libreoffice-still hunspell-en_GB ibus-unikey

# arch-chroot /mnt useradd -mU -s /usr/bin/fish -G wheel,uucp,video,audio,storage,games,input,sys "$USER"
# arch-chroot /mnt chsh -s /usr/bin/fish

# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si
# Color pacman

# nfc

# yay -S nvme-cli nerd-fonts-source-code-pro otf-san-francisco otf-sfmono ttf-public-sans pandoc-bin
# yay -c -Sc
# libinput-gestures  mill yay-bin stack-static ripgrep

# yay -S telegram-desktop drive-bin inxi

# setup bluetooth
# systemctl enable bluetooth.service

# packagekit-qt5 # fwupd-backend

# tar cvpf - . |  pv | netcat -l -w 5 -q 5  -p 9999
# netcat -w 5 -q 5 192.168.1.68 9999 | pv |  tar xvpf -
