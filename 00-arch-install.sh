#!/bin/bash
# This script should be run after internet configuration from archlinux iso
set -e
set -x

# confirm you can access the internet
echo -n "Testing Internet connection ... "
ping -q -w 1 -c 1 google.fr > /dev/null && echo "OK" || (echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue." && read)
# if [[ ! $(curl -Is http://www.google.com/ | head -n 1) =~ "200 OK" ]]; then
	# echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue."
	# read
# fi

# Get total memory to define swap partition sizing 
memSize=$(free|awk '/^Mem:/{print $2}')
memSwap=$(echo $memSize | sed -e "s/M//")
if [[ $memSwap -ge 4096 ]]
then 
	memSwap=4096
fi
endPart=$((memSwap+100))
device=
fdisk -l
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
 
# make 2 partitions on the disk.
echo -n "Partitioning ... "
parted -s ${device} mktable gpt
parted -s ${device} mkpart primary 0% 100m
parted -s ${device} mkpart primary 100m ${endPart}m
parted -s ${device} mkpart primary ${endPart}m 100%
partprobe ${device}
echo "OK"

# make filesystems
echo -n "Creating file system ... "
# /boot
mkfs.ext4 -Fv '-O ^64bit' ${device}1 
# swap
mkswap ${device}2 
# /
mkfs.ext4 -Fv ${device}3 
echo "OK"

# set up /mnt
echo -n "Mounting partitions ... "
mount ${device}3 /mnt
mkdir /mnt/boot
mount ${device}1 /mnt/boot
# set up swap
swapon ${device}2
echo "OK"
 
uuid=$(blkid -o value -s UUID ${device}3)
uuidSwap=$(blkid -o value -s UUID ${device}2)

# Update database
echo "Updating repository database ... "
pacman -Syy
pacman -S wget unzip --noconfirm

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
 
# install syslinux
#arch-chroot /mnt pacman -S syslinux --noconfirm
echo "Installing Syslinux bootloader ... "
pacstrap /mnt syslinux
 
# copy ranked mirrorlist over
cp /etc/pacman.d/mirrorlist* /mnt/etc/pacman.d
 
# generate fstab
genfstab -p -U /mnt >> /mnt/etc/fstab
 
# chroot
arch-chroot /mnt /bin/bash <<EOF
 
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

# no modifications to mkinitcpio.conf should be needed
mkinitcpio -p linux
 
# install syslinux bootloader
pacman -S --noconfirm gptfdisk
syslinux-install_update -i -a -m 2> /dev/null
 
# update syslinux config with correct root diskyaou				
sed -i "s/root=.*/root=UUID=${uuid} resume=UUID=${uuidSwap} rw/g" /boot/syslinux/syslinux.cfg

#cp /usr/lib/syslinux/menu.c32 /boot/syslinux
#cp /usr/lib/syslinux/hdt.c32 /boot/syslinux
#cp /usr/lib/syslinux/reboot.c32 /boot/syslinux
#cp /usr/lib/syslinux/poweroff.com /boot/syslinux
#extlinux --install /boot/syslinux

# Set flag boot disk for GPT
#dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/bios/gptmbr.bin of=${device}

# set root password to "root"
echo root:azer | chpasswd

# Set initial configuration
echo -n "Quick basic configuration ... "
sed -i -e 's/TIMEOUT 50/TIMEOUT 10/' /boot/syslinux/syslinux.cfg
echo -e '\n[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch\n' >> /etc/pacman.conf
pacman -Syu
pacman -S pacman --noconfirm
pacman -S vim yaourt bash-completion colordiff lsb-release --noconfirm
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
swapoff ${device}2

# Set Flag boot BIOS for GTP
sgdisk ${device} --attributes=:1:set:2
 
echo "Done! Unmount the CD image from the VM, then type 'reboot'."
echo -e "\033[0;31m/!\ Password for root authentification is 'azer'\033[0m"

