#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -e
set -x
sudo pacman --noconfirm -S openbox
mkdir -p ${HOME}/.config/
cp -r /etc/xdg/openbox ${HOME}/.config/
echo "exec openbox-session" > ${HOME}/.xinitrc
cat <<EOF >> /tmp/add.txt
  <!-- Audio controls --> 
  <keybind key="XF86AudioRaiseVolume">
    <action name="Execute">
        <command>amixer set Master 5%+ unmute</command>
    </action>
  </keybind>
  <keybind key="XF86AudioLowerVolume">
    <action name="Execute">
        <command>amixer set Master 5%- unmute</command>
    </action>
  </keybind>
  <keybind key="XF86AudioMute">
    <action name="Execute">
        <command>amixer set Master toggle</command>
    </action>
   </keybind>
EOF
sed -i '/chainQuitKey/r /tmp/add.txt' ${HOME}/.config/openbox/rc.xml
rm -f /tmp/add.txt
