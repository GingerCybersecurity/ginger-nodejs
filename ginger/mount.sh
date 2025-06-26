sudo qemu-nbd -f raw --connect /dev/nbd0 ../target/disk_image.raw
sudo qemu-nbd -f raw --connect /dev/nbd1 ../target/disk_deployment.raw
sudo qemu-nbd -f raw --connect /dev/nbd2 ../target/disk_data.raw
sudo mount /dev/nbd0p2 /mnt
sudo mount /dev/nbd1 /mnt/usr
sudo mount /dev/nbd2 /mnt/var
