#!/bin/bash
# Begin arch-install-gumby-2.sh

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WARN1='\033[0;31m' # Red
DEF1='\033[0;32m' # Green
BROWN='\033[0;33m' # Brown/Orange
BLUE='\033[0;34m' # Blue
TEXTCOLOR='\033[0;36m' # Cyan
#OTHER='\033[1;35m' # Purple
OTHER='\033[1;36m' # Light Cyan
#OTHER='\033[1;34m' # Light Blue
CHOICE='\033[1;33m' # Yellow
LIGHTCYAN='\033[1;36m' # Light Cyan
LIGHTGREEN='\033[1;32m' # Light Green

BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color

echo -e "${WARN1}Loaded script 2...${NC}"

##############################################################################################################
##### Functions for system selection
##############################################################################################################

function pacman-key-init {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Initializing pacman-key..."
  echo -e $drawline${NC}
  pacman-key --init
  pacman-key --populate archlinux
}

##############################################################################################################
##### Configure timezone / hostname / locale
##############################################################################################################

echo -e ${CHOICE}$drawline
echo -e "Please enter system clock with local timezone (ex. America/Chicago): "
echo -e $drawline${NC}
read MYTIMEZONE
rm /etc/localtime
ln -s /usr/share/zoneinfo/$MYTIMEZONE /etc/localtime
hwclock --systohc --utc

echo -e ${CHOICE}$drawline
echo -e "Enter a computer hostname:"
echo -e $drawline${NC}
read MYHOSTNAME
echo $MYHOSTNAME > /etc/hostname

echo -e ${CHOICE}$drawline
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

echo -e ${CHOICE}$drawline
echo -e "Please enter a ${OTHER}password${CHOICE} for ${OTHER}'root'${CHOICE}:"
echo -e $drawline${NC}
passwd

sed -i '/%wheel ALL=(ALL) ALL/c\%wheel ALL=(ALL) ALL'  /etc/sudoers

echo -e ${CHOICE}$drawline
echo -e "Please enter your ${OTHER}username${CHOICE} (user will be in ${OTHER}wheel${CHOICE} group):"
echo -e $drawline${NC}
read MYUSERNAME
# Exporting for call in next script
export MYUSERNAME

echo -e ${CHOICE}$drawline
echo -e "Please enter your default ${OTHER}shell${CHOICE} (options: ${OTHER}/bin/bash${CHOICE} or ${OTHER}/bin/zsh)${CHOICE}:"
echo -e $drawline${NC}
read MYSHELL
useradd -m -g users -G wheel -s $MYSHELL $MYUSERNAME
passwd $MYUSERNAME

##############################################################################################################
##### MODULES in mkinitcpio
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Configure mkinitcpio with ${OTHER}MODULES${TEXTCOLOR} needed for the initrd image"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}ext4${TEXTCOLOR})"
BASEMODULES='ext4'
echo -e "${CHOICE}"
read -r -p "Would you like to customize your MODULES? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "${CHOICE}Please enter MODULES, separated by spaces. None will be configured by default:${NC}"
    read MYMODULES
    sed -i '/^MODULES=/c\MODULES=('"${MYMODULES}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following MODULES have been added: ${OTHER}${MODULES} ${MYMODULES}${TEXTCOLOR}"
  else
    echo -e "${CHOICE}Using default MODULES"
    sed -i '/^MODULES=/c\MODULES=('"${BASEMODULES}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following MODULES have been added: ${OTHER}${BASEMODULES}${TEXTCOLOR}"
fi
echo -e $drawline${NC}

##############################################################################################################
##### BINARIES in mkinitcpio
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Configure mkinitcpio with ${OTHER}BINARIES${TEXTCOLOR} needed for the initrd image"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}*none*${TEXTCOLOR})"
echo -e "${CHOICE}"
read -r -p "Would you like to customize your BINARIES? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "${CHOICE}Please enter BINARIES, separated by spaces. None will be configured by default:${NC}"
    read MYBINARIES
    sed -i '/^BINARIES=/c\BINARIES=('"${MYBINARIES}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following BINARIES have been added: ${OTHER}${MYBINARIES}${TEXTCOLOR}"
  else
    echo -e "${CHOICE}The there are no default BINARIES to configure.${TEXTCOLOR}"
