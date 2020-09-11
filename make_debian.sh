#!/bin/bash

kern_path=/home/nf/git/linux-xlnx
deb_root=$PWD/root/

cp_err_flag=/tmp/zdeb_cp_err
create_done=/tmp/multistrap_done

image=snickerdoodle.img
sandbox=/home/nf/git/zynq_box/sandbox
release="jesse"

[ "$1_" = "buster_" ] && {
	release="buster"
}

cp_err(){
	touch $cp_err_flag
}

punt(){
	echo "Exiting early"
	rm -rf $cp_err_flag
	rm -rf $create_done
	[ -z "$(ls -A $deb_root)" ] || {
		sudo umount $deb_root
	}
	rm -rf $image
	exit
}

echo "rootfs: $deb_root"
echo "kernel source: $kern_path"

truncate -s 2G $image
mkfs.ext4 $image
sudo mount -oloop $image root/

[ -d root/lost+found ] && {
	sudo rm -r root/lost+found
} || {
	punt
}

sudo multistrap -a armhf -d $PWD/root -f $release.conf && {
	sudo cp -r $kern_path/firmware root/lib/ || cp_err
	pushd $kern_path
	sudo make INSTALL_MOD_PATH=$deb_root modules_install || cp_err
	popd
	sudo mkdir -p root/etc/init/ || cp_err
	sudo cp interfaces root/etc/network/ || cp_err
	sudo bash -c 'echo 'LANG=en_US.UTF-8' >> root/etc/default/locale' || cp_err
	sudo bash -c 'echo "user ALL = NOPASSWD:ALL" >> root/etc/sudoers' || cp_err
	sudo cp -f wpa.conf root/etc/dot_conf_examples || cp_err
	sudo mkdir -p root/home/init/ || cp_err
	sudo mkdir root/zybot
	sudo cp .vimrc root/zybot/
	sudo cp .screenrc root/zybot/
	sudo cp .gitconfig root/zybot/
	sudo cp .bashrc root/zybot/
	[ -f $cp_err_flag ] || touch $create_done
}

[ -f $create_done ] || punt

rm -rf $cp_err_flag
rm -rf $create_done

for f in dev dev/pts sys proc run ; do sudo mount --bind /$f root/$f ; done

sudo cp /usr/bin/qemu-arm-static root/usr/bin
sudo cp init_packages.sh root/usr/bin
cd root/
sudo chroot . bin/bash

sleep 3

for f in dev dev/pts sys proc run ; do sudo umount root/$f ; done

#sudo umount -lf root/
#cp -v $image $sandbox
