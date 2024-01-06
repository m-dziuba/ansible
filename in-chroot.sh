# Set locale
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
sed -i "s/#pl_PL.UTF-8/en_US.UTF-8/g" /etc/locale.gen
locale-gen

# Setup GRUB
pacman -Sy
pacman -S efibootmgr grub 
mkdir /boot/EFI
fdisk -l
read -p "EFI partition: " EFIPART
mkdir /boot/EFI
mount $EFIPART /boot/EFI
grub-install --target=x86_56-efi --bootloader-id=GRUB --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
read -p "CPU amd or intel: " CPU_MANU
pacman -S ${CPU_MANU}-ucode
grub-mkconfig -o /boot/grub/grub.cfg

# Setup swapfile

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab

# Set username and password
read -p "Username: " USER
useradd -m $USER
usermod -aG wheel $USER
echo "### Setup for $USER ###"
passwd $USER

# Set root password
echo "### Setup for $USER ###"
passwd

# Set hostname
touch /etc/hostname
echo "$USER-Arch" | tee -a /etc/hostname
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers


pacman -S sudo git curl ansible
