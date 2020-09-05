#!/bin/bash

kern_path=/home/nf/git/linux_xilinx
deb_root=$PWD/root/
sd_card=/dev/disk/by-id/usb-Generic_MassStorageClass_000000001538-0:1-part1
sd_mount=/home/nf/sdcard

release="jesse"

[ "$1_" = "buster_" ] && {
	release="buster"
}

punt(){
	echo "Exiting early"
	exit
}

echo "$deb_root"
echo "$kern_path"

sudo rm -r root/

multistrap -a armel -d $PWD/root -f $release.conf && {
	sudo cp -r /lib/firmware root/lib/
	pushd $kern_path
	make INSTALL_MOD_PATH=$deb_root modules_install
	popd
	mkdir root/etc/init/
	sudo cp .vimrc root/etc/nfinit/
	sudo cp .screenrc root/etc/nfinit/
	sudo cp .gitconfig root/etc/nfinit/
	sudo cp .bashrc root/etc/nfinit/
	sudo cp init_packages.sh root/bin/
	sudo cp interfaces root/etc/network/
	sudo echo "user ALL = NOPASSWD:ALL" >> root/etc/sudoers
	sudo cp -f wpa.conf root/etc/dot_conf_examples
	touch /tmp/multistrap_done
}

[ -f /tmp/multistrap_done ] || punt

sudo mount -t ext4 $sd_card $sd_mount/ && {
	sudo rm -r $sd_mount/*
	sudo cp -r root/* $sd_mount/
	sudo chmod u+s $sd_mount/usr/bin/sudo
}

sleep 30

#qemu stuff to init the rootfs

sudo umount $sd_mount
