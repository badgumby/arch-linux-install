#!/bin/bash
#Line separator variable

# Download the archiso image from https://www.archlinux.org/
# Copy to a usb-drive on linux
# dd if=archlinux.img of=/dev/sdX bs=16M && sync
# Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.

# This assumes a wifi only system...
# wifi-menu

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

# Functions for system selection
function efi_install {
  echo -e ${BLUE}$drawline
  echo -e "Installing packages for EFI system"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-efi-x86_64 efibootmgr zsh vim git dialog wpa_supplicant xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils
}

function bios_install {
  echo -e ${BLUE}$drawline
  echo -e "Installing packages for BIOS"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-bios zsh vim git dialog wpa_supplicant xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils
}

echo -e ${BLUE}$drawline
echo -e "Creating partitions"
echo -e "${RED}WARNING:${BLUE} You are about to format your drive. Press CTRL+C to quit. Press ENTER to continue."
echo -e $drawline${NC}
read WARNING

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

echo -e ${BLUE}$drawline
echo -e "Creating file systems on the EFI/BIOS and boot partitions..."
echo -e $drawline${NC}
mkfs.vfat -F32 ${storagedevice}1
mkfs.ext2 ${storagedevice}2

echo -e ${BLUE}$drawline
echo -e "Setting up the encryption of the system..."
echo -e $drawline${NC}
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat ${storagedevice}3
cryptsetup luksOpen ${storagedevice}3 luks

echo -e ${BLUE}$drawline
echo -e "Creating encrypted partitions..."
echo -e $drawline${NC}
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 8G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root

echo -e ${BLUE}$drawline
echo -e "Creating filesystems on encrypted partitions..."
echo -e $drawline${NC}
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap

echo -e ${BLUE}$drawline
echo -e "Mounting the new system..."
echo -e $drawline${NC}
mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap
mkdir /mnt/boot
mount ${storagedevice}2 /mnt/boot
mkdir /mnt/boot/efi
mount ${storagedevice}1 /mnt/boot/efi

options=("EFI System" "BIOS")
echo ""
echo -e "${BLUE}${BOLD}Choose your system type: ${NB}${NC}"
select opt in "${options[@]}"; do
case $REPLY in
  1) efi_install; break ;;
  2) bios_install; break ;;
  *) clear; echo -e "${RED}Invalid option selected. Please try again.${NC}"; break ;;
  esac
done

echo -e ${BLUE}$drawline
echo "Writing current fstab to file /mnt/etc/fstab"
echo -e $drawline${NC}
genfstab -pU /mnt >> /mnt/etc/fstab

echo -e ${BLUE}$drawline
echo -e "Making /tmp a ramdisk (adding tmpfs to /mnt/etc/fstab)"
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

##############################################################################################################
##### MODULES in mkinitcpio
##############################################################################################################
echo -e ${BLUE}$drawline
echo -e "Configure mkinitcpio with ${RED}MODULES${BLUE} needed for the initrd image"
echo -e "Default: (ext4)"
BASEMODULES='ext4'
read -r -p "Do you need additional MODULES? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "Please enter MODULES, separated by spaces. None will be configured by default:${NC}"
    read MYMODULES
    sed -i '/^MODULES=/c\MODULES=('"${MYMODULES}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following MODULES have been added: ${RED}${MODULES} ${MYMODULES}${BLUE}"
    read -p "ENTER to continue..."
  else
    echo -e "Using default MODULES"
    sed -i '/^MODULES=/c\MODULES=('"${BASEMODULES}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following MODULES have been added: ${RED}${BASEMODULES}${BLUE}"
    read -p "ENTER to continue..."
fi
echo -e $drawline${NC}

##############################################################################################################
##### HOOKS in mkinitcpio
##############################################################################################################
echo -e ${BLUE}$drawline
echo -e "Configure mkinitcpio with ${RED}HOOKS${BLUE} needed for the initrd image"
echo -e "Default: (base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)"
BASEHOOKS='base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck'
read -r -p "Do you need other HOOKS? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "Please enter HOOKS, separated by spaces. None will be configured by default:${NC}"
    read MYHOOKS
    sed -i '/^HOOKS=/c\HOOKS=('"${MYHOOKS}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following HOOKS have been added: ${RED}${BASEHOOKS} ${MYHOOKS}${BLUE}"
    read -p "ENTER to continue..."
  else
    echo -e "Using default HOOKS"
    sed -i '/^HOOKS=/c\HOOKS=('"${BASEHOOKS}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following HOOKS have been added: ${RED}${BASEHOOKS}${BLUE}"
    read -p "ENTER to continue..."
fi
echo -e $drawline${NC}

echo -e ${BLUE}$drawline
echo -e "Regenerating the initrd image..."
echo -e $drawline${NC}
mkinitcpio -p linux

echo -e ${BLUE}$drawline
echo -e "Setting up grub..."
echo -e $drawline${NC}
grub-install

echo -e ${BLUE}$drawline
echo -e "Modifying grub file to select encrypted partition..."
echo -e $drawline${NC}
sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cryptdevice='${storagedevice}'3:luks:allow-discards"'  /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo -e ${BLUE}$drawline
echo -e "Enabling gdm, bluetooth, and NetworkManager..."
echo -e $drawline${NC}
systemctl enable gdm
systemctl enable bluetooth
systemctl enable NetworkManager

echo -e ${BLUE}$drawline
echo -e "Are you ready to reboot? Press ENTER to continue, CTRL+C to stay in chroot."
echo -e $drawline${NC}
read MYREBOOT

echo -e ${BLUE}$drawline
echo -e "Exiting chroot..."
echo -e $drawline${NC}
exit

echo -e ${BLUE}$drawline
echo -e "Unmounting all partitions..."
echo -e $drawline${NC}
umount -R /mnt
swapoff -a

echo -e ${BLUE}$drawline
echo -e "Initiating reboot..."
echo -e $drawline${NC}
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
