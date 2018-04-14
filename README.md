# BAD Gumby's base install of Arch

```
      ██████╗  █████╗ ██████╗      ██████╗ ██╗   ██╗███╗   ███╗██████╗ ██╗   ██╗███████╗
      ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██║   ██║████╗ ████║██╔══██╗╚██╗ ██╔╝██╔════╝
      ██████╔╝███████║██║  ██║    ██║  ███╗██║   ██║██╔████╔██║██████╔╝ ╚████╔╝ ███████╗
      ██╔══██╗██╔══██║██║  ██║    ██║   ██║██║   ██║██║╚██╔╝██║██╔══██╗  ╚██╔╝  ╚════██║
      ██████╔╝██║  ██║██████╔╝    ╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝   ██║   ███████║
      ╚═════╝ ╚═╝  ╚═╝╚═════╝      ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝    ╚═╝   ╚══════╝
 █████╗ ██████╗  ██████╗██╗  ██╗      ███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║      ██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
███████║██████╔╝██║     ███████║█████╗███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
██╔══██║██╔══██╗██║     ██╔══██║╚════╝╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
██║  ██║██║  ██║╚██████╗██║  ██║      ███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝      ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝        
```
## WARNING
#### This script was created by BAD Gumby for his own install. The very first step is wiping your storage device. If you use it, be sure to backup your data before starting the script. BAD Gumby takes no responsibility for lost data or damage to your device.

## Files
#### configuration.md
> Contains the common configuration changes that I make on a fresh install

#### "icons" folder
> Contains icons I commonly use

#### arch-install-gumby.sh
> One script to rule them all

## Preparing to run the script
1. Download the archiso image from https://www.archlinux.org/
2. Copy to a usb-drive. If on linux use the below command:

   > dd if=archlinux.img of=/dev/sdX bs=16M && sync

3. Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.
4. Setup network connections

   > systemctl start dhcpcd@eth0.service (this could be a different NIC name: eth1, eno0, enp0, etc...)

   > For WiFi only system, use wifi-menu

## Executing the script
> bash <(curl -s --tlsv1.2 --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")

## What does this script do? In order:
1. Prompts for system type (EFI or BIOS)
   > Note: BIOS setup is still a work-in-progress. DO NOT USE this option.

2. Formats and partitions your hard drive

   + EFI Formatting
   > 200MB EFI Partition (ef00) - Formats to FAT32

   > 500MB Linux File System BOOT Partition (8300) - Formats to EXT2

   > Remainder: Linux File System (8300) - Creates logical volume that is LUKS encrypted (aes-xts-plain64)
   > Creates 8GB SWAP on LUKS volume
   > Uses remaining for EXT4 on LUKS volume

   + BIOS Formatting
   > 10MB MBR Partition (ef02) - Formats to FAT32

   > 250MB Linux File System BOOT Parition (8300) - Formats to EXT2

   > Remainder: Linux File System (8300) - Creates logical volume that is LUKS encrypted (aes-xts-plain64)
   > Creates 8GB SWAP on LUKS volume
   > Uses remaining for EXT4 on LUKS volume

3. Runs pacstrap (base install) based on choice of system. Packages listed below:
   > EFI: base base-devel grub-efi-x86_64 efibootmgr zsh vim wget git dialog wpa_supplicant reflector
   > BIOS: base base-devel grub-bios zsh vim wget git dialog wpa_supplicant reflector

4. Generate /etc/fstab
5. Make a tmpfs for /tmp (used by installer)
6. Download second script
   > arch-install-gumby-2.sh

7. Chroot into new system
   > arch-chroot /mnt /bin/bash /root/arch-install-gumby-2.sh

8. Set time zone
9. Set hostname
10. Enable en_US.UTF-8 locale, and generate locale
11. Set 'root' password
12. Create new user, set shell, and add to wheel group
13. Configure initrd MODULES
    + Default:
    > ext4

    + Custom:
    > Enter modules separated by spaces

14. Configure initrd BINARIES
    + Default:
    > none

    + Custom:
    > Enter binaries separated by spaces

15. Configure initrd FILES
    + Default:
    > none

    + Custom:
    > Enter files separated by spaces

16. Configure initrd HOOKS
    + Default:
    > base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck

    + Custom:
    > Enter hooks separated by spaces

17. Generate initrd image
18. Run initial grub-install, edit grub config for cryptdevice boot, then run grub-mkconfig
19. Enable Arch [multilib] repo
20. Run reflector to update mirrors based on sync, location, and sort by download speed
21. Intialize pacman-key
22. Install packages from Arch official repository
    + BAD Gumby's default packages:
    > xf86-video-intel xorg-server gdm mate mate-extra xorg-appsbluez-utils intel-ucode system-config-printer network-manager-applet dconf-editor remmina tilda filezilla poedit jdk8-openjdk jre8-openjdk scrot keepass atom ncmpcpp mopidy steam gimp inkscape neofetch conky p7zip ntfs-3g samba

    + Custom:
    > Enter packages separated by spaces

23. Enable services
    > Enter services separated by spaces

24. Download third script
    > arch-install-gumby-3.sh

25. Switch into newly created user
    > su -p $MYUSERNAME /home/${MYUSERNAME}/arch-install-gumby-3.sh

26. Download and install 'aura' Arch user repository package manager
27. Prompt to install System76 drivers/modules
    + Packages
    > system76-driver system76-dkms-git system76-wallpapers

28. Install packages from Arch user repository
    + BAD Gumby's default packages:
    > mate-tweak oh-my-zsh-git correcthorse neovim-gtk-git remmina-plugin-rdesktop visual-studio-code-bin wps-office google-chrome mopidy-gmusic keybase-bin signal-desktop-bin multibootusb skype-electron

    + Custom:
    > Enter packages separated by spaces

29. Prompt to install BAD Gumby's favorite themes/fonts
    + Packages:
    > ant-nebula-gtk-theme candy-gtk-theme paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts

30. Prompt to reboot
