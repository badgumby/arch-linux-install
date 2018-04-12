#!/bin/bash

# 1. Download the archiso image from https://www.archlinux.org/
# 2. Copy to a usb-drive on linux
#    dd if=archlinux.img of=/dev/sdX bs=16M && sync
# 3. Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.
# 4. Setup network connections
#    systemctl enable dhcpcd@eth0.service
#    For WiFi only system, use wifi-menu
# 5. Execute this script:
#    bash <(curl -s --tlsv1.2 --insecure --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color
clear

# http://http://patorjk.com/software/taag/
# Fonts: ANSI Shadow (optional: 3D-Ascii + Chunky)
echo -e ${BLUE}
echo '      ██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗███╗   ███╗██████╗ ██╗   ██╗███████╗       '
echo '      ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║████╗ ████║██╔══██╗╚██╗ ██╔╝██╔════╝       '
echo '      ██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║██╔████╔██║██████╔╝ ╚████╔╝ ███████╗       '
echo '      ██╔══██╗██╔══██║██║  ██║    ██║   ██║██║   ██║██║╚██╔╝██║██╔══██╗  ╚██╔╝  ╚════██║       '
echo '      ██████╔╝██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝   ██║   ███████║       '
echo '      ╚═════╝ ╚═╝  ╚═╝╚═════╝      ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝    ╚═╝   ╚══════╝       '
echo ' █████╗ ██████╗  ██████╗██╗  ██╗      ███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ '
echo '██╔══██╗██╔══██╗██╔════╝██║  ██║      ██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗'
echo '███████║██████╔╝██║     ███████║█████╗███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝'
echo '██╔══██║██╔══██╗██║     ██╔══██║╚════╝╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗'
echo '██║  ██║██║  ██║╚██████╗██║  ██║      ███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║'
echo '╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝      ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝'
echo -e ${NC}

##############################################################################################################
##### Functions for system selection
##############################################################################################################

function efi_install {
  echo -e ${BLUE}$drawline
  echo -e "Installing packages for EFI system"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-efi-x86_64 efibootmgr zsh vim wget git dialog wpa_supplicant reflector
}

function bios_install {
  echo -e ${BLUE}$drawline
  echo -e "Installing packages for BIOS"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-bios zsh vim wget git dialog wpa_supplicant reflector
}

function pacman-key-init {
  echo -e ${BLUE}$drawline
  echo -e "Initializing pacman-key..."
  echo -e $drawline${NC}
  pacman-key --init
  pacman-key --populate archlinux
  base-install-packages
}

##############################################################################################################
##### Creating partitions
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "${RED}WARNING: BAD Gumby's Arch installer is destructive."
echo -e "${RED}The first step will format your drive! Be sure to backup your data before running, if necessary."
echo -e "${RED}If you ran this by mistake, please quit now!"
echo -e "${RED}${BOLD}Press CTRL+C to quit. Press ENTER to continue.${NB}${BLUE}"
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

echo -e ${BLUE}$drawline
echo -e "${RED}WARNING: You are about to format the device ${BLUE}${storagedevice}${RED}. Press CTRL+C to quit. Press ENTER to continue."
echo -e "${RED}This is your last chance to exit before you wipe your drive!${BLUE}"
echo -e $drawline${NC}
read WARNING2

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

##############################################################################################################
##### Creating file systems / encrypting partitions
##############################################################################################################

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

##############################################################################################################
##### Install base Arch packages with pacstrap / select EFI or BIOS
##############################################################################################################

options=("EFI System" "BIOS")
echo ""
echo -e "${BLUE}Choose your system type: ${NC}"
select opt in "${options[@]}"; do
case $REPLY in
  1) efi_install; break ;;
  2) bios_install; break ;;
  *) clear; echo -e "${RED}Invalid option selected. Please try again.${NC}"; break ;;
  esac
done

##############################################################################################################
##### Build /etc/fstab
##############################################################################################################

