#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -e
set -x
sudo usermod -a -G audio,video,users,storage,disk,power,wheel $USER
sudo pacman --noconfirm -S openbox gmrun
yaourt -S libaosd --noconfirm
sudo cp -f `dirname $0`/files/openbox/osd.sh /usr/local/bin/
sudo cp -f `dirname $0`/files/openbox/restart-openbox.sh /usr/local/bin/
mkdir -p ${HOME}/.config/
cp -r /etc/xdg/openbox ${HOME}/.config/
echo "exec openbox-session" > ${HOME}/.xinitrc
cp -f `dirname $0`/files/openbox/autostart ${HOME}/.config/openbox/autostart 
cp -f `dirname $0`/files/openbox/rc.xml ${HOME}/.config/openbox/rc.xml
