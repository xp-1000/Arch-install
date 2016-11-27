#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -x
set -e
sudo pacman --noconfirm -S ttf-freefont ttf-dejavu ttf-liberation
sudo pacman --noconfirm -S sakura samba
sudo usermod -a -G audio,video,users,storage,disk,wheel $USER
sed "s/USER/$USER/g" ./files/samba/smb.conf > /etc/samba/smb.conf
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
yaourt -S --noconfirm kodi-addon-pvr-iptvsimple-git
echo "kodi &" >> ${HOME}/.config/openbox/autostart 
echo "sakura &" >> ${HOME}/.config/openbox/autostart 
yaourt --noconfirm -S google-chrome
ln -sf /usr/bin/google-chrome-* /usr/bin/google-chrome
sudo pacman --noconfirm -S python-xdg python2-xdg xdg-utils
#STEAM
sudo sed -e '/^#\[multilib\]/,+1 s/^#//g' /etc/pacman.conf
sudo pacman -Syy
sudo pacman --noconfirm -S steam steam-native-runtime pulseaudio wmctrl libxcb 
sudo pacman --noconfirm -S lib32-openal lib32-nss lib32-gtk2 lib32-gtk3 lib32-libcanberra lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-libudev0-shim lib32-alsa-plugins lib32-libpulse lib32-libxcb lib32-curl
wget http://tv.manfroi.fr/res/kodi-backup.zip -O /tmp/kodi-backup.zip
rm -fr ${HOME}/.kodi
mkdir -p ${HOME}/.kodi
unzip /tmp/kodi-backup.zip -d ${HOME}/.kodi/
folder=$(ls ${HOME}/.kodi/ | sort | head -n 1)
mv ${HOME}/.kodi/${folder}* ${HOME}/.kodi/
rm -fr ${HOME}/.kodi/${folder}
