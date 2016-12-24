#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -x
set -e
sudo pacman --noconfirm -S ttf-freefont ttf-dejavu ttf-liberation
sudo pacman --noconfirm -S sakura samba xarchiver pcmanfm unzip zip p7zip unrar numlockx
sed "s/USER/$USER/g" ./files/samba/smb.conf | sudo tee /etc/samba/smb.conf
sudo systemctl enable smbd
sudo systemctl enable nmbd
sudo systemctl enable dhcpcd
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
echo "kodi &" >> ${HOME}/.config/openbox/autostart 
echo "sakura &" >> ${HOME}/.config/openbox/autostart 
echo "numlockx &" >> ${HOME}/.config/openbox/autostart 
sudo pacman --noconfirm -S firefox firefox-i18n-fr
tar xvzf `dirname $0`/files/ui/firefox.tar.gz -C ${HOME}
echo "MOZ_DISABLE_GMP_SANDBOX=1 firefox" | sudo tee /etc/environment
yaourt --noconfirm -S google-chrome
sudo ln -sf /usr/bin/google-chrome-* /usr/bin/google-chrome
sudo pacman --noconfirm -S python-xdg python2-xdg xdg-utils
#STEAM
sudo sed -ie '/^#\[multilib\]/,+1 s/^#//g' /etc/pacman.conf
sudo pacman -Syy
sudo pacman --noconfirm -S steam steam-native-runtime pulseaudio wmctrl libxcb 
sudo pacman --noconfirm -S lib32-openal lib32-nss lib32-gtk2 lib32-gtk3 lib32-libcanberra lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-libudev0-shim lib32-alsa-plugins lib32-libpulse lib32-libxcb lib32-curl
wget http://tv.manfroi.fr/res/kodi-kiwisbox.tar.gz -O /tmp/kodi-backup.tar.gz
rm -fr ${HOME}/.kodi
tar xvzf /tmp/kodi-backup.tar.gz -C ${HOME}
mkdir -p ${HOME}/{Videos/Series,Videos/Films,Musique,Images/Wallpapers,Telechargements/Films,Telechargements/Series}
set +e
#cd && wget "$(curl -s https://api.github.com/repos/scakemyer/plugin.video.quasar/releases | grep browser_download_url | grep linux_x64 | head -n 1 | cut -d '"' -f 4)"
wget -r --accept "*.gif" --accept "*.jpg" http://tv.manfroi.fr/res/backgrounds
mv tv.manfroi.fr/res/backgrounds/* ${HOME}/Images/Wallpapers/
rm -fr tv.manfroi.fr
