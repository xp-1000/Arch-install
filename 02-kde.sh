#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -x
set -e
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root" 1>&2
   exit 1
fi
yaourt -S --noconfirm plasma kdebase kde-l10n-fr 
yaourt -S --noconfirm yakuake phonon-qt4-vlc phonon-qt5-vlc kscreen hunspell-fr spectacle kdegraphics-okular breeze-gtk ark
yaourt -Rsn --noconfirm kdebase-konqueror kdebase-konq-plugins kate 
yaourt -S --noconfirm ttf-freefont ttf-dejavu ttf-liberation networkmanager atom cups print-manager
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable cups-browsed.service
sudo sed -i 's/^Current=$/Current=breeze/' /etc/sddm.conf
sudo sed -i 's/^CursorTheme=$/CursorTheme=breeze_cursors/' /etc/sddm.conf
sudo sed -i 's/^Numlock=none$/Numlock=on/' /etc/sddm.conf
sudo sed -i 's/^Session=/Session=plasma.desktop/' /etc/sddm.conf
sudo sed -i "s/^User=/User=$1/" /etc/sddm.conf
echo "Kde environment will be start on your display to generate stock configuration"
echo "Type one key to continue when kde is run and user connected"
sleep 3
sudo systemctl start sddm
sleep 5
while ! [ -f $HOME/.config/plasmashellrc ]; do
  read 
done
yaourt -S --noconfirm firefox-kde-opensuse
yaourt -S --noconfirm firefox-i18n-fr
mkdir -p $HOME/.config/autostart/
mkdir -p ${HOME}/.compose-cache/
ln -sfv /run/user/$UID/ /home/$USER/.compose-cache
cp -f `dirname $0`/files/kde/autostart/*.desktop  $HOME/.config/autostart/
cp -f `dirname $0`/files/kde/config/*  $HOME/.config/
cp -f `dirname $0`/files/kde/kde4/share/config/*  $HOME/.kde4/share/config/
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
sed -i 's/Switch to Previous Desktop=none/Switch to Previous Desktop=Ctrl+Alt+Left/' ${HOME}/.config/kglobalshortcutsrc
sed -i 's/Walk Through Windows (Reverse)=Alt+Shift+Backtab/Walk Through Windows (Reverse)=Alt+Shift+Tab/' ${HOME}/.config/kglobalshortcutsrc
sudo systemctl restart sddm.service
# themes arc kde
# shortcuts kde
## kdewallet for ssh key support
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# export SSH_ASKPASS="/usr/bin/ksshaskpass"

