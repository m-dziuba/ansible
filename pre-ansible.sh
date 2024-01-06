loadkeys pl
timedatectl set-ntp true
passwd
pacman -Sy

fdisk -l
read -p "Disk to partition: " TGTDEV
read -p "Partition suffix: " PART_SUFFIX
read -p "EFI partition size: " EFI_SIZE
read -p "root partition size: " ROOT_SIZE

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
    g # create new partition table
    n # new partition
    1 # partition number 1
      # default - start at beginning of disk 
    +${EFI_SIZE} # EFI_SIZE MB boot parttion
    t # change partition type to EFI
    1 # pick partition 1
    w # save
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
    n # new partition
    2 # partion number 2
      # default, start immediately after preceding partition
    +${ROOT_SIZE} # ROOT_SIZE GB root partition
    w # save
EOF
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
    n # new partition
    3 # partion number 2
      # default, start immediately after preceding partition
      # default, extend partition to end of disk
    p # print the in-memory partion table
    w # write the partition table
EOF

mkfs.fat -F 32 ${TGTDEV}${PART_SUFFIX}1
mkfs.ext4 ${TGTDEV}${PART_SUFFIX}2
mkfs.ext4 ${TGTDEV}${PART_SUFFIX}3
mount ${TGTDEV}${PART_SUFFIX}2 /mnt
mkdir /mnt/home
mount ${TGTDEV}${PART_SUFFIX}2 /mnt/home
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# Change root into the new system
arch-chroot /mnt  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/m-dziuba/ansible/master/in-chroot.sh)"
