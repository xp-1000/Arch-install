#!/bin/bash
set -e

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
while [[ ! "$go" == "y" ]]; do
 read -p "Are you sure to continue (y/n): " -e go
done
 
# make 2 partitions on the disk.
echo -n "Partitioning ... "
parted -s ${device} mktable gpt
parted -s ${device} mkpart primary 0% 100m
parted -s ${device} mkpart primary 100m ${endPart}m
parted -s ${device} mkpart primary ${endPart}m 100%
echo "OK"


# make filesystems
echo -n "Creating file system ... "
# /boot
mkfs.ext4 '-O ^64bit' ${device}1 > /dev/null 2>&1
# swap
mkswap ${device}2 > /dev/null 2>&1
# /
mkfs.ext4 ${device}3 > /dev/null 2>&1
echo "OK"

# set up /mnt
echo -n "Mounting partitions ... "
mount ${device}3 /mnt
mkdir /mnt/boot
mount ${device}1 /mnt/boot
# set up swap
swapon ${device}2
echo "OK"
 
# rankmirrors to make this faster (though it takes a while)
echo -n "Ranking repository mirrors ... "
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
rankmirrors -n 6 /etc/pacman.d/mirrorlist.orig >/etc/pacman.d/mirrorlist
echo "OK"

# Update database
echo "Updating repository database ... "
pacman -Syy
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
 
# set initial locale
echo "fr_FR.UTF-8 UTF-8" >>/etc/locale.gen
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
syslinux-install_update -i -a -m 2> /dev/null
 
# update syslinux config with correct root diskyaou				
uuid=$(blkid -o value -s UUID ${device}3)
sed -i "s/root=.*/root=UUID=${uuid} rw/" /boot/syslinux/syslinux.cfg

#cp /usr/lib/syslinux/menu.c32 /boot/syslinux
#cp /usr/lib/syslinux/hdt.c32 /boot/syslinux
#cp /usr/lib/syslinux/reboot.c32 /boot/syslinux
#cp /usr/lib/syslinux/poweroff.com /boot/syslinux
#extlinux --install /boot/syslinux

# Set flag boot disk for GPT
dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/bios/gptmbr.bin of=${device}

# set root password to "root"
echo root:azer | chpasswd

# Set initial configuration
echo -n "Quick basic configuration ... "
mv -f "`dirname $0`/bash.bashrc" /etc
mv -f "`dirname $0`/profile" /etc
sed -i -e 's/TIMEOUT 50/TIMEOUT 10/' /boot/syslinux/syslinux.cfg
echo -e '\n[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/$arch\n' >> /etc/pacman.conf
pacman -Syu
pacman -S vim --noconfirm
pacman -S openssh --noconfirm
systemctl enable sshd
pacman -S yaourt --noconfirm

# end section sent to chroot
EOF
 
# unmount
umount /mnt/{boot,}
swapoff ${device}2

# Set Flag boot BIOS for GTP
sgdisk ${device} --attributes=:1:set:2
 
echo "Done! Unmount the CD image from the VM, then type 'reboot'."
