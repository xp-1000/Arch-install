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
pacman -S --noconfirm sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i '/PS1=/d' /home/${1}/.bashrc
sed -i '/alias ls/d' /home/${1}/.bashrc 
pacman -S --noconfirm xorg-server xorg-server-utils xorg-xinput xorg-xclock xorg-twm
cp -f "`dirname $0`/files/xorg/*" /etc/X11/xorg.conf.d/
echo "You need to install right video driver manually"
