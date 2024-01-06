# get opts
while getopts ":e:p:u:" opt; do
    case $opt in
        e)
            EFI_PART="$OPTARG"
            ;;
        p)
            PASSWORD="$OPTARG"
            ;;
        u)
            USER="$OPTARG"
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
pacman -S efibootmgr grub linux-headers linux-lts-headers --noconfirm
mkdir -p /boot/EFI
mount $EFI_PART /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=GRUB --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
CPU_MANU=$(lscpu | awk '/Vendor ID:/ { if ($3 == "GenuineIntel ID") print "intel"; else if ($3 == "AuthenticAMD") print "amd"; else print "CPU manufacturer unknown" }')
pacman -S ${CPU_MANU}-ucode --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg

# Setup swapfile

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo "/swapfile none swap sw 0 0" | tee -a /etc/fstab

# Set username and password
useradd -m -s /bin/bash $USER
chown -R "${USER}:${USER}" "/home/${USER}"
chmod 700 "home/{$USER}"
usermod -aG wheel $USER

echo "${USER}:${PASSWORD}" | chpasswd
echo "root:${PASSWORD}" | chpasswd

# Set hostname
rm /etc/hostname
touch /etc/hostname
echo "$USER-arch" | tee -a /etc/hostname
echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

pacman -S sudo git networkmanager --noconfirm
git clone https://github.com/m-dziuba/ansible /home/${USER}/ansible
chown -R "${USER}:${USER}" "/home/${USER}/ansible"
exit
