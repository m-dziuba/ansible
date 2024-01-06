# Set locale
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
rm /etc/locale.gen
touch /etc/locale.gen
echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen
echo "pl_PL.UTF-8 UTF-8" | tee -a /etc/locale.gen
# Set username and password
read -p "Username: " USER
read -sp "User password: " USERPWD
useradd -m $USER
usermod -aG wheel $USER
echo $USER:$USERPWD | chpasswd 
USERPWD=""
# Set hostname
touch /etc/hostname
echo "$USER-Arch" | tee -a /etc/hostname
# Set password
read -sp "Root password: " ROOTPWD
echo root:$ROOTPWD | chpasswd 
ROOTPWD=""
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

pacman -Sy

fdisk -l
read -p "EFI partition: " EFIPART
mount $EFIPART /efi
pacman -S efibootmgr grub amd-ucode
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_56-efi --efi-directory=/efi --bootloader-id=GRUB

pacman -S sudo git curl ansible
