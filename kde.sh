#!/bin/bash
sudo pacman -S --noconfirm plasma kdebase kde-l10n-fr 
sudo pacman -S --noconfirm yakuake phonon-qt4-vlc phonon-qt5-vlc kscreen hunspell-fr spectacle kdegraphics-okular breeze-gtk ark
sudo pacman -Rsn --noconfirm plasma-mediacenter kdebase-konqueror kdebase-konq-plugins kate 
sudo pacman -S --noconfirm ttf-freefont ttf-dejavu ttf-liberation networkmanager atom cups print-manager
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable cups-browsed.service
sudo sed -i 's/^Current=$/Current=breeze/' /etc/sddm.conf
sudo sed -i 's/^CursorTheme=$/CursorTheme=breeze_cursors/' /etc/sddm.conf
sudo sed -i 's/^Numlock=none$/Numlock=on/' /etc/sddm.conf
mkdir ${HOME}/.compose-cache/
ln -sfv /run/user/$UID/ /home/$USER/.compose-cache
echo -e '\n[Windows]\nBorderlessMaximized=true' >> ${HOME}/.config/kwinrc
yaourt -S --noconfirm firefox-kde-opensuse
pacman -S --noconfirm firefox-i18n-fr
mv -f "`dirname $0`/files/kde/autostart/*.desktop"  $HOME/.config/autostart/
sudo systemctl start sddm.service
# themes arc 
# shortcuts + reglages kde generaux ?
# terraform  + restaurer le backup firefox et cie

