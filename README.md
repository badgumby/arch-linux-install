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
#### Apps-Arch-Repo.md
   > Table of apps that will be installed from the official Arch repository if you use BAD Gumby's defaults

#### Apps-User-Repo.md
   > Table of apps that will be installed from the Arch user repository (AUR) if you use BAD Gumby's defaults

#### arch-install-gumby(-2/3).sh
   > What you came to see

#### configuration.md
   > Contains the common configuration changes that I make on a fresh install

#### "icons" folder
   > Contains icons I commonly use

#### README.md
   > Uh... you're looking at it


## Preparing to run the script
1. Download the archiso image from https://www.archlinux.org/
2. Copy to a usb-drive. If on linux use the below command:

   > dd if=archlinux.img of=/dev/sdX bs=16M && sync

3. Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.
4. Setup network connections

   For Wired LAN, use `systemctl start dhcpcd@eth0.service`

   For Wireless LAN, use `wifi-menu`

## Executing the script
`bash <(curl -s --tlsv1.2 --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")`

## What does this script do? In order:
1. Prompts for system type (EFI or BIOS)
   > Note: BIOS setup is still a work-in-progress. **DO NOT USE BIOS OPTION**.

2. Format and partitions your hard drive

   + EFI Formatting

      | Partition | Size | Type | Format |
      | --- | --- | --- | --- |
      | 1 | 200 MB | EFI (ef00) | FAT32 |
      | 2 | 500 MB | Linux File System (8300) | EXT2 |
      | 3 | Remainder + | Linux File System (8300) | LUKS (aes-xts-plain64) logical volume group (vg0) |
      | vg0-swap | 8 GB | n/a | swap on vg0 |
      | vg0-root | Remainder + | n/a | EXT4 on vg0 |

   + BIOS Formatting

      | Partition | Size | Type | Format |
      | --- | --- | --- | --- |
      | 1 | 10 MB | MBR (ef02) | FAT32 |
      | 2 | 250 MB | Linux File System (8300) | EXT2 |
      | 3 | Remainder + | Linux File System (8300) | LUKS (aes-xts-plain64) logical volume group (vg0) |
      | vg0-swap | 8 GB | n/a | swap on vg0 |
      | vg0-root | Remainder + | n/a | EXT4 on vg0 |

3. Run `pacstrap` (base install) based on choice of system. Packages listed below:
   + EFI:

      [base](https://www.archlinux.org/groups/x86_64/base/) [base-devel](https://www.archlinux.org/groups/x86_64/base-devel/) [grub-efi-x86_64](https://www.archlinux.org/packages/core/x86_64/grub/) [efibootmgr](https://www.archlinux.org/packages/core/x86_64/efibootmgr/) [linux-headers](https://www.archlinux.org/packages/core/x86_64/linux-headers/) [zsh](https://www.archlinux.org/packages/extra/x86_64/zsh/) [vim](https://www.archlinux.org/packages/extra/x86_64/vim/) [wget](https://www.archlinux.org/packages/extra/x86_64/wget/) [git](https://www.archlinux.org/packages/extra/x86_64/git/) [dialog](https://www.archlinux.org/packages/core/x86_64/dialog/) [wpa_supplicant](https://www.archlinux.org/packages/core/x86_64/wpa_supplicant/) [reflector](https://www.archlinux.org/packages/community/any/reflector/)

      Note: base is the required minimum for install, and base-devel is recommended.

   + BIOS:

      [base](https://www.archlinux.org/groups/x86_64/base/) [base-devel](https://www.archlinux.org/groups/x86_64/base-devel/) [grub-bios](https://www.archlinux.org/packages/core/x86_64/grub/) [linux-headers](https://www.archlinux.org/packages/core/x86_64/linux-headers/) [zsh](https://www.archlinux.org/packages/extra/x86_64/zsh/) [vim](https://www.archlinux.org/packages/extra/x86_64/vim/) [wget](https://www.archlinux.org/packages/extra/x86_64/wget/) [git](https://www.archlinux.org/packages/extra/x86_64/git/) [dialog](https://www.archlinux.org/packages/core/x86_64/dialog/) [wpa_supplicant](https://www.archlinux.org/packages/core/x86_64/wpa_supplicant/) [reflector](https://www.archlinux.org/packages/community/any/reflector/)

      Note: base is the required minimum for install, and base-devel is recommended.

4. Generate /etc/fstab
5. Make a tmpfs for /tmp (used by installer)
6. Download second script

   `arch-install-gumby-2.sh`

7. Chroot into new system

   `arch-chroot /mnt /bin/bash /root/arch-install-gumby-2.sh`

8. Set time zone
9. Set hostname
10. Enable `en_US.UTF-8 locale`, and generate locale
11. Set `root` password
12. Create new user, set shell, and add to `wheel` group
13. Configure initrd MODULES
    + Default:

      `ext4`

    + Custom:

      `Enter modules separated by spaces`

14. Configure initrd BINARIES
    + Default:

      `none`

    + Custom:

      `Enter binaries separated by spaces`

15. Configure initrd FILES
    + Default:

      `none`

    + Custom:

      `Enter files separated by spaces`

16. Configure initrd HOOKS
    + Default:

      `base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck`

    + Custom:

      `Enter hooks separated by spaces`

17. Generate initrd image
18. Run initial `grub-install`, edit grub config for cryptdevice boot, then run `grub-mkconfig`
19. Enable Arch `[multilib]` repo
20. Run `reflector` to update mirrors based on sync, location, and sort by download speed
21. Intialize `pacman-key`
22. Install packages from Arch official repository
    + BAD Gumby's default packages:

      [List of official repo packages](../master/Apps-Arch-Repo.md)

    + Custom:

      `Enter packages separated by spaces`

23. Download third script

   `arch-install-gumby-3.sh`

24. Switch into newly created user

   `su -p $MYUSERNAME /home/${MYUSERNAME}/arch-install-gumby-3.sh`

25. Download and install `aura` Arch user repository package manager
26. Prompt to install System76 drivers/modules (installed from AUR)
    + Packages

      `system76-driver system76-dkms-git system76-wallpapers`

27. Install packages from Arch user repository
    + BAD Gumby's default packages:

      [List of AUR packages](../master/Apps-User-Repo.md)

    + Custom:

      `Enter packages separated by spaces`

28. Enable services `sytemctl enable *` after packages have been installed

   `Enter services separated by spaces`

29. Prompt to install BAD Gumby's favorite themes/fonts
    + Packages:

      `arc-gtk-theme arc-solid-gtk-theme materia-theme-git candy-gtk-theme paper-icon-theme ttf-material-icons ttf-ms-fonts ttf-wps-fonts`

30. Prompt to reboot
