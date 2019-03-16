#!/bin/bash
set -euo pipefail

pacman --noconfirm -S mesa xf86-video-intel vulkan-intel libva-intel-driver libvdpau-va-gl vdpauinfo
