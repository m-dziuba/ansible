loadkeys pl
pacman -Sy
fdisk -l
read -p "Disk to partition: " TGTDEV
echo "\n"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
    o # clear the in memory partition table
    n # new partition
    p # primary partition
    1 # partition number 1
      # default - start at beginning of disk 
    +100M # 100 MB boot parttion
    n # new partition
    p # primary partition
    2 # partion number 2
      # default, start immediately after preceding partition
    +2G # 2 GB swap partition
    n # new partition
    p # primary partition
    3 # partion number 2
      # default, start immediately after preceding partition
      # default, extend partition to end of disk
    a # make a partition bootable
    1 # bootable partition is partition 1 -- /dev/sda1
    p # print the in-memory partition table
    w # write the partition table
EOF
mkswap ${TGTDEV}2
swapon ${TGTDEV}2
mkfs.ext4 ${TGTDEV}3
mount ${TGTDEV}3 /mnt
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
# Change root into the new system
arch-chroot /mnt /bin/bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/m-dziuba/ansible/master/in-chroot.sh)"
