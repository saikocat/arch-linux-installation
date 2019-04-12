#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.999.log")
exec 2> >(tee "stderr.999.log")

pacstrap /mnt acpi_call powertop tlp tlp-rdw
install -Dm0644 system-config/mod-thinkpad-acpi.conf /mnt/etc/modprobe.d/thinkpad-acpi.conf

arch-chroot /mnt systemctl enable NetworkManager-dispatcher.service
arch-chroot /mnt systemctl enable tlp.service
arch-chroot /mnt systemctl enable tlp-sleep.service
arch-chroot /mnt systemctl disable systemd-rfkill.service
arch-chroot /mnt systemctl mask systemd-rfkill.service
arch-chroot /mnt systemctl mask systemd-rfkill.socket

sed -i '/START_CHARGE_THRESH_BAT0=/s/^#//g' /mnt/etc/default/tlp
sed -i '/STOP_CHARGE_THRESH_BAT0=/s/^#//g'  /mnt/etc/default/tlp
