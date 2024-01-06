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

pacman -Sy
pacman -S sudo git curl ansible
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
# su $USER
cd ~/
