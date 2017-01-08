## PURPOSE
At the beginning this is only one script created for provision archlinux and bootstrap it quickly in different environment.

Then I just wanted to automate a very basic archlinux installation mainly for personal projects testing purpose.

Over time some other scripts have added according to my needs mainly born from my different uses of archlinux like my desktop environment (kde) and my tv box (kodi). 

These scripts do not do complex tasks but this is above all an only place to find some of my tweaks or configurations for me or for other who want.

## DESCRIPTION

Scripts were splitted according to their launch conditions :

* 00-* : should be run from the official archlinux iso. (make and boot on usb then get this script and run it)
* 01-* : should be run on a fresh installation by root user.
* 02-* : should be run on a dresh installation by unprivileged user
* 03-* : should be run on a dresh installation by unprivileged user after its 02 dependance(s)

Note you can see at the begining of the 03-* scripts which 02-* scripts should be run before it.

## USAGE

1. Boot on archlinux iso
2. Initialize environment :

```sh
loadkeys fr
dhcpcd
systemctl start sshd
passwd 
```

3. Get script and run it :

```sh
pacman -Syy
pacman -S wget unzip
wget https://github.com/xp-1000/Arch-install/archive/master.zip
unzip master.zip
cd Arch-install-master
bash 00-arch-install.sh && reboot
```

## EXAMPLE

Make a tv box ready to use :

1. 00-arch-install.sh
2. 01-[driver].sh (for intel : 01-intel.sh)
3. 02-openbox.sh
4. 03-kodi.sh


## NOTES
From the beginning this automation is french oriented (french archlinux mirrors, french locale, french time ..)

I want these scripts stay simple and quickly editable and mostly easy to run. This is why it is simple bash scripts, no dependants need, just to curl it.

The script jobs are possible not the right way to do or may be this is not suited to your needs, it is often personal choices so you are free to modify as you want. I hope it could become a good help for your installations.
