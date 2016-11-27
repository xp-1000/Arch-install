#!/bin/bash
# This script take one argument : the username
# This script should be run by root from the installed system
# This script is interactive for user password catching
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
if [[ $# -eq 0 ]]; then
  echo "Please provide your ursername with arg"
  exit 1
fi
useradd -m -G wheel -s /bin/bash $1
echo "Please type your password"
passwd $1
pacman -S --noconfirm sudo fontconfig
pacman -S --noconfirm powerline powerline-common powerline-fonts 
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i '/PS1=/d' /home/${1}/.bashrc
sed -i '/alias ls/d' /home/${1}/.bashrc 
if ! grep -q '# Powerline' /etc/bash.bashrc; then
  cat <<EOF >> /etc/bash.bashrc
# Powerline 
export TERM='xterm-256color'
export XDG_CONFIG_DIRS='/etc/conf.d'
if [ -f /usr/lib/python3.[5-9]/site-packages/powerline/bindings/bash/powerline.sh ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source /usr/lib/python3.[5-9]/site-packages/powerline/bindings/bash/powerline.sh
fi
EOF
fi
mkdir -p /etc/conf.d/powerline/
cat <<EOF > /etc/conf.d/powerline/config.json
{
    "ext": {
        "shell": {
            "theme": "default_leftonly"
        }
    }
}
EOF
pacman -S --noconfirm xorg-server xorg-server-utils xorg-xinput xorg-xclock xorg-twm xorg-xinit xf86-video-fbdev alsa-utils
cp -f `dirname $0`/files/xorg/* /etc/X11/xorg.conf.d/
echo "You need to install right video driver manually"
#echo "Installing generic vesa driver"
#yaourt -S --noconfirm xf86-video-vesa
