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

echo -e "${WARN1}Loaded script 3...${NC}"

##############################################################################################################
##### Install AUR Helper (yay: https://github.com/Jguer/yay)
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Installing yay (AUR Helper and Pacman wrapper)"
echo -e $drawline${NC}
# Pull down the yay PKGBUILD.
mkdir /home/${MYUSERNAME}/yay
cd /home/${MYUSERNAME}/yay
wget --no-check-certificate https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay --output-document=./PKGBUILD
makepkg -si

##############################################################################################################
##### System76 drivers
##############################################################################################################

INSTALL76=(system76-driver system76-dkms-git system76-wallpapers)

echo -e ${TEXTCOLOR}$drawline
echo -e "Packages for System76 computers"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}system76-driver system76-dkms-git system76-wallpapers${TEXTCOLOR})"
echo -e "${CHOICE}"
read -r -p "Is this a System76 computer? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    for i in "${INSTALL76[@]}"
    do
      echo -e "${OTHER}Installing $i...${NC}"
      sudo yay -S $i
    done
  else
    echo -e ""
    echo -e "${OTHER}Not a System76 computer. Skipping...${NC}"
fi
echo -e ${TEXTCOLOR}$drawline${NC}

##############################################################################################################
##### Install packages for AUR
##############################################################################################################

AURINSTALL=(correcthorse displaylink evdi google-chrome keybase-bin mate-tweak mopidy-gmusic multibootusb neovim-gtk-git oh-my-zsh-git signal-desktop-bin skype-electron visual-studio-code-bin wps-office)

echo -e ${TEXTCOLOR}$drawline
echo -e "BAD Gumby's packages from the Arch User Repository"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}correcthorse displaylink evdi google-chrome keybase-bin mate-tweak mopidy-gmusic multibootusb neovim-gtk-git oh-my-zsh-git signal-desktop-bin skype-electron visual-studio-code-bin wps-office${TEXTCOLOR})"
echo -e "${CHOICE}"
read -r -p "Would you like to customize your AUR PACKAGES? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "${CHOICE}Please enter AUR PACKAGES, separated by spaces. None of the default AUR packages will be installed:${NC}"
    read -a MYAUR
    for i in "${MYAUR[@]}"
    do
      echo -e "${OTHER}Installing $i...${NC}"
      sudo yay -S $i
    done
  else
    echo -e ""
    echo -e "${CHOICE}Using BAD Gumby's AUR packages...${NC}"
    for i in "${AURINSTALL[@]}"
    do
      echo -e "${OTHER}Installing $i...${NC}"
      sudo yay -S $i
    done
fi
echo -e ${TEXTCOLOR}$drawline${NC}

##############################################################################################################
##### Start services - after yay
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Enabling system services: 'sudo systemctl enable service'"
echo -e "${CHOICE}"
read -r -p "Would you like to set any services to start at boot? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    echo -e ""
    echo -e "${CHOICE}Please enter services, separated by spaces.${NC}"
    echo -e "${OTHER}Suggested: NetworkManager bluetooth sshd gdm displaylink${NC}"
    read -a MYSERVICES
    for i in "${MYSERVICES[@]}"
    do
      echo -e "${OTHER}Enabling $i...${NC}"
      sudo systemctl enable $i
    done
  else
    echo -e ""
    echo -e "${OTHER}No services will be enabled.${NC}"
fi
echo -e ${TEXTCOLOR}$drawline${NC}
echo -e "${CHOICE}Pausing to display results. Press ENTER to continue...${NC}"
read HEYWAITNOW

##############################################################################################################
##### BAD Gumby's favorite themes/fonts
##############################################################################################################

THEMEINSTALL1=(arc-gtk-theme arc-solid-gtk-theme)
THEMEINSTALL2=(materia-theme-git candy-gtk-theme paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts)

echo -e ${TEXTCOLOR}$drawline
echo -e "BAD Gumby's favorite themes/fonts"
echo -e "${DEF1}Default:${TEXTCOLOR} (${OTHER}arc-gtk-theme arc-solid-gtk-theme materia-theme-git candy-gtk-theme paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts${TEXTCOLOR})"
echo -e "${CHOICE}"
read -r -p "Would you like to install BAD Gumby's favorite themes? [y/n]: " response
echo -e ${NC}
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    for i in "${THEMEINSTALL1[@]}"
    do
      echo -e "${OTHER}Installing $i...${NC}"
      sudo pacman -S $i
    done
    for i in "${THEMEINSTALL2[@]}"
    do
      echo -e "${OTHER}Installing $i...${NC}"
      sudo yay -S $i
    done
  else
    echo -e ""
    echo -e "${CHOICE}Not installing themes. Skipping...${NC}"
fi
echo -e ${TEXTCOLOR}$drawline${NC}

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##### Finished with third script , back to script 2
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
