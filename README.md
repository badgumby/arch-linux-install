# BAD Gumby's base install of Arch

```
 ________  ________  ________     ________  ___  ___  _____ ______   ________      ___    ___ ________     
|\   __  \|\   __  \|\   ___ \   |\   ____\|\  \\\  \|\   _ \  _   \|\   __  \    |\  \  / /|\    ____\    
\ \   __  \ \   __  \ \  \ \\ \  \ \  \  __\ \  \\\  \ \  \\|__| \  \ \   __  \   \ \   / / \ \ _____  \   
 \ \  \|\  \ \  \ \  \ \  \_\\ \  \ \  \|\  \ \  \\\  \ \  \    \ \  \ \  \|\  \   \/  / /   \|____| \  \  
  \ \_______\ \__\ \__\ \_______\  \ \_______\ \_______\ \__\    \ \__\ \_______\__/  / /       ____\_\  \
   \|_______|\|__|\|__|\|_______|   \|_______|\|_______|\|__|     \|__|\|_______|\___/ /       |\_________\
                                                                                \|___|/        \|_________|
                  _______             __                __          __ __                                   
                 |   _   |.----.----.|  |--.    .-----.|  |_.---.-.|  |  |.-----.----.                      
                 |       ||   _|  __||     |----|__ --||   _|  _  ||  |  ||  -__|   _|                      
                 |___|___||__| |____||__|__|----|_____||____|___._||__|__||_____|__|                        
```

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

   > systemctl start dhcpcd@eth0.service

   > For WiFi only system, use wifi-menu

## Executing the script
> bash <(curl -s --tlsv1.2 --insecure --request GET "https://raw.githubusercontent.com/badgumby/arch-linux-install/master/arch-install-gumby.sh")
