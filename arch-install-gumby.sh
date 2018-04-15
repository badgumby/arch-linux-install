#!/bin/bash

# 1. Download the archiso image from https://www.archlinux.org/
# 2. Copy to a usb-drive on linux
#    dd if=archlinux.img of=/dev/sdX bs=16M && sync
# 3. Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.
# 4. Setup network connections
#    systemctl enable dhcpcd@eth0.service
#    For WiFi only system, use wifi-menu
# 5. Execute this script:
#    bash <(curl -s --tlsv1.2 --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")

#Line separator variable
drawline=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -`
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
WARN1='\033[0;31m' # Red
DEF1='\033[0;32m' # Green
BROWN='\033[0;33m' # Brown/Orange
#TEXTCOLOR='\033[0;34m' # Blue
TEXTCOLOR='\033[0;36m' # Cyan
OTHER='\033[1;35m' # Purple
CHOICE='\033[1;33m' # Yellow

BOLD='\e[1m'
NB='\e[21m' #No Bold
NC='\033[0m' # No Color
clear

# http://http://patorjk.com/software/taag/
# Fonts: ANSI Shadow (optional: 3D-Ascii + Chunky)
echo -e ${TEXTCOLOR}
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
##### Global functions
##############################################################################################################

function select_device {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "List of storage devices"
  echo -e $drawline${NC}
  fdisk -l

  echo -e ${CHOICE}$drawline
  echo -e "What device should we partition? (ex. /dev/sda)"
  echo -e $drawline${NC}
  read storagedevice

  echo -e ${WARN1}$drawline
  echo -e "WARNING: You are about to format the device ${OTHER}${storagedevice}${WARN1}. Press CTRL+C to quit. Press ENTER to continue."
  echo -e "This is your last chance to exit before you wipe your drive!"
  echo -e $drawline${NC}
  read WARNING2
}

function inform_os_partitions {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Printing written partitions..."
  echo -e $drawline${NC}
  sgdisk -p $storagedevice

  echo -e ${TEXTCOLOR}$drawline
  echo -e "Informing OS of changes..."
  echo -e $drawline${NC}
  partprobe $storagedevice
  fdisk -l $storagedevice
}

function encrypt_device {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Setting up the encryption of the system..."
  echo -e $drawline${NC}
  cryptsetup -c aes-xts-plain64 -y --use-random luksFormat ${storagedevice}3
  cryptsetup luksOpen ${storagedevice}3 luks

  echo -e ${TEXTCOLOR}$drawline
  echo -e "Creating encrypted partitions..."
  echo -e $drawline${NC}
  pvcreate /dev/mapper/luks
  vgcreate vg0 /dev/mapper/luks
  lvcreate --size 8G vg0 --name swap
  lvcreate -l +100%FREE vg0 --name root

  echo -e ${TEXTCOLOR}$drawline
  echo -e "Creating filesystems on encrypted partitions..."
  echo -e $drawline${NC}
  mkfs.ext4 /dev/mapper/vg0-root
  mkswap /dev/mapper/vg0-swap
}

##############################################################################################################
##### EFI system functions
##############################################################################################################

function efi_pacstrap {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Installing packages for EFI system"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-efi-x86_64 efibootmgr zsh vim wget git dialog wpa_supplicant reflector
}

function efi_partition {
  sgdisk -Z $storagedevice
  sgdisk -n 0:0:+200M -t 0:ef00 -c 0:"efi_boot" $storagedevice
  sgdisk -n 0:0:+550M -t 0:8300 -c 0:"linux_boot" $storagedevice
  sgdisk -n 0:0:0 -t 0:8300 -c 0:"data" $storagedevice
}

function efi_create_fs {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Creating file systems on the EFI/BIOS and boot partitions..."
  echo -e $drawline${NC}
  mkfs.vfat -F32 ${storagedevice}1
  mkfs.ext2 ${storagedevice}2
}

function mount_efi {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Mounting the new system..."
  echo -e $drawline${NC}
  mount /dev/mapper/vg0-root /mnt
  swapon /dev/mapper/vg0-swap
  mkdir /mnt/boot
  mount ${storagedevice}2 /mnt/boot
  mkdir /mnt/boot/efi
  mount ${storagedevice}1 /mnt/boot/efi
}



##############################################################################################################
##### BIOS functions
##############################################################################################################

function bios_pacstrap {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Installing packages for BIOS"
  echo -e $drawline${NC}
  pacstrap /mnt base base-devel grub-bios zsh vim wget git dialog wpa_supplicant reflector
}

function bios_create_fs {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Creating file systems on the EFI/BIOS and boot partitions..."
  echo -e $drawline${NC}
  mkfs.vfat -F32 ${storagedevice}1
  mkfs.ext2 ${storagedevice}2
}

function bios_partition {
  #sfdisk -w $storagedevice
  #sfdisk $storagedevice -X dos
  #sfdisk -N 1 $storagedevice
  sgdisk -Z $storagedevice
  sgdisk -n 0:0:+10M -t 0:ef02 -c 0:"mbr_boot" $storagedevice
  sgdisk -n 0:0:+250M -t 0:8300 -c 0:"linux_boot" $storagedevice
  sgdisk -n 0:0:0 -t 0:8300 -c 0:"data" $storagedevice
}

function mount_bios {
  echo -e ${TEXTCOLOR}$drawline
  echo -e "Mounting the new system..."
  echo -e $drawline${NC}
  mount /dev/mapper/vg0-root /mnt
  swapon /dev/mapper/vg0-swap
  mkdir /mnt/boot
  mount ${storagedevice}2 /mnt/boot
}



##############################################################################################################
##### Functions for installs
##############################################################################################################

function efi_install {
  # If EFI System is selected
  select_device
  efi_partition
  inform_os_partitions
  efi_create_fs
  encrypt_device
  mount_efi
}

function bios_install {
  # If BIOS is selected
  select_device
  bios_partition
  inform_os_partitions
  bios_create_fs
  encrypt_device
  mount_bios
}

##############################################################################################################
##### WARNING Message - Start of script
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "${WARN1}WARNING: BAD Gumby's Arch installer is destructive."
echo -e "${WARN1}The first step will format your drive! Be sure to backup your data before running, if necessary."
echo -e "${WARN1}If you ran this by mistake, please quit now!"
echo -e "${WARN1}${BOLD}Press CTRL+C to quit. Press ENTER to continue.${NB}${TEXTCOLOR}"
echo -e $drawline${NC}
read WARNING

##############################################################################################################
##### Select EFI or BIOS system type
##############################################################################################################

options=("EFI System" "BIOS")
echo ""
echo -e "${CHOICE}Choose your system type: ${NC}"
select opt in "${options[@]}"; do
case $REPLY in
  1) efi_install; break ;;
  2) bios_install; break ;;
  *) clear; echo -e "${WARN1}Invalid option selected. Please try again.${NC}"; break ;;
  esac
done

##############################################################################################################
##### Build /etc/fstab
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo "Writing current fstab to file /mnt/etc/fstab"
echo -e $drawline${NC}
genfstab -pU /mnt >> /mnt/etc/fstab

echo -e ${TEXTCOLOR}$drawline
echo -e "Making /tmp a ramdisk (adding tmpfs to /mnt/etc/fstab)"
echo -e $drawline${NC}
echo 'tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0' >> /mnt/etc/fstab
# Change relatime on all non-boot partitions to noatime (reduces wear if using an SSD)

##############################################################################################################
##### Enter arch-chroot
##############################################################################################################

echo -e ${TEXTCOLOR}$drawline
echo -e "Entering the new system..."
echo -e $drawline${NC}
# Downloading next script
curl -o /mnt/root/arch-install-gumby-2.sh -s --tlsv1.2 --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby-2.sh"
chmod +x /mnt/root/arch-install-gumby-2.sh
# Exporting storagedevice variable
echo $storagedevice > /mnt/root/storagedevice.txt

arch-chroot /mnt /bin/bash /root/arch-install-gumby-2.sh

##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################
##### Finished with initial setup, time to reboot
##############################################################################################################
##############################################################################################################
##############################################################################################################
##############################################################################################################

echo -e ${WARN1}$drawline
echo -e "Installation is complete."
echo -e "${CHOICE}Are you ready to reboot? Press ENTER to continue, CTRL+C to stay in chroot.${BLUE}"
echo -e "If you stay in chroot, be sure to type 'exit' when you are done working to reboot."
echo -e ${WARN1}$drawline${NC}
read MYREBOOT

echo -e ${TEXTCOLOR}$drawline
echo -e "Exiting chroot..."
echo -e $drawline${NC}
# Exit chroot
exit

echo -e ${TEXTCOLOR}$drawline
echo -e "Unmounting all partitions..."
echo -e $drawline${NC}
umount -R /mnt
swapoff -a

echo -e ${TEXTCOLOR}$drawline
echo -e "Initiating reboot..."
echo -e "Please remember to remove installation media."
echo -e $drawline${NC}
reboot

##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
