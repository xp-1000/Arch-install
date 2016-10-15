#!/bin/bash
sudo pacman -S --noconfirm plasma kdebase kde-l10n-fr 
sudo pacman -S --noconfirm yakuake phonon-qt4-vlc phonon-qt5-vlc kscreen hunspell-fr spectacle kdegraphics-okular breeze-gtk ark
sudo pacman -Rsn --noconfirm plasma-mediacenter kdebase-konqueror kdebase-konq-plugins kate 
sudo pacman -S --noconfirm ttf-freefont ttf-dejavu ttf-liberation networkmanager atom
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo sed -i 's/^Current=$/Current=breeze/'
sudo sed -i 's/^Numlock=none$/Numlock=on/'
mkdir ${HOME}/.compose-cache/
ln -sfv /run/user/$UID/ /home/$USER/.compose-cache
echo -e '\n[Windows]\nBorderlessMaximized=true' >> ${HOME}/.config/kwinrc
yaourt -S --noconfirm firefox-kde-opensuse
pacman -S firefox-i18n-fr
systemctl start sddm
