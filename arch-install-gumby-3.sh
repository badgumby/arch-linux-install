#!/bin/bash

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

echo -e "${RED}Loaded script 3...${NC}"

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

76INSTALL=(system76-driver system76-dkms-git system76-wallpapers)

echo -e ${BLUE}$drawline
echo -e "Packages for System76 computers"
echo -e "${GREEN}Default:${BLUE} (${RED}system76-driver system76-dkms-git system76-wallpapers${BLUE})"
echo -e "${RED}"
read -r -p "Is this a System76 computer? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    for i in "${76INSTALL[@]}"
    do
      echo -e "${RED}Installing $i...${NC}"
      sudo aura -Ax $i
    done
  else
    echo -e ""
    echo -e "${RED}Not a System76 computer. Skipping...${NC}"
fi
echo -e ${BLUE}$drawline${NC}

##############################################################################################################
##### Install packages for AUR
##############################################################################################################

AURINSTALL=(mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin zoom multibootusb skype-electron)

echo -e ${BLUE}$drawline
echo -e "BAD Gumby's packages from the Arch User Repository"
echo -e "${GREEN}Default:${BLUE} (${RED}mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin zoom multibootusb skype-electron${BLUE})"
echo -e "${RED}"
read -r -p "Would you like to customize your AUR PACKAGES? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "${RED}Please enter AUR PACKAGES, separated by spaces. None of the default AUR packages will be installed:${NC}"
    read -a MYAUR
    for i in "${MYAUR[@]}"
    do
      echo -e "${RED}Installing $i...${NC}"
      sudo aura -Ax $i
    done
  else
    echo -e ""
    echo -e "${RED}Using BAD Gumby's AUR packages...${NC}"
    for i in "${AURINSTALL[@]}"
    do
      echo -e "${RED}Installing $i...${NC}"
      sudo aura -Ax $i
    done
fi
echo -e ${BLUE}$drawline${NC}

##############################################################################################################
##### BAD Gumby's favorite themes
##############################################################################################################

THEMEINSTALL=(ant-nebula-gtk-theme candy-gtk-themes paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts typecatcher)

echo -e ${BLUE}$drawline
echo -e "BAD Gumby's favorite themes"
echo -e "${GREEN}Default:${BLUE} (${RED}ant-nebula-gtk-theme candy-gtk-themes paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts typecatcher${BLUE})"
echo -e "${RED}"
read -r -p "Would you like to install BAD Gumby's favorite themes? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    for i in "${THEMEINSTALL[@]}"
    do
      echo -e "${RED}Installing $i...${NC}"
      sudo aura -Ax $i
    done
  else
    echo -e ""
    echo -e "${RED}Not installing themes. Skipping...${NC}"
fi
echo -e ${BLUE}$drawline${NC}

##############################################################################################################
##### Finished with third script
##############################################################################################################
