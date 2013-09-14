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
 
# make 2 partitions on the disk.
echo -n "Partitioning ... "
parted -s /dev/sda mktable gpt
parted -s /dev/sda mkpart primary 0% 100m
parted -s /dev/sda mkpart primary 100m ${endPart}m
parted -s /dev/sda mkpart primary ${endPart}m 100%
echo "OK"


# make filesystems
echo -n "Creating file system ... "
# /boot
mkfs.ext4 /dev/sda1 > /dev/null 2>&1
# swap
mkswap /dev/sda2 > /dev/null 2>&1
# /
mkfs.ext4 /dev/sda3 > /dev/null 2>&1
echo "OK"

# set up /mnt
echo -n "Mounting partitions ... "
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
# set up swap
swapon /dev/sda2
echo "OK"
 
# rankmirrors to make this faster (though it takes a while)
echo -n "Ranking repository mirrors ... "
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
rankmirrors -n 6 /etc/pacman.d/mirrorlist.orig >/etc/pacman.d/mirrorlist
echo "OK"

# Update database
echo "Updating repository database ... "
pacman -Syy

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
genfstab -p /mnt >> /mnt/etc/fstab
 
# chroot
arch-chroot /mnt /bin/bash <<'EOF'
 
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
#syslinux-install_update -i -a -m
 
# update syslinux config with correct root diskyaou				

#sed 's/root=.*/root=\/dev\/sda3 ro/' < /boot/syslinux/syslinux.cfg > /boot/syslinux/syslinux.cfg.new
#mv /boot/syslinux/syslinux.cfg.new /boot/syslinux/syslinux.cfg

cp /usr/lib/syslinux/menu.c32 /boot/syslinux
cp /usr/lib/syslinux/hdt.c32 /boot/syslinux
cp /usr/lib/syslinux/reboot.c32 /boot/syslinux
cp /usr/lib/syslinux/poweroff.com /boot/syslinux
extlinux --install /boot/syslinux

# Set flag boot disk for GPT
dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/gptmbr.bin of=/dev/sda

# set root password to "root"
echo root:azer | chpasswd

# Set initial configuration
echo -n "Quick general configuration ... "
echo "export EDITOR=vim" >> /etc/profile
echo "alias vi='vim'" >> /etc/bash.bashrc
echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf
pacman -Syu
pacman -S vim --noconfirm
pacman -S openssh --noconfirm
systemctl enable sshd
pacman -S yaourt --noconfirm

# end section sent to chroot
EOF
 
# unmount
umount /mnt/{boot,}
swapoff /dev/sda2

# Set Flag boot BIOS for GTP
sgdisk /dev/sda --attributes=:1:set:2
 
echo "Done! Unmount the CD image from the VM, then type 'reboot'."