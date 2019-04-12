#!/usr/bin/env bash
### WARNING: UNTESTED ###
# setfont -v latarcyrheb-sun32 # hidpi
# TODO: trap on SIGHUP SIGINT SIGTERM
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

# better create it from the sample variables
source ./variables

# Update system clock to ensure accuracy
timedatectl set-ntp true
timedatectl set-timezone ${TIMEZONE}
hwclock --systohc

# Prepare Disk & Partitions
echo ":: Prepare disk wipe & partitioning ..."

echo "Current partition layout on ${DISK} is:"
sgdisk -p "${DISK}"

sgdisk --zap-all ${DISK}

sgdisk --clear \
       --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:0       --typecode=2:8e00 --change-name=2:LVM \
         ${DISK}

partprobe "${DISK}"

# From the sgdisk u see that we have 2 partition number 1 & 2

# Alignment check
parted ${DISK} align-check optimal 1 | grep aligned
parted ${DISK} align-check optimal 2 | grep aligned

# Running partition detection
EFI_PARTITION=$(findfs PARTUUID="$(partx --output UUID --noheadings --raw -n 1 "${DISK}")")
LVM_PARTITION=$(findfs PARTUUID="$(partx --output UUID --noheadings --raw -n 2 "${DISK}")")

echo "${EFI_PARTITION} for EFI"
echo "${LVM_PARTITION} for LVM"

wipefs "${EFI_PARTITION}"
wipefs "${LVM_PARTITION}"

# LVM creation
VGROUP="arch-vg"
lvmdiskscan

pvcreate ${LVM_PARTITION}
pvdisplay

vgcreate ${VGROUP} ${LVM_PARTITION}
vgdisplay

lvcreate ${VGROUP} --size ${ROOT_LV_SIZE} --name root-lv
lvcreate ${VGROUP} --extents +100%FREE --name home-lv
lvdisplay

# create filesystem
mkfs.vfat -F32 "${EFI_PARTITION}"
mkfs.ext4 /dev/${VGROUP}/root-lv
mkfs.ext4 /dev/${VGROUP}/home-lv

# mounting the fs
mount "/dev/$VGROUP/root-lv" /mnt
mkdir -p /mnt/boot
mount -t vfat "${EFI_PARTITION}" /mnt/boot
mkdir -p /mnt/home
mount "/dev/$VGROUP/home-lv" /mnt/home

# bootstrap
pacstrap /mnt base base-devel

# fstab - use UUID as source identifier, -p exclude pseudofs mounts
genfstab -U -p /mnt >> /mnt/etc/fstab

# timeZone
echo ":: Setting time zone"
ln -sf /usr/share/zoneinfo/${TIMEZONE} /mnt/etc/localtime

# locale
echo ":: Setting and generating locale"
echo "${LANGUAGE}.UTF-8 UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=${LANGUAGE}.UTF-8" > /mnt/etc/locale.conf

# hidpi vconsole font
# arch-chroot /mnt pacman -S terminus-font
# echo "FONT=ter-132n" > /mnt/etc/vconsole.conf

# hostname
echo ":: Setting hostname"
echo "${HOSTNAME}" > /mnt/etc/hostname

# network
echo ":: Installing network"
arch-chroot /mnt pacman --noconfirm -S networkmanager wget
arch-chroot /mnt systemctl enable NetworkManager

# microcode
echo ":: Microcode detection"
grep -q -i "vendor_id.*intel" /proc/cpuinfo && pacstrap /mnt intel-ucode
grep -q -i "vendor_id.*amd" /proc/cpuinfo && pacstrap /mnt amd-ucode

# install essentials - at least for wifi-menu
pacstrap /mnt dialog

# initramfs
echo ":: Setting initramfs with SD & LVM"
sed -i -f "tasks/enable-initramfs-hooks-sd-lvm2/mkinitcpio.sed" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

# Boot stuff
arch-chroot /mnt bootctl install
cat <<EOF > /mnt/boot/loader/loader.conf
default arch
timeout 3
EOF

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
$(grep -i "vendor_id.*\(amd\|intel\)"  /proc/cpuinfo | head -n1 | \
    sed 's/.*\(intel\|amd\).*/\L\1/i' | \
    xargs -I {} echo -e "initrd   /{}-ucode.img")
initrd   /initramfs-linux.img
options  root=/dev/${VGROUP}/root-lv rw
EOF
