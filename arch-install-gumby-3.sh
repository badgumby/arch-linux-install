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
##### Finished with third script, time to reboot
##############################################################################################################

echo -e ${BLUE}$drawline
echo -e "Are you ready to reboot? Press ENTER to continue, CTRL+C to stay in chroot."
echo -e $drawline${NC}
read MYREBOOT

echo -e ${BLUE}$drawline
echo -e "Exiting chroot..."
echo -e $drawline${NC}
# Exit su
exit
# Exit chroot
exit
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
