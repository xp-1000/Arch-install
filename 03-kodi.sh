#!/bin/bash
# This script should be run by unprivileged user from the installed system
# This script depends on 02-openbox.sh which should be run before.
set -x
set -e
sudo pacman --noconfirm -S ttf-freefont ttf-dejavu ttf-liberation
sudo pacman --noconfirm -S sakura samba xarchiver pcmanfm unzip zip p7zip unrar numlockx pavucontrol
# Wifi support
sudo pacman --noconfirm -S tint2 networkmanager network-manager-applet gnome-keyring adwaita-icon-theme dunst
# Volume support 
sudo pacman --noconfirm -S pulseaudio pulseaudio-alsa volumeicon
pulseaudio --start
# xkill
sudo pacman --noconfirm -S xorg-xkill
# Battery
sudo pacman --noconfirm -S cbatticon
sudo sed -i '/NOPASSWD/s/^# //g' /etc/sudoers 
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sed "s/USER/$USER/g" ./files/samba/smb.conf | sudo tee /etc/samba/smb.conf
sudo systemctl enable smbd
sudo systemctl start smbd
sudo systemctl enable nmbd
sudo systemctl start nmbd
sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd
#KODI
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
[Service]
Type=simple
ExecStart=
ExecStart=-/usr/bin/agetty --autologin kiwis --noclear %I \$TERM
EOF
sudo cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/noclear.conf > /dev/null
[Service]
TTYVTDisallocate=no
EOF
cat <<EOF >> ${HOME}/.bash_profile
if [ -z "\$DISPLAY" ] && [ \$(tty) == /dev/tty1 ]; then
    startx
fi
EOF
sudo pacman --noconfirm -S kodi
yaourt --noconfirm -S kodi-addon-pvr-iptvsimple-git
cp -f cp -f `dirname $0`/files/openbox/dunstrc ${HOME}/.config/
mkdir -p ${HOME}/.config/tint2
cp -f cp -f `dirname $0`/files/openbox/tint2rc ${HOME}/.config/tint2/
echo "kodi &" >> ${HOME}/.config/openbox/autostart 
echo "numlockx &" >> ${HOME}/.config/openbox/autostart 
echo "dunst &" >> ${HOME}/.config/openbox/autostart 
echo "tint2 &" >> ${HOME}/.config/openbox/autostart 
echo "nm-applet &" >> ${HOME}/.config/openbox/autostart 
echo "volumeicon &" >> ${HOME}/.config/openbox/autostart 
echo "cbatticon &" >> ${HOME}/.config/openbox/autostart 
sed -i 's/<number>4/<number>2/' ${HOME}/.config/openbox/rc.xml
sudo pacman --noconfirm -S firefox firefox-i18n-fr
tar xvzf `dirname $0`/files/ui/firefox.tar.gz -C ${HOME}
echo "MOZ_DISABLE_GMP_SANDBOX=1 firefox" | sudo tee /etc/environment
yaourt --noconfirm -S google-chrome
sudo ln -sf /usr/bin/google-chrome-* /usr/bin/google-chrome
sudo pacman --noconfirm -S python-xdg python2-xdg xdg-utils
#STEAM
sudo sed -ie '/^#\[multilib\]/,+1 s/^#//g' /etc/pacman.conf
sudo pacman -Syy
sudo pacman --noconfirm -S steam steam-native-runtime wmctrl libxcb 
sudo pacman --noconfirm -S lib32-openal lib32-nss lib32-gtk2 lib32-gtk3 lib32-libcanberra lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-libudev0-shim lib32-alsa-plugins lib32-libpulse lib32-libxcb lib32-curl
wget http://tv.manfroi.fr/res/kodi-kiwisbox.tar.gz -O /tmp/kodi-backup.tar.gz
sudo gpasswd -a ${USER} polkitd
rm -fr ${HOME}/.kodi
tar xvzf /tmp/kodi-backup.tar.gz -C ${HOME}
mkdir -p ${HOME}/{Videos/Series,Videos/Films,Musique,Images/Wallpapers,Téléchargements/Films,Téléchargements/Series,Documents/Sauvegarde}
set +e
#cd && wget "$(curl -s https://api.github.com/repos/scakemyer/plugin.video.quasar/releases | grep browser_download_url | grep linux_x64 | head -n 1 | cut -d '"' -f 4)"
wget -r --accept "*.gif" --accept "*.jpg" http://tv.manfroi.fr/res/backgrounds
mv tv.manfroi.fr/res/backgrounds/* ${HOME}/Images/Wallpapers/
rm -fr tv.manfroi.fr
