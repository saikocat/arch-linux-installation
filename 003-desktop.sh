#!/bin/bash
# TODO: [WIP]
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.3.log")
exec 2> >(tee "stderr.3.log")

USER=hoa

pacstrap -S xorg-server plasma sddm konsole yakuake dolphin fish chromium firefox okular
arch-chroot /mnt systemctl enable sddm.service
# arch-chroot /mnt useradd -mU -s /usr/bin/fish -G wheel,uucp,video,audio,storage,games,input,sys "$USER"
# arch-chroot /mnt chsh -s /usr/bin/fish

# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si
# Color pacman

# ttf-liberation powerline-fonts ttf-croscore ttf-carlito ttf-caladea ttf-fira-code otf-hasklig adobe-source-code-pro-fonts otf-ipafont lcdfilter

# openssh nfs-utils hddtemp tmux
# systemctl enable sshd.socket
# calibre libreoffice-still hunspell pulseaudio alsa keepassxc

# sudo systemctl start bluetooth.service

# audio & codec
# phonon-qt5-gstreamer phonon-qt5-vlc gst-plugins-good gst-plugins-ugly gst-libav
# libva-intel-driver gstreamer-vaapi

# stow tree ark p7zip spectacle mcomix okular gwenview mpv curl wget

# cups foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds
# sudo systemctl enable org.cups.cupsd.service

# adapta-gtk-theme


# qemu ovmf
