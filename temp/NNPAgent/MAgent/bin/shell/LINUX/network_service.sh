#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

EXIT_CODE=0
if [ -d /etc/sysconfig/network-scripts ] ; then

    echo "RedHat Interfaces setting..."
    #../../utils/ETC/ShCmd 60 service network $1
    ../../utils/ETC/ShCmd 60 ifdown $2
    ../../utils/ETC/ShCmd 60 ifup $2

else
    if [ -f /etc/network/interfaces ] ; then
        echo "Ubuntu Interfaces setting..."
        ../../utils/ETC/ShCmd 60 service networking $1
        ../../utils/ETC/ShCmd 60 ifdown $2
        ../../utils/ETC/ShCmd 60 ifup $2

    else
        echo "Interfaces setting unknown...[/etc/sysconfig/network-scripts, /etc/network/interfaces not found]"
        EXIT_CODE=255
    fi
fi

exit $EXIT_CODE
