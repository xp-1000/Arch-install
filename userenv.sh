#!/bin/bash
if [[ $# -eq 0 ]]; then
  echo "Please provide your ursername with arg"
  exit 1
fi
useradd -m -G wheel -s /bin/bash $1
passwd $1
pacman -S --noconfirm sudo bash-completion
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
pacman -S --noconfirm xorg-server xorg-server-utils xorg-xinput xorg-xclock xorg-twm
cp -f "`dirname $0`/files/xorg/*" /etc/X11/xorg.conf.d/
echo "You need to install right video driver manually"
