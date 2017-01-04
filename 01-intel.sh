#!/bin/bash
set -e
set -x
pacman --noconfirm -S xf86-video-intel libva-intel-driver libvdpau-va-gl vdpauinfo
sed -i '/^.*Device0/ s/^/#/g' /etc/X11/xorg.conf.d/20-server.conf
sed -i '/^#.*ntel/ s/^#//g' /etc/X11/xorg.conf.d/20-server.conf