echo -e ${BLUE}$drawline
echo "Writing current fstab to file /mnt/etc/fstab"
echo -e $drawline${NC}
genfstab -pU /mnt >> /mnt/etc/fstab

echo -e ${BLUE}$drawline
echo -e "Making /tmp a ramdisk (adding tmpfs to /mnt/etc/fstab)"
echo -e $drawline${NC}
echo 'tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0' >> /mnt/etc/fstab
# Change relatime on all non-boot partitions to noatime (reduces wear if using an SSD)

##############################################################################################################
##### Enter arch-chroot
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Entering the new system..."
echo -e $drawline${NC}
curl -o /mnt/root/arch-install-gumby-2.sh -s --tlsv1.2 --insecure --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh"
chmod +x /mnt/root/arch-install-gumby2.sh
arch-chroot /mnt /bin/bash /root/arch-install-gumby-2.sh

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##### Configure timezone / hostname / locale
##############################################################################################################

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

##############################################################################################################
##### Configure root user / allow wheel in sudoers file / add new user
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Please enter a password for ${RED}'root'${BLUE}:"
echo -e $drawline${NC}
passwd

sed -i '/%wheel ALL=(ALL) ALL/c\%wheel ALL=(ALL) ALL'  /etc/sudoers

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
read -r -p "Would you like to customize your MODULES? [y/n]: " response
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
##### BINARIES in mkinitcpio
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Configure mkinitcpio with ${RED}BINARIES${BLUE} needed for the initrd image"
echo -e "Default: (*none*)"
read -r -p "Would you like to customize your BINARIES? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "Please enter BINARIES, separated by spaces. None will be configured by default:${NC}"
    read MYBINARIES
    sed -i '/^BINARIES=/c\BINARIES=('"${MYBINARIES}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following BINARIES have been added: ${RED}${MYBINARIES}${BLUE}"
    read -p "ENTER to continue..."
  else
    echo -e "${BLUE}The there are no default BINARIES to configure."
    read -p "ENTER to continue..."
fi
echo -e $drawline${NC}

##############################################################################################################
##### FILES in mkinitcpio
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Configure mkinitcpio with ${RED}FILES${BLUE} needed for the initrd image"
echo -e "Default: (*none*)"
read -r -p "Would you like to customize your FILES? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "Please enter FILES, separated by spaces. None will be configured by default:${NC}"
    read MYFILES
    sed -i '/^FILES=/c\FILES=('"${MYFILES}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following FILES have been added: ${RED}${MYFILES}${BLUE}"
    read -p "ENTER to continue..."
  else
    echo -e "${BLUE}The there are no default FILES to configure."
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
read -r -p "Would you like to customize your HOOKS? [y/n]: " response
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

##############################################################################################################
##### Regenerate initrd
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Regenerating the initrd image..."
echo -e $drawline${NC}
mkinitcpio -p linux

##############################################################################################################
##### Install/Configure GRUB
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Setting up GRUB..."
echo -e $drawline${NC}
grub-install

echo -e ${BLUE}$drawline
echo -e "Modifying GRUB file to select encrypted partition..."
echo -e $drawline${NC}
sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cryptdevice='${storagedevice}'3:luks:allow-discards"'  /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

##############################################################################################################
##### Install AUR Helper (Aura)
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Installing aura (Arch User Repository package manager)"
echo -e $drawline${NC}
# Pull down the aura PKGBUILD.
mkdir /root/aura-bin
cd /root/aura-bin
wget --no-check-certificate https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD\?h\=aura-bin --output-document=./PKGBUILD
makepkg -si

##############################################################################################################
##### Update /etc/pacman.d/mirrorlist using Reflector
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Updating /etc/pacman.d/mirrorlist using Reflector"
echo -e "Selecting HTTPS mirrors, synchronized within the last 12 hours, located in country, and sorted by download speed."
echo -e "Full list of countries can be found at ${RED}https://archlinux.org/mirrors/status/${BLUE}"
echo -e "Please enter your preferred country (for US, enter: United States)"
echo -e $drawline${NC}
read MYCOUNTRY

