#!/bin/bash
# TODO: fold all these into task
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

# Set up logging 
exec 1> >(tee "stdout.2.log")
exec 2> >(tee "stderr.2.log")

pacstrap /mnt rsync pv vim fzf git

echo ":: System Config ..."
install -Dm0644 system-config/mod-speakerbeep.conf /mnt/etc/modprobe.d/mod-speakerbeep.conf
install -Dm0644 system-config/sysctl-net-congestion.conf /mnt/etc/sysctl.d/99-sysctl-net-congestion.conf
install -Dm0644 system-config/sysctl-swap.conf /mnt/etc/sysctl.d/99-sysctl-swap.conf

echo ":: Enable SSD trim ..."
# helpers/disk/is-ssd-trim-supported.sh /dev/sda
arch-chroot /mnt systemctl enable fstrim.timer
sed -i -f tasks/enable-ssd-trim/lvm.sed /mnt/etc/lvm/lvm.conf

echo ":: Enable systemd-swap ..."
pacstrap /mnt systemd-swap
sed -i -f tasks/enable-systemd-swap/configure.sed /mnt/etc/systemd/swap.conf
arch-chroot /mnt systemctl enable systemd-swap

# hidpi vconsole font
echo ":: HiDPI for vconsole"
pacstrap /mnt terminus-font
echo "FONT=ter-132n" > /mnt/etc/vconsole.conf

echo ":: Journald log size max ..."
# WARNING: not idempotent - need sed
echo "SystemMaxUse=100M" >> /mnt/etc/systemd/journald.conf

echo ":: Pacman contrib"
pacstrap /mnt pacman-contrib
install -Dm0644 system-config/pacmand-hooks-remove-old-cache.hook /mnt/etc/pacman.d/hooks/remove-old-cache.hook
install -Dm0644 system-config/pacmand-hooks-systemdboot.hook /mnt/etc/pacman.d/hooks/100-systemd-boot.hook
