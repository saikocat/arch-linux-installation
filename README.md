# arch-linux-installation
Installation dump

# testing with qemu
```bash
$ qemu-img create -f qcow2 install-test 5G
Formatting 'install-test', fmt=qcow2 size=5368709120 cluster_size=65536 lazy_refcounts=off refcount_bits=16
$ qemu-system-x86_64  -boot menu=on \
    -cdrom /path/archlinux-version-x86_64.iso \
    -drive file=install-test,format=qcow2 \
    -enable-kvm -machine q35,accel=kvm -device intel-iommu -cpu host -m 4028
```