reflector --country "${MYCOUNTRY}" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist

##############################################################################################################
##### Install common packages from Official Repo
##############################################################################################################

function base-install-packages {
  BASEINSTALL="xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils intel-ucode mate-media system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba"

  echo -e ${BLUE}$drawline
  echo -e "BAD Gumby's base packages from the Official Arch Repo"
  echo -e "Default: (xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils intel-ucode mate-media system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba)"
  echo -e ""
  read -r -p "Would you like to customize your PACKAGES? [y/n]: " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
      echo -e ""
      echo -e "Please enter PACKAGES, separated by spaces. None of the default packages will be installed:${NC}"
      read MYPACKAGES
      pacman -S ${MYPACKAGES}
      read -p "ENTER to continue..."
    else
      echo -e ""
      echo -e "Using BAD Gumby's base packages..."
      pacman -S ${BASEINSTALL}
      systemctl enable gdm
      systemctl enable bluetooth
      systemctl enable NetworkManager
      read -p "ENTER to continue..."
  fi
  echo -e $drawline${NC}
}
# Execute install function
base-install-packages

# Ask if pacman had issues with key
read -r -p "Did pacman have signature errors when attempting to install packages? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    pacman-key-init
  else
    echo -e "No issues. Skipping..."
fi

##############################################################################################################
##### Switching user for AUR package installations
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Switching to created user, ${RED}${MYUSERNAME}${BLUE}, for AUR package installs"
echo -e $drawline${NC}
su $MYUSERNAME

##############################################################################################################
##### System76 drivers
##############################################################################################################

76INSTALL="system76-driver system76-dkms-git system76-wallpapers"

echo -e ${BLUE}$drawline
echo -e "Packages for System76 computers"
echo -e "Default: (system76-driver system76-dkms-git system76-wallpapers)"
echo -e ""
read -r -p "Is this a System76 computer? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "Installing System76 drivers${NC}"
    sudo aura -Ax ${76INSTALL}
    read -p "ENTER to continue..."
  else
    echo -e ""
    echo -e "Not a System76 computer. Skipping..."
fi
echo -e $drawline${NC}

##############################################################################################################
##### Install packages for AUR
##############################################################################################################

AURINSTALL="mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin zoom multibootusb skype-electron"

echo -e ${BLUE}$drawline
echo -e "BAD Gumby's packages from the Arch User Repository"
echo -e "Default: (mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin zoom multibootusb skype-electron)"
echo -e ""
read -r -p "Would you like to customize your AUR PACKAGES? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "Please enter AUR PACKAGES, separated by spaces. None of the default AUR packages will be installed:${NC}"
    read MYAUR
    sudo aura -Ax ${MYAUR}
    read -p "ENTER to continue..."
  else
    echo -e ""
    echo -e "Using BAD Gumby's AUR packages..."
    sudo aura -Ax ${AURINSTALL}
    read -p "ENTER to continue..."
fi
echo -e $drawline${NC}

##############################################################################################################
##### BAD Gumby's favorite themes
##############################################################################################################

THEMEINSTALL="ant-nebula-gtk-theme candy-gtk-themes paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts typecatcher"

echo -e ${BLUE}$drawline
echo -e "BAD Gumby's favorite themes"
echo -e "Default: (ant-nebula-gtk-theme candy-gtk-themes paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts typecatcher)"
echo -e ""
read -r -p "Would you like to install BAD Gumby's favorite themes? [y/n]: " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "Installing BAD Gumby's favorite themes${NC}"
    sudo aura -Ax ${THEMEINSTALL}
    read -p "ENTER to continue..."
  else
    echo -e ""
    echo -e "Not installing themes. Skipping..."
fi
echo -e $drawline${NC}

##############################################################################################################
##### Finished with initial setup, time to reboot
##############################################################################################################

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
echo -e "Please remember to remove installation media."
echo -e $drawline${NC}
reboot

##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
