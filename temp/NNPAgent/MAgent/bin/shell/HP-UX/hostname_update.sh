#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname.dat
CMD=`echo "" > $FILE_DAT`
if [ $1 ] ; then

    COMMAND=`echo "hostname setting[$1]..." > ../aproc/shell/hostname.dat` 

    HOSTNAME_CONFFILE=/etc/rc.config.d/netconf
    if [ -f $HOSTNAME_CONFFILE ] ; then

        COMMAND=`\rm -f /etc/rc.config.d/netconf_* >> ../aproc/shell/hostname.dat 2>&1`
        COMMAND=`./shell/HP-UX/ConfUpdate.sh HOSTNAME=$1 $HOSTNAME_CONFFILE >> ../aproc/shell/hostname.dat 2>&1`
        COMMAND=`/sbin/init.d/hostname start >> ../aproc/shell/hostname.dat 2>&1`
        COMMAND=`hostname $1 >> ../aproc/shell/hostname.dat 2>&1`
        COMMAND=`uname -S $1 >> ../aproc/shell/hostname.dat 2>&1`
    else
        COMMAND=`echo "hostname set($1) failed." >> ../aproc/shell/hostname.dat 2>&1`
        COMMAND=`echo "file not found : $HOSTNAME_CONFFILE" >> ../aproc/shell/hostname.dat 2>&1`
    fi
else 
    COMMAND=`echo "hostname argument intput error." >> ../aproc/shell/hostname.dat 2>&1`
    exit 255
fi

exit 0