fi
echo -e $drawline${NC}

##############################################################################################################
##### FILES in mkinitcpio
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Configure mkinitcpio with ${OTHER}FILES${TEXTCOLOR} needed for the initrd image"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}*none*${TEXTCOLOR})"
echo -e "${CHOICE}"
read -r -p "Would you like to customize your FILES? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "${CHOICE}Please enter FILES, separated by spaces. None will be configured by default:${NC}"
    read MYFILES
    sed -i '/^FILES=/c\FILES=('"${MYFILES}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following FILES have been added: ${OTHER}${MYFILES}${TEXTCOLOR}"
  else
    echo -e "${CHOICE}The there are no default FILES to configure.${TEXTCOLOR}"
fi
echo -e $drawline${NC}

##############################################################################################################
##### HOOKS in mkinitcpio
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Configure mkinitcpio with ${OTHER}HOOKS${TEXTCOLOR} needed for the initrd image"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck${TEXTCOLOR})"
BASEHOOKS='base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck'
echo -e "${CHOICE}"
read -r -p "Would you like to customize your HOOKS? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "${CHOICE}Please enter HOOKS, separated by spaces. None will be configured by default:${NC}"
    read MYHOOKS
    sed -i '/^HOOKS=/c\HOOKS=('"${MYHOOKS}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following HOOKS have been added: ${OTHER}${BASEHOOKS} ${MYHOOKS}${TEXTCOLOR}"
  else
    echo -e "${CHOICE}Using default HOOKS"
    sed -i '/^HOOKS=/c\HOOKS=('"${BASEHOOKS}"')' /etc/mkinitcpio.conf
    echo -e "${TEXTCOLOR}The following HOOKS have been added: ${OTHER}${BASEHOOKS}${TEXTCOLOR}"
fi
echo -e $drawline${NC}

##############################################################################################################
##### Regenerate initrd
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Regenerating the initrd image..."
echo -e $drawline${NC}
mkinitcpio -p linux

##############################################################################################################
##### Install/Configure GRUB
##############################################################################################################

# Get storagedevice from first script
storagedevice3=$(head -n 1 /root/storagedevice.txt)

echo -e ${TEXTCOLOR}$drawline
echo -e "Setting up GRUB..."
echo -e $drawline${NC}
grub-install

echo -e ${TEXTCOLOR}$drawline
echo -e "Modifying GRUB file to select encrypted partition..."
echo -e $drawline${RED}
sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cryptdevice='${storagedevice3}':luks:allow-discards"' /etc/default/grub
echo -e ${CHOICE}
echo 'Verify line below shows: GRUB_CMDLINE_LINUX="cryptdevice=/dev/PARTITION3:luks:allow-discards"'
echo -e ${OTHER}
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX=
echo -e ${CHOICE}
read -r -p "Is this correct? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e "${TEXTCOLOR}Continuing using partition: ${OTHER}$storagedevice3${NC}"
  else
    echo -e "${CHOICE}Please enter the correct partition 3 name: ${NC}"
    read storagedevice3
    echo -e "${TEXTCOLOR}Using partition: ${OTHER}$storagedevice3${NC}"
    sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cryptdevice='${storagedevice3}':luks:allow-discards"' /etc/default/grub
    cat /etc/default/grub | grep GRUB_CMDLINE_LINUX=
fi
read HOLDUPHEY
echo -e ${NC}
grub-mkconfig -o /boot/grub/grub.cfg

##############################################################################################################
##### Enable Arch Multilib
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Enabling Arch multilib repo..."
echo -e $drawline${NC}

linenumber=$(grep -nr "\\#\\[multilib\\]" /etc/pacman.conf | gawk '{print $1}' FS=":")
sed -i "${linenumber}s:.*:[multilib]:" /etc/pacman.conf
linenumber=$((linenumber+1))
sed -i "${linenumber}s:.*:Include = /etc/pacman.d/mirrorlist:" /etc/pacman.conf

