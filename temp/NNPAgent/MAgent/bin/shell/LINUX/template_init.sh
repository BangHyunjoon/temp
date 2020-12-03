#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/ip_update.dat
TMP_CHK=`date > $FILE_DAT`
NIC_NAME="eth0"

NIC_NAME=""
NIC_BOOTPROT=""
NIC_IP=""
NIC_NETMASK=""
NIC_GATEWAY=""
NIC_DNS1=""
NIC_DNS2=""
TMP_CMD=0

if [ "$1" ] ; then
    NIC_NAME=$1
    #echo "NIC_NAME=[$NIC_NAME]"
else
    echo "Not found interface mac addr : $1" >> $FILE_DAT
    exit 255
fi

if [ "$2" ] ; then
    NIC_BOOTPROT=$2
else
    echo "Not found bootprot input : $2" >> $FILE_DAT
    exit 255
fi

if [ "$NIC_BOOTPROT" = "static" ] ; then
    NIC_BOOTPROT="STATIC"
    if [ "$3" ] ; then
        TMP_CMD=`echo $3 | grep ^- | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            NIC_IP=$3
        else
            NIC_IP=""
        fi
    else
        NIC_IP=""
    fi

    if [ "$4" ] ; then
        TMP_CMD=`echo $4 | grep ^- | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            NIC_NETMASK=$4
        else
            NIC_NETMASK=""
        fi
    else
        NIC_NETMASK=""
    fi

    if [ "$5" ] ; then
        TMP_CMD=`echo $5 | grep ^- | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            NIC_GATEWAY=$5
        else
            NIC_GATEWAY=""
        fi
    else
        NIC_GATEWAY=""
    fi
else
    NIC_BOOTPROT="DHCP"
fi

if [ -d /etc/sysconfig/network-scripts ] ; then
    echo "RedHat Interfaces setting..." >> $FILE_DAT
    IFCFG_NAME=/etc/sysconfig/network-scripts/ifcfg-$NIC_NAME
    ROUTE_NAME=/etc/sysconfig/network-scripts/route-$NIC_NAME

    \rm -f /etc/sysconfig/network-scripts/ifcfg-e*
    echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
    echo "BOOTPROTO=$NIC_BOOTPROT" >> $IFCFG_NAME
    echo "ONBOOT=yes" >> $IFCFG_NAME
    if [ "$NIC_BOOTPROT" = "STATIC" ] ; then
        echo "IPADDR=$NIC_IP" >> $IFCFG_NAME
        echo "NETMASK=$NIC_NETMASK" >> $IFCFG_NAME
        echo "GATEWAY=$NIC_GATEWAY" >> $IFCFG_NAME
    fi
    echo "" > /etc/udev/rules.d/70-persistent-net.rules
else
    if [ -f /etc/network/interfaces ] ; then
        echo "Ubuntu(or Debian) Interfaces setting..." >> $FILE_DAT
        IFCFG_NAME=/etc/network/interfaces
        IFCFG_TMP=/etc/network/interfaces_

        ###################################
        # interface dhcp setting update
        echo "" > $IFCFG_TMP
        echo "auto $NIC_NAME" >> $IFCFG_TMP
        echo "iface $NIC_NAME inet $NIC_BOOTPROT" >> $IFCFG_TMP
        if [ "$NIC_BOOTPROT" = "STATIC" ] ; then
            echo "address $NIC_IP" >> $IFCFG_NAME
            echo "netmask $NIC_NETMASK" >> $IFCFG_NAME
            echo "gateway $NIC_GATEWAY" >> $IFCFG_NAME
        fi
        #
        ###################################

        \rm -f $IFCFG_NAME
        mv $IFCFG_TMP $IFCFG_NAME
    else
        echo "Interfaces setting unknown...[/etc/sysconfig/network-scripts, /etc/network/interfaces not found]" >> $FILE_DAT
    fi
fi

\rm ../../MAegnt/bin/shell/LINUX/ifcfg_set*
../../utils/ETC/ConfUpdate VAGENT_TYPE=1 ../conf/MasterAgent.conf > /dev/null
../../utils/ETC/ConfUpdate AUTO_UPDATE_TIME=60 ../conf/MasterAgent.conf > /dev/null
../../utils/ETC/ConfUpdate MASTER_AGENT_KEY=MA_ ../conf/MasterAgent.conf > /dev/null

cd /
sleep 3;shutdown -H 0;shutdown -H &

echo "SUCCESS"
exit 0

