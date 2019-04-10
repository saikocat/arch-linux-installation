#!/usr/bin/env bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# WARNING: THIS SCRIPT WILL WIPE THE ENTIRE USB FLASH DRIVE USB_DEVICE
# UEFI mode only
# This scrpit assumes you already download the iso and put in the same directory
# There is getopts but single letter opt can be arcane so force explicit value
#
# Example:
# ./000-prepare-usb-installation-media.sh 2019.04.01 sdb

VERSION=$1 # sample version 2019.04.01
USB_DRIVE=$2 # sd{x}
USB_DEVICE=/dev/${USB_DRIVE}
ISO_FILE=archlinux-${VERSION}-x86_64.iso

# Sanity check for presence of iso file and block device
ls -l ${ISO_FILE}
# --output columns: [name, removable, type] --raw --noheadings --nodeps (not
# printing partitions)
lsblk -o NAME,RM,TYPE -rnd | grep "${USB_DRIVE} 1 disk"

# # Verifying signature
echo ":: Verifying ISO signature..."
wget -c https://www.archlinux.org/iso/${VERSION}/archlinux-${VERSION}-x86_64.iso.sig
gpg --keyserver-options auto-key-retrieve --verify archlinux-${VERSION}-x86_64.iso.sig
pacman-key -v $ISO_FILE.sig

echo ":: Preparing USB installation media..."
echo "== writing into ${USB_DEVICE} ..."
sudo dd bs=4M if=${ISO_FILE} of=${USB_DEVICE} status=progress oflag=sync

echo ":: Done"
