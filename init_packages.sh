mount -t proc proc /proc

/var/lib/dpkg/info/dash.preinst install

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a

