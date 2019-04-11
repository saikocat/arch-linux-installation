#!/usr/bin/env sed -f
s/\(HOOKS=(base .*\)udev/\1systemd/
s/\( block\)\( \| sd-lvm2 \| lvm2 \)*\(filesystems\)/\1 sd-lvm2 \3/
