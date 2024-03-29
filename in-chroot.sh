#!/usr/env/bin bash

fdisk -l
read -p "EFI partition: " EFI_PART 
read -p "Username: " USER
read -p "Password: " PASSWORD 
# Set locale
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
sed -i "s/#pl_PL.UTF-8/en_US.UTF-8/g" /etc/locale.gen
locale-gen

# Setup GRUB
pacman -Sy
pacman -S efibootmgr grub linux-headers linux-lts-headers --noconfirm --needed
mkdir -p /boot/EFI
mount $EFI_PART /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=GRUB --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
CPU_MANU=$(lscpu | awk '/Vendor ID:/ { if ($3~/GenuineIntel/) print "intel"; else if ($3~/AuthenticAMD/) print "amd" }')
pacman -S ${CPU_MANU}-ucode --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg

# Setup swapfile

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab

# Set username and password
useradd -m -s /bin/bash $USER
usermod -aG wheel $USER

echo "${USER}:${PASSWORD}" | chpasswd
echo "root:${PASSWORD}" | chpasswd

# Set hostname
rm -f /etc/hostname
touch /etc/hostname
echo "$USER-arch" | tee -a /etc/hostname
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

pacman -S sudo git networkmanager --noconfirm --needed 
systemctl enable NetworkManager.service

mkdir -p /home/${USER}/projects/ansible
git clone https://github.com/m-dziuba/ansible /home/${USER}/projects/ansible
chown -R "${USER}:${USER}" "/home/${USER}"
chmod 700 "home/${USER}"
chmod 777  "/home/${USER}/projects/ansible/install.sh"

su -c "cd /home/${USER}/projects/ansible && ./install.sh" mdziuba 

