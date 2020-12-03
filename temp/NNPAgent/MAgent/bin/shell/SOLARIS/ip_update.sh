#!/bin/sh

LD_LIBRARY_PATH=/nkia/NNPAgent/LIB
export LD_LIBRARY_PATH

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ip_update.dat
IP_UPDATE_EXIT=../aproc/shell/ip_update.exit

TMP_CMD=`date > $FILE_DAT`

for NIC_NAME in `dladm | grep -v LINK | cut -d' ' -f1`
do
    #echo "NIC_NAME=$NIC_NAME"
    TMP_CMD=`ifconfig -a | grep $NIC_NAME | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        CMD=`echo "ipadm create-ip $NIC_NAME" >> $FILE_DAT 2>&1`
        CMD=`ipadm create-ip $NIC_NAME >> $FILE_DAT 2>&1`
    fi
done

NIC_NAME=""
if [ "$1" ] ; then
    NIC_NAME=`../../utils/ETC/network_mac | grep $1 |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    if [ $NIC_NAME ] ; then
        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
    else
        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
        exit 255
    fi
    #echo "NIC_NAME=[$NIC_NAME]"
else
    echo "Not found interface mac addr : $1" >> $FILE_DAT
    exit 255
fi

TMP_CMD=`./shell/SOLARIS/ifcfg_update.sh $*;echo $?`

echo "$TMP_CMD" > $IP_UPDATE_EXIT
exit $TMP_CMD
