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
yaourt -S --noconfirm firefox-kde-opensuse
pacman -S --noconfirm firefox-i18n-fr
cp -f "`dirname $0`/files/kde/autostart/*.desktop"  $HOME/.config/autostart/
cp -f "`dirname $0`/files/kde/config/*"  $HOME/.config/
cp -f "`dirname $0`/files/kde/kde4/share/config/*"  $HOME/.kde4/share/config/
mkdir ${HOME}/.compose-cache/
ln -sfv /run/user/$UID/ /home/$USER/.compose-cache
echo -e '\n[Windows]\nBorderlessMaximized=true' >> ${HOME}/.config/kwinrc
echo "gtk-primary-button-warps-slider=false" >> ${HOME}/.config/gtk-3.0/settings.ini
cat <<EOF >  ${HOME}/.config/kscreenlockerrc
[Daemon]
LockGrace=30
Timeout=15
EOF
cat <<EOF >  ${HOME}/.config/plasma-localerc
[Translations]
LANGUAGE=fr
EOF
cat <<EOF >  ${HOME}/.config/systemsettingsrc
[Basic Settings]
Indexing-Enabled=false
EOF
sed -i '1i[Basic Settings]\nIndexing-Enabled=false' ${HOME}/.config/baloofilerc
sed -i '/\[General\]/a\BrowserApplication[$e]=!firefox' ${HOME}/.kde4/share/config/kdeglobals
sed -i '/\[General\]/a\BrowserApplication[$e]=!firefox' ${HOME}/.config/kdeglobals
sed -i '/\[KDE\]/a\DoubleClickInterval=800\nSingleClick=true\nStartDragDist=4\nStartDragTime=500\nWheelScrollLines=3' ${HOME}/.config/kdeglobals
sed -i 's/^loginMode.*$/loginMode=default/' ${HOME}/.config/ksmserverrc
sed -i 's/Switch to Next Desktop=none/Switch to Next Desktop=Ctrl+Alt+Right/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Switch to Previous Desktop=none/Switch to Previous Desktop=Ctrl+Left+Right/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Walk Through Windows (Reverse)=Alt+Shift+Backtab/Walk Through Windows (Reverse)=Alt+Shift+Tab/' ${HOME}/.config/kglobalshortcutsrc


sudo systemctl start sddm.service
# themes arc 
# shortcuts 

