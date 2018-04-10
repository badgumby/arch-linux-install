#!/bin/bash
###############################################################
###############################################################
######## Install ARCH Linux with encrypted file-system ########
########           Options for EFI or BIOS             ########
########            Modified by BAD Gumby              ########
###############################################################
###############################################################

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color

echo -e ${BLUE}${BOLD}
echo -e '________  ________  ________          ________  ___  ___  _____ ______   ________      ___    ___ ________      '
echo -e '|\   __  \|\   __  \|\   ___ \        |\   ____\|\  \|\  \|\   _ \  _   \|\   __  \    |\  \  /  /|\   ____\    '
echo -e '\ \   __  \ \   __  \ \  \ \\ \       \ \  \  __\ \  \\\  \ \  \\|__| \  \ \   __  \   \ \    / / \ \_____  \   '
echo -e ' \ \  \|\  \ \  \ \  \ \  \_\\ \       \ \  \|\  \ \  \\\  \ \  \    \ \  \ \  \|\  \   \/  /  /   \|____|\  \  '
echo -e '  \ \_______\ \__\ \__\ \_______\       \ \_______\ \_______\ \__\    \ \__\ \_______\__/  / /       ____\_\  \ '
echo -e '   \|_______|\|__|\|__|\|_______|        \|_______|\|_______|\|__|     \|__|\|_______|\___/ /       |\_________\'
echo -e '                                                                                     \|___|/        \|_________|'
echo -e ' _______             __         _______               __          __ __             '
echo -e '|   _   |.----.----.|  |--.    |_     _|.-----.-----.|  |_.---.-.|  |  |.-----.----.'
echo -e '|       ||   _|  __||     |     _|   |_ |     |__ --||   _|  _  ||  |  ||  -__|   _|'
echo -e '|___|___||__| |____||__|__|    |_______||__|__|_____||____|___._||__|__||_____|__|  '
echo -e ${NC}${NB}

# Download the archiso image from https://www.archlinux.org/
# Copy to a usb-drive on linux
# dd if=archlinux.img of=/dev/sdX bs=16M && sync
# Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.

# This assumes a wifi only system...
# wifi-menu

echo -e ${BLUE}$drawline
echo -e "Creating partitions"
echo -e "${RED}WARNING:${BLUE} You are about to format your drive. Press CTRL+C to quit. Enter to continue."
echo -e $drawline${NC}
read warning

echo -e ${BLUE}$drawline
echo -e "List of storage devices"
echo -e $drawline${NC}
fdisk -l

echo -e ${BLUE}$drawline
echo -e "What device should we partition? (ex. /dev/sda)"
echo -e $drawline${NC}
read storagedevice
sgdisk -Z $storagedevice
sgdisk -n 0:0:+200M -t 0:ef00 -c 0:"efi_boot" $storagedevice
sgdisk -n 0:0:+500M -t 0:8300 -c 0:"linux_boot" $storagedevice
sgdisk -n 0:0:0 -t 0:8300 -c 0:"data" $storagedevice

echo -e ${BLUE}$drawline
echo -e "Printing written partitions..."
echo -e $drawline${NC}
sgdisk -p $storagedevice

echo -e ${BLUE}$drawline
echo -e "Informing OS of changes..."
echo -e $drawline${NC}
partprobe $storagedevice
fdisk -l $storagedevice

#############################################################################
# OLD - DO NOT USE
#############################################################################
#cgdisk /dev/sdX
# For EFI, use this
# 1 100MB EFI partition  # Hex code ef00
# 2 500MB Boot partition # Hex code 8300
# 3 100% size partiton   # Hex code 8300 (to be encrypted)

# For BIOS, use this
# 1 100MB BIOS partition # Hex code ef02
# 2 500MB Boot partition # Hex code 8300
# 3 100% size partiton   # Hex code 8300 (to be encrypted)
#############################################################################

echo "Creating file systems on the EFI/BIOS and boot partitions..."
mkfs.vfat -F32 ${storagedevice}1
mkfs.ext2 ${storagedevice}2

echo "Setting up the encryption of the system..."
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat ${storagedevice}3
cryptsetup luksOpen ${storagedevice}3 luks

echo "Creating encrypted partitions..."
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 8G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root

echo "Creating filesystems on encrypted partitions..."
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap

echo "Mounting the new system..."
mount /dev/mapper/vg0-root /mnt # /mnt is the installed system
swapon /dev/mapper/vg0-swap # Not needed but a good thing to test
mkdir /mnt/boot
mount ${storagedevice}2 /mnt/boot
mkdir /mnt/boot/efi
mount ${storagedevice}1 /mnt/boot/efi

