BAD Gumby's base install of Arch


## Files
#### configuration.md
> Changes to be made after install

#### "icons" folder
> Contains icons I commonly use

#### arch-install-gumby.sh
> One script to rule them all

## Preparing to run the script
1. Download the archiso image from https://www.archlinux.org/
2. Copy to a usb-drive on linux

   dd if=archlinux.img of=/dev/sdX bs=16M && sync
   
3. Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.
4. Setup network connections

   systemctl enable dhcpcd@eth0.service

   For WiFi only system, use wifi-menu

## Executing the script
> bash <(curl -s --tlsv1.2 --insecure --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")
