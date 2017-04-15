#!/bin/bash
# This script should be run by unprivileged user from the installed system
set -e
set -x
sudo usermod -a -G audio,video,users,storage,disk,power,wheel $USER
sudo pacman --noconfirm -S openbox gmrun
yaourt -S libaosd --noconfirm
sudo cp -f `dirname $0`/files/openbox/osd-mixer.sh /usr/local/bin/
sudo cp -f `dirname $0`/files/openbox/restart-openbox.sh /usr/local/bin/
mkdir -p ${HOME}/.config/
cp -r /etc/xdg/openbox ${HOME}/.config/
echo "exec openbox-session" > ${HOME}/.xinitrc
cat <<EOF >> /tmp/add.txt
  <!-- Custom controls --> 
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
  <keybind key="A-C-Delete">
    <action name="Execute">
      <command>restart-openbox.sh</command>
    </action>
  </keybind>
  <keybind key="A-F5">
    <action name="Execute">
      <command>sudo xkill -button 1</command>
    </action>
  </keybind>
  <keybind key="A-F2">
    <action name="Execute">
      <command>gmrun</command>
    </action>
  </keybind>
  <keybind key="A-k">
    <action name="Execute">
      <command>bash -c 'sudo pkill -9 kodi ; kodi'</command>
    </action>
  </keybind>
EOF
sed -i '/chainQuitKey/r /tmp/add.txt' ${HOME}/.config/openbox/rc.xml
rm -f /tmp/add.txt
