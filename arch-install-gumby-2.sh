#!/bin/bash

# 1. Run part 1 first.
# 2. Execute this script:
#    bash <(curl -s --tlsv1.2 --insecure --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby-2.sh")

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

function pacman-key-init {
  echo -e ${BLUE}$drawline
  echo -e "Initializing pacman-key..."
  echo -e $drawline${NC}
  pacman-key --init
  pacman-key --populate archlinux
  base-install-packages
}

##############################################################################################################
##### Initial Message
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "${RED}WARNING: This is BAD Gumby's Arch installer - Part 2."
echo -e "${RED}If you haven't already, please run Part 1 first."
echo -e "${RED}If you ran this by mistake, please quit now!"
echo -e "${RED}${BOLD}Press CTRL+C to quit. Press ENTER to continue.${NB}${BLUE}"
echo -e $drawline${NC}
read WARNING

##############################################################################################################
##### Configure timezone / hostname / locale
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Please enter system clock with local timezone (ex. America/Chicago): "
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
  else
    echo -e "${NC}Using default MODULES"
    sed -i '/^MODULES=/c\MODULES=('"${BASEMODULES}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following MODULES have been added: ${RED}${BASEMODULES}${BLUE}"
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
  else
    echo -e "${NC}The there are no default BINARIES to configure.${BLUE}"
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
  else
    echo -e "${NC}The there are no default FILES to configure.${BLUE}"
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
  else
    echo -e "${NC}Using default HOOKS"
    sed -i '/^HOOKS=/c\HOOKS=('"${BASEHOOKS}"')' /etc/mkinitcpio.conf
    echo -e "${BLUE}The following HOOKS have been added: ${RED}${BASEHOOKS}${BLUE}"
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
echo -e "Is the swap partition mounted?${NC}"
sudo fdisk -l
echo -e ${BLUE}$drawline${NC}
read HOLDUP

echo -e ${BLUE}$drawline
echo -e "Setting up GRUB..."
echo -e $drawline${NC}
grub-install

echo -e ${BLUE}$drawline
echo -e "Modifying GRUB file to select encrypted partition..."
echo -e $drawline${NC}
sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cryptdevice='${storagedevice}'3:luks:allow-discards"' /etc/default/grub
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX=
echo 'Verify above line shows: GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX3:luks:allow-discards"'
read HOLDUPHEY
grub-mkconfig -o /boot/grub/grub.cfg

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
  BASEINSTALL="xf86-video-intel xorg-server gdm mate bluez-utils intel-ucode system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba"

  echo -e ${BLUE}$drawline
  echo -e "BAD Gumby's base packages from the Official Arch Repo"
  echo -e "Default: (xf86-video-intel xorg-server xorg-apps gdm mate mate-extra bluez-utils intel-ucode mate-media system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba)"
  echo -e ""
  read -r -p "Would you like to customize your PACKAGES? [y/n]: " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
      echo -e ""
      echo -e "${RED}Please enter PACKAGES, separated by spaces. None of the default packages will be installed:${NC}"
      read MYPACKAGES
      pacman --noconfirm -S ${MYPACKAGES}
      read -p "ENTER to continue..."
    else
      echo -e ""
      echo -e "${RED}Using BAD Gumby's base packages...${NC}"
      pacman --noconfirm -S ${BASEINSTALL}
      read jibba
      pacman --noconfirm -S mate-extra
      read jabba
      pacman --noconfirm -S xorg-apps
      read joo
      pacman --noconfirm -S mate-extra
      read joe
      systemctl enable gdm
      systemctl enable bluetooth
      systemctl enable NetworkManager
      read -p "ENTER to continue..."
  fi
  echo -e $drawline${NC}
}
# Initialize pacman keyring
pacman-key-init
# Execute install function
base-install-packages

##############################################################################################################
##### Switching user for AUR package installations
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Switching to created user, ${RED}${MYUSERNAME}${BLUE}, for AUR package installs"
echo -e $drawline${NC}
su $MYUSERNAME

##############################################################################################################
##### Install AUR Helper (Aura)
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Installing aura (Arch User Repository package manager)"
echo -e $drawline${NC}
# Pull down the aura PKGBUILD.
mkdir /home/${MYUSERNAME}/aura-bin
cd /home/${MYUSERNAME}/aura-bin
wget --no-check-certificate https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD\?h\=aura-bin --output-document=./PKGBUILD
makepkg -si

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
