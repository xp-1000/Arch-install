#!/bin/bash
# This script take one argument : the username
# This script should be run by root from the installed system
# This script is interactive for user password catching
set -euo pipefail

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

pacman -S --noconfirm sudo fontconfig wget git go
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i '/PS1=/d' /home/${1}/.bashrc
sed -i '/alias ls/d' /home/${1}/.bashrc 

su $1 -c 'mkdir /tmp/userenv'
su $1 -c 'cd /tmp/userenv && git clone https://aur.archlinux.org/vim-lightline-git.git && cd vim-lightline-git && makepkg'
pacman -U /tmp/userenv/vim-lightline-git/vim-lightline-git-*.pkg.tar.xz --noconfirm

su $1 -c 'cd /tmp/userenv && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg'
pacman -U /tmp/userenv/yay/yay-*.pkg.tar.xz --noconfirm

pacman -S thefuck --noconfirm
if ! grep -q '^# Fuck' /etc/bash.bashrc; then
  cat <<EOF >> /etc/bash.bashrc
# Fuck
#eval \$(thefuck --alias --enable-experimental-instant-mode)
eval \$(thefuck --alias)

EOF
fi

su $1 -c 'cd /tmp/userenv && git clone https://aur.archlinux.org/powerline-go-bin.git && cd powerline-go-bin && makepkg'
pacman -U /tmp/userenv/powerline-go-bin/powerline-go-bin*.pkg.tar.xz --noconfirm
if ! grep -q '^# Powerline-go' /etc/bash.bashrc; then
  cat <<EOF >> /etc/bash.bashrc
# Powerline-go
function _update_ps1() {
    #PS1="\$(powerline-go -modules venv,user,ssh,cwd,perms,git,hg,jobs,exit,root,vgo,docker -theme /etc/conf.d/powerline-go/theme.json -error \$?)"
    PS1="\$(powerline-go -modules venv,user,ssh,cwd,perms,git,hg,jobs,exit,root,vgo,docker -error \$?)"
}

if [ "\$TERM" != "linux" ] && [ -f "\$GOPATH/bin/powerline-go" ]; then
    export TERM='xterm-256color'
    PROMPT_COMMAND="_update_ps1; \$PROMPT_COMMAND"
fi

EOF
fi
#mkdir -p /etc/conf.d/powerline-go/
#cp -f $(dirname $0)/files/powerline-go/* /etc/conf.d/powerline-go/

cp -f $(dirname $0)/files/git/gitconfig /home/${1}/.gitconfig

pacman -S --noconfirm xorg-server xorg-server-common xorg-xinput xorg-xclock xorg-twm xorg-xinit xf86-video-fbdev alsa-utils
cp -f $(dirname $0)/files/xorg/* /etc/X11/xorg.conf.d/

rm -fr /tmp/userenv

mkdir /home/${1}/go /home/${1}/.local/bin
echo -e '\nGOPATH=${HOME}/go\nPATH=${PATH}:${HOME}/.local/bin/:${HOME}/go/bin' >> /home/${1}/.bashrc

echo "You need to install right video driver manually"