##########################################################################################################################################################
# For EFI, use this
pacstrap /mnt base base-devel grub-efi-x86_64 efibootmgr zsh vim git dialog wpa_supplicant xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils

# For BIOS, instead of EFI use this
pacstrap /mnt base base-devel grub-bios zsh vim git dialog wpa_supplicant xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils
##########################################################################################################################################################

echo -e ${BLUE}$drawline
echo "Writing current fstab to file /etc/fstab"
echo -e $drawline${NC}
genfstab -pU /mnt >> /mnt/etc/fstab

echo -e ${BLUE}$drawline
echo -e "Making /tmp a ramdisk (adding tmpfs to /etc/fstab)"
echo -e $drawline${NC}
echo 'tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0' >> /mnt/etc/fstab
# Change relatime on all non-boot partitions to noatime (reduces wear if using an SSD)

echo -e ${BLUE}$drawline
echo -e "Entering the new system..."
echo -e $drawline${NC}
arch-chroot /mnt /bin/bash

echo -e ${BLUE}$drawline
echo -e "Setup system clock with local timezone (ex. America/Chicago): "
echo -e $drawline${NC}
read MYTIMEZONE
rm /etc/localtime
ln -s /usr/share/zoneinfo/$MYTIMEZONE /etc/localtime
hwclock --systohc --utc

echo -e ${BLUE}$drawline
echo -e "Enter a computer hostname:"
echo -e $drawline${NC}
read MYHOSTNAME
echo $MYHOSTNAME > /etc/hostname

echo -e ${BLUE}$drawline
echo -e "Enabling en_US.UTF-8 locale"
echo -e $drawline${NC}
sed -i 's:#en_US.UTF-8 UTF-8:en_US.UTF-8 UTF-8:g' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo LANGUAGE=en_US.UTF-8 >> /etc/locale.conf
echo LC_ALL=en_US.UTF-8 >> /etc/locale.conf

echo -e ${BLUE}$drawline
echo -e "Please enter a password for ${RED}'root'${BLUE}:"
echo -e $drawline${NC}
passwd

echo -e ${BLUE}$drawline
echo -e "Please enter your username (user will be in ${RED}wheel${BLUE} group):"
echo -e $drawline${NC}
read MYUSERNAME

echo -e ${BLUE}$drawline
echo -e "Please enter your default shell (options: ${RED}/bin/bash${BLUE} or ${RED}/bin/zsh)${BLUE}:"
echo -e $drawline${NC}
read MYSHELL
useradd -m -g users -G wheel -s $MYSHELL $MYUSERNAME
passwd $MYUSERNAME

# Configure mkinitcpio with modules needed for the initrd image
vim /etc/mkinitcpio.conf
# Add 'ext4' to MODULES
# Add 'encrypt' and 'lvm2' to HOOKS before filesystems
# Move 'keyboard' before encrypt in HOOKS

# Regenerate initrd image
mkinitcpio -p linux

# Setup grub
grub-install
# In /etc/default/grub edit the line GRUB_CMDLINE_LINUX to
GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX3:luks:allow-discards"
# then run
grub-mkconfig -o /boot/grub/grub.cfg

# Enable desired services
systemctl enable gdm
systemctl enable bluetooth
systemctl enable NetworkManager

# Exit new system and go into the cd shell
exit

# Unmount all partitions
umount -R /mnt
swapoff -a

# Reboot into the new system, don't forget to remove the cd/usb
reboot

##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################

# Initialize pacman keys
pacman-key --init
pacman-key --populate archlinux

# Install aura (Arch User Repository package manager)
# Pull down the aura package.
git clone https://aur.archlinux.org/aura-bin.git
# Change into the aura directory and make the package with all it’s dependencies.
cd aura-bin
makepkg -s
# When that is done, simply install the locally built package (version as of this build).
sudo pacman -U aura-bin-1.4.0-1-x86_64.pkg.tar.xz

##########################################################################################################################################################
# If on System76 machine, install this first
sudo aura -Ax system76-driver system76-dkms-git system76-wallpapers

# Install from Official Repo
sudo aura -Sx intel-ucode mate-media system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba

# Install from AUR
sudo aura -Ax mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git aic94xx-firmware wd719x-firmware remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin zoom multibootusb skype-electron

# Install themes/fonts
sudo aura -Ax ant-nebula-gtk-theme candy-gtk-themes paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts typecatcher

##########################################################################################################################################################
