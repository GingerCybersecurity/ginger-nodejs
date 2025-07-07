sudo umount /mnt/var
sudo umount /mnt/usr
sudo umount /mnt
sudo qemu-nbd --disconnect /dev/nbd2
sudo qemu-nbd --disconnect /dev/nbd1
sudo qemu-nbd --disconnect /dev/nbd0
