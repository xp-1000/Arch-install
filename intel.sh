#!/bin/bash
set -e
set -x
sudo pacman --noconfirm -S xf86-video-intel libva-intel-driver libvdpau-va-gl vdpauinfo
sudo sed -i '/^.*Device0/ s/^/#/g' /etc/X11/xorg.conf.d/20-server.conf
sudo sed -i '/^#.*ntel/ s/^#//g' /etc/X11/xorg.conf.d/20-server.conf
