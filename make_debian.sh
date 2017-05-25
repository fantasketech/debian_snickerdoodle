#!/bin/bash

kern_path=/home/zybo/zybo_desc/zybo_kernel
deb_root=$PWD/root/

punt(){
	echo "Exiting early"
	exit
}

echo "$deb_root"
echo "$kern_path"

sudo rm -r root/

multistrap -a armel -d $PWD/root -f multistrap.conf && {
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

sudo mount -t ext4 /dev/sdh2 ~/fs_zybo && {
	sudo rm -r ~/fs_zybo/*
	sudo cp -r root/* ~/fs_zybo
	sudo chmod u+s ~/fs_zybo/usr/bin/sudo
}

sleep 30

sudo umount ~/fs_zybo