##############################################################################################################
##### Update /etc/pacman.d/mirrorlist using Reflector
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Updating /etc/pacman.d/mirrorlist using Reflector"
echo -e "Selecting HTTPS mirrors, synchronized within the last 12 hours, located in country, and sorted by download speed."
echo -e "Full list of countries can be found at ${OTHER}https://archlinux.org/mirrors/status/${TEXTCOLOR}"
echo -e "${CHOICE}Please enter your preferred country (for US, enter: United States)${TEXTCOLOR}"
echo -e $drawline${NC}
read MYCOUNTRY

reflector --country "${MYCOUNTRY}" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist

##############################################################################################################
##### Update local databases with multilib repo
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Synchronizing package databases..."
echo -e $drawline${NC}
pacman -Syy

##############################################################################################################
##### Install common packages from Official Repo
##############################################################################################################

function base-install-packages {
  BASEINSTALL=(aircrack-ng atom bind-tools blueman bluez-utils clamav conky dconf-editor filezilla freerdp gdm gimp gnome-keyring hexchat inkscape intel-ucode jdk8-openjdk jre8-openjdk keepass mate mate-extra mopidy ncmpcpp neofetch network-manager-applet networkmanager-openconnect networkmanager-openvpn networkmanager-vpnc nm-connection-editor nmap ntfs-3g openconnect openssh p7zip pidgin poedit remmina rofi tilda samba scrot steam system-config-printer virtualbox xf86-video-intel xorg-apps xorg-server)

  echo -e ${TEXTCOLOR}$drawline
  echo -e "BAD Gumby's base packages from the Official Arch Repo"
  echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}aircrack-ng atom bind-tools blueman bluez-utils clamav conky dconf-editor filezilla freerdp gdm gimp gnome-keyring hexchat inkscape intel-ucode jdk8-openjdk jre8-openjdk keepass mate mate-extra mopidy ncmpcpp neofetch network-manager-applet networkmanager-openconnect networkmanager-openvpn networkmanager-vpnc nm-connection-editor nmap ntfs-3g openconnect openssh p7zip pidgin poedit remmina rofi tilda samba scrot steam system-config-printer virtualbox xf86-video-intel xorg-apps xorg-server${TEXTCOLOR})"
  echo -e "${CHOICE}"
  read -r -p "Would you like to customize your PACKAGES? [y/n]: " response
  echo -e ${NC}
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
      echo -e ""
      echo -e "${CHOICE}Please enter PACKAGES, separated by spaces. None of the default packages will be installed:${NC}"
      read -a MYPACKAGES
      for i in "${MYPACKAGES[@]}"
      do
        echo -e "${OTHER}Installing $i...${NC}"
        pacman --noconfirm -S $i
      done
    else
      echo -e ""
      echo -e "${TEXTCOLOR}Using BAD Gumby's base packages...${NC}"
      for i in "${BASEINSTALL[@]}"
      do
        echo -e "${OTHER}Installing $i...${NC}"
        pacman --noconfirm -S $i
      done
  fi
  echo -e ${TEXTCOLOR}$drawline${NC}
}
# Initialize pacman keyring
pacman-key-init
# Execute install function
base-install-packages

##############################################################################################################
##### Switching user for AUR package installations
##############################################################################################################

curl -o /home/${MYUSERNAME}/arch-install-gumby-3.sh -s --tlsv1.2 --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby-3.sh"
chmod +x /home/${MYUSERNAME}/arch-install-gumby-3.sh

echo -e ${TEXTCOLOR}$drawline
echo -e "Switching to created user, ${OTHER}${MYUSERNAME}${TEXTCOLOR}, for AUR package installs"
echo -e $drawline${NC}
su -p $MYUSERNAME /home/${MYUSERNAME}/arch-install-gumby-3.sh

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##### Finished with second script, back to 1
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
