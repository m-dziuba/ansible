# get opts
while getopts ":e:" opt; do
    case $opt in
        e)
            EFI_PART="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done


# Set locale
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc
sed -i "s/#en_US.UTF-8/en_US.UTF-8/g" /etc/locale.gen
sed -i "s/#pl_PL.UTF-8/en_US.UTF-8/g" /etc/locale.gen
locale-gen

# Setup GRUB
pacman -Sy
pacman -S efibootmgr grub  --noconfirm
mkdir /boot/EFI
fdisk -l
read -p "EFI partition: " EFIPART
mkdir -p /boot/EFI
mount $EFIPART /boot/EFI
grub-install --bootloader-id=GRUB --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
CPU_MANU=$(lscpu | awk '/Vendor ID:/ { if ($3 == "GenuineIntel") print "intel"; else if ($3 == "AuthenticAMD") print "amd"; else print "CPU manufacturer unknown" }')
pacman -S ${CPU_MANU}-ucode --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg

# Setup swapfile

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab

# Set username and password
echo "### Setup for $USER ###"
read -p "Username: " USER
useradd -m $USER
usermod -aG wheel $USER
passwd $USER

# Set root password
echo "### Setup for root ###"
passwd

# Set hostname
touch /etc/hostname
echo "$USER-arch" | tee -a /etc/hostname
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

pacman -S sudo git --noconfirm
git clone https://github.com/m-dziuba/ansible /home/${USER}/ansible
