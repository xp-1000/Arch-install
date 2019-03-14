#!/bin/bash
set -e
set -x
pacman --noconfirm -S mesa xf86-video-intel vulkan-intel libva-intel-driver libvdpau-va-gl vdpauinfo
