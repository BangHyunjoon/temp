#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname.dat
CMD=`echo "" > $FILE_DAT`
if [ $1 ] ; then
# check set hostname command
    HOST_CMD=0
    type -P hostnamectl &>/dev/null && HOST_CMD=1 || continue


    COMMAND=`echo "hostname setting[$1]..." > ../aproc/shell/hostname.dat`
    if [ $HOST_CMD -eq 0 ] ; then 
       COMMAND=`hostname $1 >> ../aproc/shell/hostname.dat 2>&1`
    else
       COMMAND=`hostnamectl set-hostname $1 >> ../aproc/shell/hostname.dat 2>&1`
    fi

    HOSTNAME_REDHAT=/etc/sysconfig/network
    HOSTNAME_UBUNTU=/etc/hostname
    if [ -f $HOSTNAME_REDHAT ] ; then
        COMMAND=`./shell/LINUX/ConfUpdate.sh HOSTNAME=$1 $HOSTNAME_REDHAT >> ../aproc/shell/hostname.dat 2>&1`
        if [ -f $HOSTNAME_UBUNTU ] ; then #centos7
            COMMAND=`echo $1 > $HOSTNAME_UBUNTU`
        fi 
    else
        if [ -f $HOSTNAME_UBUNTU ] ; then
            COMMAND=`echo $1 > $HOSTNAME_UBUNTU`
        else
            COMMAND=`echo "hostname set($1) failed." >> ../aproc/shell/hostname.dat 2>&1`
            COMMAND=`echo "file not found : $HOSTNAME_REDHAT, $HOSTNAME_UBUNTU" >> ../aproc/shell/hostname.dat 2>&1`
        fi
    fi
else 
    COMMAND=`echo "hostname argument intput error." >> ../aproc/shell/hostname.dat 2>&1`
    exit 255
fi

exit 0
