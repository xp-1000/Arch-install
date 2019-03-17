#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -euo pipefail

set -x
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root" 1>&2
   exit 1
fi
yay -S --noconfirm plasma-meta plasma-wayland-session 
yay -S --noconfirm yakuake phonon-qt5-vlc kscreen hunspell-fr spectacle okular breeze-gtk ark
yay -S --noconfirm ttf-freefont ttf-dejavu ttf-liberation networkmanager atom cups print-manager
yay -S --noconfirm papirus-icon-theme arc-gtk-theme arc-kde kvantum-theme-arc kvantum-qt5 kde-gtk-config
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable cups-browsed.service
sudo cp /usr/lib/sddm/sddm.conf.d/default.conf /etc/sddm.conf
sudo sed -i 's/^Current=$/Current=breeze/' /etc/sddm.conf
sudo sed -i 's/^CursorTheme=$/CursorTheme=breeze_cursors/' /etc/sddm.conf
sudo sed -i 's/^Numlock=none$/Numlock=on/' /etc/sddm.conf
sudo sed -i 's/^Session=/Session=plasma.desktop/' /etc/sddm.conf
sudo sed -i "s/^User=/User=${USER}/" /etc/sddm.conf
echo "Kde environment will be start on your display to generate stock configuration"
echo "Type one key to continue when kde is run and user connected"
sleep 3
sudo systemctl start sddm
sleep 5
while ! [ -f ${HOME}/.config/plasmashellrc ]; do
  read 
done
yay -S --noconfirm firefox-kde-opensuse-bin
yay -S --noconfirm firefox-i18n-fr
mkdir -p ${HOME}/.config/autostart/
mkdir -p ${HOME}/.compose-cache/
ln -sfv /run/user/$UID/ ${HOME}/.compose-cache
cp -f $(dirname $0)/files/kde/autostart/*.desktop  $HOME/.config/autostart/
cp -f $(dirname $0)/files/kde/config/*  $HOME/.config/
cp -f $(dirname $0)/files/kde/kde4/share/config/*  $HOME/.kde4/share/config/
echo "gtk-primary-button-warps-slider=false" >> ${HOME}/.config/gtk-3.0/settings.ini
sed -i 's/^gtk-icon-theme-name=/gtk-icon-theme-name=Papirus-Dark/g' ${HOME}/.config/gtk-3.0/settings.ini
sed -i 's/^gtk-theme-name=.*/gtk-theme-name=Arc-Dark/g' ${HOME}/.config/gtk-3.0/settings.ini
sed -i 's/^gtk-icon-theme-name=.*/gtk-icon-theme-name="Papirus-Dark"/g' ${HOME}/.gtkrc-2.0
sed -i 's/^gtk-theme-name=.*/gtk-theme-name="Arc-Dark"/g' ${HOME}/.gtkrc-2.0
sed -i 's/^include .*/include "\/usr\/share\/themes\/Arc-Dark\/gtk-2.0\/gtkrc"/g' ${HOME}/.gtkrc-2.0
sed -i 's/^ksplashrc_ksplash_theme=.*/ksplashrc_ksplash_theme=com.github.varlesh.arc-dark/g' ${HOME}/.config/startupconfig
echo -e '\n[Greeter]\nTheme=com.github.varlesh.arc-dark' >> ${HOME}/.config/kscreenlockerrc
sed -i 's/^Theme=.*/Theme=Papirus-Dark/g' ${HOME}/.kde4/share/config/kdeglobals ${HOME}/.config/kdeglobals
sed -i 's/^ColorScheme=.*/ColorScheme=Arc-Dark/g' ${HOME}/.kde4/share/config/kdeglobals ${HOME}/.config/kdeglobals
sed -i 's/^widgetStyle=.*/widgetStyle=kvantum-dark/g' ${HOME}/.kde4/share/config/kdeglobals ${HOME}/.config/kdeglobals
sed -i '/^\[KDE\]/a LookAndFeelPackage=com.github.varlesh.arc-dark' ${HOME}/.kde4/share/config/kdeglobals ${HOME}/.config/kdeglobals
sed -i '/\[General\]/a\BrowserApplication[$e]=!firefox' ${HOME}/.kde4/share/config/kdeglobals ${HOME}/.config/kdeglobals
sed -i '/\[KDE\]/a\DoubleClickInterval=800\nSingleClick=true\nStartDragDist=4\nStartDragTime=500\nWheelScrollLines=3' ${HOME}/.kde4/share/config/kdeglobals  ${HOME}/.config/kdeglobals
sed -i 's/^show-on-mouse-pos=none,none,\(.*\)$/show-on-mouse-pos=Ctrl+Alt+C,none,\1/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Switch to Next Desktop=none/Switch to Next Desktop=Ctrl+Alt+Right/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Switch to Previous Desktop=none/Switch to Previous Desktop=Ctrl+Alt+Left/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Walk Through Windows (Reverse)=Alt+Shift+Backtab/Walk Through Windows (Reverse)=Alt+Shift+Tab/' ${HOME}/.config/kglobalshortcutsrc
sed -i '1i[Basic Settings]\nIndexing-Enabled=false' ${HOME}/.config/baloofilerc
sudo systemctl restart sddm.service
## kdewallet for ssh key support
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# export SSH_ASKPASS="/usr/bin/ksshaskpass"

