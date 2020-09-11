#!/bin/bash

[ -f /var/lib/dpkg/info/dash.preinst ] && /var/lib/dpkg/info/dash.preinst install

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a

useradd -m -p "sa3tHJ3/KuYvI" user
cp /zybot/* /home/user/
chown user /home/user/*
rm -r /zybot/
chmod u+s /usr/bin/sudo
