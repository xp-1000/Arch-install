#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -e
set -x
sudo usermod -a -G audio,video,users,storage,disk,power,wheel $USER
sudo pacman --noconfirm -S openbox
yaourt -S libaosd --noconfirm
sudo cp -f `dirname $0`/files/openbox/osd-mixer.sh /usr/local/bin/
mkdir -p ${HOME}/.config/
cp -r /etc/xdg/openbox ${HOME}/.config/
echo "exec openbox-session" > ${HOME}/.xinitrc
cat <<EOF >> /tmp/add.txt
  <!-- Audio controls --> 
  <keybind key="XF86AudioRaiseVolume">
    <action name="Execute">
        <command>osd-mixer.sh volup</command>
    </action>
  </keybind>
  <keybind key="XF86AudioLowerVolume">
    <action name="Execute">
        <command>osd-mixer.sh voldown</command>
    </action>
  </keybind>
  <keybind key="XF86AudioMute">
    <action name="Execute">
        <command>osd-mixer.sh mute</command>
    </action>
   </keybind>
EOF
sed -i '/chainQuitKey/r /tmp/add.txt' ${HOME}/.config/openbox/rc.xml
rm -f /tmp/add.txt
