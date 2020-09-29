#!/bin/bash

[ -f /var/lib/dpkg/info/dash.preinst ] && /var/lib/dpkg/info/dash.preinst install

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a

useradd -m -s "/bin/bash" -p "sa3tHJ3/KuYvI" user
chmod u+s /usr/bin/sudo

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin  dpkg --configure -a # twice becuase some to not get initted properly (like bash)

echo 'ttyPS0' >> /etc/securetty

echo "127.0.0.1	zynqbot" >> /etc/hosts
echo "zynqbot" >> /etc/hostname

rm /bin/sh ; ln -s /bin/bash /bin/sh
