# Configuration changes after install

#### dconf-editor changes
###### /org/mate/panel/menubar/icon-name
> arch-24 (copy icons to /home/*user*/.icons/)

###### /org/gnome/login-screen/banner-message-text
> Set if you want

###### /org/mate/desktop/interface
> Set themes

###### /org/mate/caja/preferences
> always-use-location-entry: on

###### /org/mate/power-manager
> backlight-battery-reduce: off

> button-lid-ac: nothing

> button-lid-battery: nothing

> button-power: interactive

> button-suspend: nothing

> idle-dim-battery: off

#### Set MATE defaults
###### mate-default-applications-properties

#### Set Keyboard Shortcuts
> Take a screenshot: Alt+F12

> (Custom) Screenshot -
> scrot-gui: Print

> (Custom) Rofi -
> rofi -show run: F2


#### Theme Settings
###### Themes
> Copy afflatus-compact theme folder to /home/*user*/.themes/

> Controls - Arc

> Windows Border - Afflatus-compact

> Icons - Paper

> Pointer - MATE

###### Localization
> sudo cp mate-panel.mo /usr/share/locale/e_US/LC_MESSAGES/mate-panel.mo

> mate-panel --replace

#### GRUB2 Config (/etc/default/grub)
###### Set font for HiDPI
> `sudo grub-mkfont --output=/boot/grub/fonts/DejaVuSansMono24.pf2 --size=24 /usr/share/fonts/TTF/DejaVuSanMono.ttf`
> GRUB_FONT="/boot/grub/fonts/DejaVuSansMono24.pf2"

###### Add a custom background (TGA, PNG, or JPG[8-bit, 256 colors, non-indexed] )
> GRUB_BACKGROUND="/boot/grub/splash1.png"

###### Show splash and suppress PCIe error messages
> GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pci=nomsi"

###### After changes, build grub.cfg
> `sudo grub-mkconfig -o /boot/grub/grub.cfg`
