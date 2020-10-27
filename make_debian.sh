[ "$kern_path" == "" ] && {
	kern_path=/home/nf/git/linux_snickerdoodle
}
deb_root=$PWD/root/
cp_err_flag=/tmp/zdeb_cp_err
create_done=/tmp/multistrap_done

image=snickerdoodle.img
[ "$sandbox" == "" ] && {
	sandbox=/home/nf/git/zynq_bot/sandbox/
}
release="buster"

[ "$1_" = "jesse_" ] && {
	release="jesse"
}

cp_err(){
	touch $cp_err_flag
}

punt(){
	echo "Exiting early"
	rm -rf $cp_err_flag
	rm -rf $create_done
	[ -z "$(ls -A $deb_root)" ] || {
		sudo umount -lf $deb_root
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
	sudo bash -c 'echo 'LANGUAGE=en_US.UTF-8' >> root/etc/default/locale' || cp_err
	sudo bash -c 'echo 'LC_ALL=en_US.UTF-8' >> root/etc/default/locale' || cp_err
	sudo bash -c 'echo "user ALL = NOPASSWD:ALL" >> root/etc/sudoers' || cp_err
	sudo bash -c "sudo echo 'root::0:0:root:/root:/bin/bash' > root/etc/passwd"
	sudo cp -f wpa.conf root/etc/wpa.conf || cp_err
	sudo cp -f resolv.conf root/etc/resolv.conf || cp_err
	sudo cp -f network-wireless@.service root/etc/systemd/system/ || cp_err
	sudo cp -f connect_wpa.sh root/etc/wpa_supplicant/ || cp_err
	[ -f $cp_err_flag ] || touch $create_done
}

[ -f $create_done ] || punt

rm -rf $cp_err_flag
rm -rf $create_done

sudo umount -lf root/

sleep 3

sudo mount -oloop $image root/

for f in dev dev/pts sys proc run ; do sudo mount --bind /$f root/$f ; done

sudo cp /usr/bin/qemu-arm-static root/usr/bin
sudo cp init_packages.sh root/usr/bin
cd root/
sudo update-binfmts --enable qemu-arm
sudo chroot . bin/bash

sleep 3

cd ..

sudo cp .vimrc root/home/user/
sudo cp .screenrc root/home/user/
sudo cp .gitconfig root/home/user/
sudo cp .bashrc root/home/user/
sudo cp ttyPS0.conf root/etc/init/

sudo chown 1000:1000 root/home/user
sudo chown 1000:1000 root/home/user/.*

sudo mkdir -p root/boot/

sudo cp $kern_path/arch/arm/boot/uImage root/boot/
sudo cp $sandbox/system.bit root/boot/
sudo cp $sandbox/boot.bin root/boot/
sudo cp $sandbox/devicetree.dtb root/boot/

for f in dev/pts dev sys proc run ; do sudo umount root/$f ; done

sudo umount -lf $deb_root

cp -v $image $sandbox && rm -f $image
