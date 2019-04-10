```
ARCH_201704 - https://superuser.com/questions/519784/error-installing-arch-linux

wifi-menu
ip addr

pacman -Sy

sgdisk -Z /dev/sda
sgdisk -a 2048 -o /dev/sda

sgdisk -n 1:0:+200M /dev/sda
sgdisk -n 2:0:0 /dev/sda

sgdisk -t 1:ef00 /dev/sda
sgdisk -t 2:8300 /dev/sda

sgdisk -c 1:bootefi /dev/sda
sgdisk -c 2:root /dev/sda

fdisk -l

lvmdiskscan

pvcreate /dev/sda2
pvdisplay

vgcreate vgroup /dev/sda2
vgdisplay

lvcreate --size 42G --name lvroot vgroup
lvcreate --extents +100%FREE --name lvhome vgroup
lvdisplay


# create filesystem
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/mapper/vgroup-lvroot
mkfs.ext4 /dev/mapper/vgroup-lvhome

# Mount the partitions
mount /dev/mapper/vgroup-lvroot /mnt
mkdir -p /mnt/boot
mount -t vfat /dev/sda1 /mnt/boot
mkdir /mnt/home
mount /dev/mapper/vgroup-lvhome /mnt/home


# select a mirror / interative or not
pacstrap -i /mnt base base-devel

# -U use UUDis for source identifiers 
# -p execlude pseudofs mounts
genfstab -U -p /mnt >> /mnt/etc/fstab
vi /mnt/etc/fstab

# chroot time
arch-chroot /mnt

# other modifications
# vi /etc/mkinitcpio.conf
# hooks
encrypt lvm2 filesystems shutdown
# modules
vfat ext4 dm_mod dm_crypt aes_x86_64 i915


# add options to /etc/lvm/lvm.conf
issue_discards 1

# Time
ln -sf /usr/share/zoneinfo/Singapore /etc/localtime
hwclock --systohc

vi /etc/locale.gen
# locale-gen
sudo localectl set-locale LANG=en_SG.UTF-8


vi /etc/hostname

pacman -S intel-ucode

mkinitcpio -p linux

bootctl --path=/boot install

# vi /boot/loader/loader.conf
# default arch
# timeout 3
cp /usr/share/systemd/bootctl/loader.conf /boot/loader/loader.conf
cp /usr/share/systemd/bootctl/arch.conf /boot/loader/entries/

pacman -S dialog rsync netcat pv

exit 
umount -R /mnt
reboot

https://wiki.archlinux.org/index.php/Installation_guide
https://wiki.archlinux.org/index.php/systemd-boot#Configuration
https://gist.github.com/jasonwryan/4618490
https://fhackts.wordpress.com/2016/09/09/installing-archlinux-the-efisystemd-boot-way/
```


```
POST Installation

# vim
pacman -S vim

# time n clock
pacman -S ntp
timedatectl set-timezone Asia/Singapore
ntpd -qg
hwclock --systohc

# NM
pacman -S networkmanager

# TLP
pacman -S tlp acpi_call # tp_smapi
pacman -S x86_energy_perf_policy
# /etc/default/tlp
# START_CHARGE_THRESH_BAT0=60
# STOP_CHARGE_THRESH_BAT0=90

systemctl enable --now  tlp.service
systemctl enable tlp-sleep.service
systemctl disable systemd-rfkill.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
tlp start

/sys/class/power_supply/BAT0
#  sudo tlp setcharge 70 90 BAT0 

# Thermald
? lm_sensors ?
thermald
sudo systemctl enable --now thermald

# HDD monitor
smartmontools

# SSD Trim
systemctl enable fstrim.timer

# backlight
acpi_osi=Linux acpi_backlight=vendor
=vendor, =linux and ='!Windows 2012'


pacman -S xorg-server
pacman -S plasma
pacman -S konsole yakuake dolphin
systemctl enable sddm.service
pacman -S fish
useradd -m -G wheel -s /usr/bin/fish hoa
mkdir -p ~/bin
set -U fish_user_paths ~/bin $fish_user_paths
```

```
# Network
NetworkManager
systemctl enable NetworkManager-dispatcher.service

```

[hoa ~]$ wol 00:11:32:31:1A:17 -v -i 255.255.255.0

yaourt -Qm
journalctl -b --priority=3

disable filesearch
sddmbreeze theme

konsole chromium firefox

pacman -S netcat pv wol
pacman -S git

```
openssh
systemctl enable sshd.socket
```

calibre

