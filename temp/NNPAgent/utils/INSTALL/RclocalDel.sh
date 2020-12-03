#! /bin/sh
DATE=`date +%Y%m%d`
if [ -f /etc/rc.d/rc.local ]; then
    cp -rf /etc/rc.d/rc.local ./rc.local_$DATE
    sed -e '/rc.cygn2/d' /etc/rc.d/rc.local > ./rc.local
    chmod 744 ./rc.local
    \cp -f ./rc.local /etc/rc.d/rc.local
elif [ -f /etc/init.d/boot.local ]; then
    cp -rf /etc/init.d/boot.local ./boot.local_$DATE
    sed -e '/rc.cygn2/d' /etc/init.d/boot.local > ./boot.local
    chmod 744 ./boot.local
    \cp -f ./boot.local /etc/init.d/boot.local
elif [ -f /etc/init.d/e7cygn ]; then
    \rm -f /etc/init.d/e7cygn
fi
