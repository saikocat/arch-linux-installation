#!/usr/bin/env bash
### WARNING: UNTESTED ###
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

DISK=$1
TIMEZONE="Asia/Singapore"
HOSTNAME="shingetsu"

# Update system clock to ensure accuracy
timedatectl set-ntp true

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

lvcreate ${VGROUP} --size 64G --name root-lv
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
# microcode
grep -q -i "vendor_id.*intel" /proc/cpuinfo && pacstrap /mnt intel-ucode
grep -q -i "vendor_id.*amd" /proc/cpuinfo && pacstrap /mnt amd-ucode

# Use PARTUUID as source identifier, -p exclude pseudofs mounts
genfstab -t PARTUUID -p /mnt >> /mnt/etc/fstab
# Boot stuff
arch-chroot /mnt bootctl install
cat <<EOF > /mnt/boot/loader/loader.conf
default arch
EOF

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
$(grep -i "vendor_id.*\(amd\|intel\)"  /proc/cpuinfo | head -n1 | \
    sed 's/.*\(intel\|amd\).*/\L\1/i' | \
    xargs -I {} echo -e "initrd   /{}-ucode.img")
initrd   /initramfs-linux.img
options  root=PARTUUID=$(blkid -s PARTUUID -o value "${LVM_PARTITION}") rw
EOF

# LVM
sed -i -f "tasks/enable-initramfs-hooks-sd-lvm2/mkinitcpio.sed" /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

# Locale
cat >>"/mnt/etc/locale.gen" <<EOF
en_SG.UTF-8 UTF-8
EOF

arch-chroot /mnt/ locale-gen

# cat >"/mnt/root/default-environment" <<EOF
# HOSTNAME=${HOSTNAME}
# TIMEZONE=${TIMEZONE}
# EOF
# 
# SYSTEMD_START_FILE="/mnt/etc/systemd/system/multi-user.target.wants/init-system.service"
# cat >"$SYSTEMD_START_FILE" <<EOF
# [Service]
# Type=oneshot
# EnvironmentFile=/root/default-environment
# ExecStart=/usr/bin/localectl set-locale LANG=en_SG.UTF-8
# ExecStart=/usr/bin/hostnamectl set-hostname $HOSTNAME
# ExecStart=/usr/bin/timedatectl set-ntp 1
# ExecStart=/usr/bin/timedatectl set-timezone $TIMEZONE
# ExecStart=/bin/systemctl poweroff
# EOF
# 
# systemd-nspawn -D /mnt -b
# rm "$SYSTEMD_START_FILE"