kwriteconfig5 --file kwinrc --group Windows --key BorderlessMaximizedWindows true

-S read-edid
sudo pacman -S colord-kde
sudo pacman -S phonon-qt5-gstreamer phonon-qt5-vlc
colord-kde-icc-importer
colormgr device-add-profile
colormgr device-make-profile-default

thinkpad color profile

kwallet-manager

xorg-xgamma


```
#pacuar
/etc/pacman.conf

sudo pacman -S expac yajl --noconfirm

mkdir -p /tmp/pacaur_install
cd /tmp/pacaur_install

if [ ! -n "$(pacman -Qs cower)" ]; then
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
    makepkg PKGBUILD --skippgpcheck --install --needed
fi

if [ ! -n "$(pacman -Qs pacaur)" ]; then
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
    makepkg PKGBUILD --install --needed
fi


```

```
fonts:
ttf
pacaur -S ttf-liberation powerline-fonts ttf-croscore ttf-carlito ttf-caladea
ttf-fira-code
otf-hasklig


adobe-source-code-pro-fonts
otf-ipafont 
lcdfilter

for family in serif sans-serif monospace Arial Helvetica Verdana "Times New Roman" "Courier New"; do
  echo -n "$family: "
  fc-match "$family"
done

  <!-- Set preferred serif, sans serif, and monospace fonts. -->
  <alias>
    <family>serif</family>
    <prefer><family>Tinos</family></prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Arimo</family></prefer>
  </alias>
  <alias>
    <family>sans</family>
    <prefer><family>Arimo</family></prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>Cousine</family></prefer>
  </alias>

  <!-- Aliases for commonly used MS fonts. -->
  <match>
    <test name="family"><string>Arial</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Arimo</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Helvetica</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Arimo</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Verdana</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Arimo</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Tahoma</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Arimo</string>
    </edit>
  </match>
  <match>
    <!-- Insert joke here -->
    <test name="family"><string>Comic Sans MS</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Arimo</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Times New Roman</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Tinos</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Times</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Tinos</string>
    </edit>
  </match>
  <match>
    <test name="family"><string>Courier New</string></test>
    <edit name="family" mode="assign" binding="strong">
      <string>Cousine</string>
    </edit>
  </match>

https://seasonofcode.com/posts/how-to-set-default-fonts-and-font-aliases-on-linux.html

```


tmux vimperator
pulseaudio alsa
keepassxc

```
# torrent
# transmission
```


```
# utilities
stow
tree
ark p7zip spectacle mcomix okular gwenview mpv
curl wget
```

```
# printing
cups foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds
sudo systemctl enable org.cups.cupsd.service
sudo gpasswd -a hoa sys


libreoffice-still
hunspell
```

```
# audio and video codec
gst-plugins-good gst-plugins-ugly gst-libav
libva-intel-driver gstreamer-vaapi

```

```
# java & scala
jre8-openjdk scala
coursier

```

```
# python
python-virtualenvwrapper
```

ssh config
rsync -avzh -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress hoa@192.168.1.234:/home/hoa/.ssh /tmp/
git clone git@github.com:saikocat/dotfiles.git


curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -u $HOME/.vimrc.bundles +PlugInstall +PlugClean! +qa

powerline-fonts

/etc/systemd/journald.conf
SystemMaxUse=100M


```
pacman -S nfs-utils
rpcbind.service nfs-client.target

```

```
# KeepassXC
# dropbox
```

```
# monitor
glances
```

```
#bluetooth
bluez
sudo systemctl start bluetooth.service
```

```
swap
/etc/sysctl.d/99-sysctl.conf
vm.swappiness=10
```

```
# Haskell
stack
stack setup
stack ghci
```

```
# Scala Coursier
```

```
rm ~/.local/share/applications/telegramdesktop.desktop
```


```
docker docker-compose
sudo su
mkdir -p /home/docker
chmod go-rwx /home/docker
ln -s /home/docker /var/lib/docker


kvm qemu
```

```
cbt
$ git archive --format=tar --remote=<repository URL> HEAD | tar xf -
http://takezoe.hatenablog.com/entry/2017/02/15/150839
https://github.com/cvogt/cbt
```
pip install websocket-client sexpdata

```
set -U fish_user_paths /usr/local/bin $fish_user_paths
```


adapta-gtk-theme
exa
libpinput-gesture


/etc/default/tlp
USB_BLACKLIST
0fce:01f4


# wayland
pacaur -S plasma-wayland-session
