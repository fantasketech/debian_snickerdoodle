#!/bin/bash

[ -f /var/lib/dpkg/info/dash.preinst ] && /var/lib/dpkg/info/dash.preinst install

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a

useradd -m -p "sa3tHJ3/KuYvI" user
cp /boot/* /home/user/
chown user:user /home/user/*
rm -r /boot/
chmod u+s /usr/bin/sudo

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a # twice becuase some to not get initted properly (like bash)
