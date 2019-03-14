#!/bin/bash
# This script should be run after internet configuration from archlinux iso
set -e
set -x

# confirm you can access the internet
echo -n "Testing Internet connection ... "
ping -q -w 1 -c 1 google.fr > /dev/null && echo "OK" || (echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue." && read)

# Get total memory to define swap file sizing 
memSize=$(free|awk '/^Mem:/{print $2}')
memSwap=$(echo $memSize | sed -e "s/M//")
if [[ $memSwap -ge 4096 ]]
then 
  memSwap=4096
fi

device=
fdisk -l | grep '^Disk[[:space:]]*/' | grep -v loop
while [[ ! -b $device ]]; do
  read -p "Type your device path (e.g. /dev/sda): " -e device
done
echo -e "\033[0;31m/!\ Warning : $device will be totally erased !\033[0m"
while ! ([[ "$go" == "y" ]] || [[ "$go" == "n" ]]); do
 read -p "Are you sure to continue ? (y/n): " -e go
done
if [[ $go == "n" ]]; then
  exit 1
fi

suffix=""
if [[ "${device}" == *"nvme"* ]];
  then suffix="p"
fi
 
# erase disk
echo -n "Erase disk ... "
sgdisk --zap-all ${device}
echo "OK"
# make partitions on the disk.
echo -n "Partitioning ... "
sgdisk --new=0:0:+512MiB ${device}
sgdisk --change-name=1:ESP ${device}
sgdisk --typecode=1:EF00 ${device}
sgdisk --new=0:0:0 ${device}
sgdisk --change-name=2:SYSTEM ${device}
sgdisk --typecode=2:8300 ${device}
partprobe ${device}
echo "OK"

# make filesystems
echo -n "Creating file system ... "
# /boot
mkfs.fat -F32 ${device}${suffix}1
# /
mkfs.ext4 -Fv ${device}${suffix}2
echo "OK"

uuid=$(blkid -o value -s UUID ${device}${suffix}2)

# set up /mnt
echo -n "Mounting partitions ... "
mount ${device}${suffix}2 /mnt
mkdir /mnt/boot
mount ${device}${suffix}1 /mnt/boot
echo "OK"

# Update database
echo "Updating repository database ... "
pacman -Syy
pacman -S wget unzip pacman-contrib --noconfirm

# rankmirrors to make this faster (though it takes a while)
echo -n "Ranking repository mirrors ... "
pacman -S --noconfirm pacman-mirrorlist
cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
wget --no-check-certificate "https://www.archlinux.org/mirrorlist/?country=FR&country=DE&country=IT&protocol=http&ip_version=4" -O /etc/pacman.d/mirrorlist.new
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.new
rankmirrors -n 6 /etc/pacman.d/mirrorlist.new > /etc/pacman.d/mirrorlist
echo "OK"

# Install keys for archlinux packages
pacman -S --noconfirm archlinux-keyring 

echo "Installing ArchLinux ... "
# install base packages (take a coffee break if you have slow internet)
pacstrap /mnt base base-devel
 
# copy ranked mirrorlist over
cp /etc/pacman.d/mirrorlist* /mnt/etc/pacman.d
 
# generate fstab
genfstab -p -U /mnt >> /mnt/etc/fstab
 
# chroot
arch-chroot /mnt /bin/bash <<EOF
 
# set up swap
fallocate -l ${memSwap}M /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo -e "# Swap\n/swapfile\t\tnone\t\tswap\t\tdefaults\t0 0" >> /etc/fstab

# set initial hostname
echo "archlinux-$(date -I)" >/etc/hostname
 
# set initial timezone to America/Los_Angeles
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
# set hw clock on utc
hwclock --systohc --utc
 
# set initial locale
echo "fr_FR.UTF-8 UTF-8" >>/etc/locale.gen
echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
echo "fr_FR ISO-8859-1" >>/etc/locale.gen
locale-gen
#locale >/etc/locale.conf
#sed -i -e 's/LANG="en_US/LANG="fr_FR/' /etc/locale.conf
echo 'LANG="fr_FR.UTF-8"' > /etc/locale.conf

# set keymap
echo "KEYMAP=fr-pc" > /etc/vconsole.conf

# install systemd-boot
bootctl --path=/boot install
cp /usr/share/systemd/bootctl/loader.conf /boot/loader/loader.conf
echo "timeout 1" >> /boot/loader/loader.conf
cat <<EOC > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=${uuid} rw
EOC

# microcode management
if lscpu | grep -qi intel; then
  manufacturer="intel"
elif lscpu | grep -qi amd; then
  manufacturer="amd"
fi
if ! [ -z ${manufacturer} ]; then
  pacman -S ${manufacturer}-ucode --noconfirm
  sed -i "/^linux.*\/vm/a initrd  /${manufacturer}-ucode.img" /boot/loader/entries/arch.conf
fi

# no modifications to mkinitcpio.conf should be needed
mkinitcpio -p linux
 
# set root password to "root"
echo root:azer | chpasswd

# Set initial configuration
echo -n "Quick basic configuration ... "
echo -e '\n[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch\n' >> /etc/pacman.conf
pacman -Syu
pacman -S pacman --noconfirm
pacman -S vim bash-completion colordiff lsb-release --noconfirm
pacman -S openssh ntp --noconfirm
systemctl enable sshd
systemctl enable ntpd

# end section sent to chroot
EOF

# Add default bashrc and profile files
if ! grep -q '### Tweaks bashrc' /mnt/etc/bash.bashrc; then
  cat `dirname $0`/files/bash/bash.bashrc >> /mnt/etc/bash.bashrc
fi
cp -f `dirname $0`/files/bash/profile/* /mnt/etc/profile.d/
 
while ! ([[ "$wifi" == "y" ]] || [[ "$wifi" == "n" ]]); do
 read -p "Do you want install wifi support ? (y/n): " -e wifi
done
if [[ $wifi == "y" ]]; then
  pacstrap /mnt dialog wpa_supplicant
fi
 
# unmount
umount /mnt/{boot,}
 
echo "Done! Unmount the CD image from the VM, then type 'reboot'."
echo -e "\033[0;31m/!\ Password for root authentification is 'azer'\033[0m"

