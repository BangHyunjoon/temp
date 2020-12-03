#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ip_update.dat
IP_UPDATE_EXIT=../aproc/shell/ip_update.exit

TMP_CMD=`date > $FILE_DAT`

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

TMP_CMD=`./shell/LINUX/ifcfg_update.sh $*;echo $?`

if [ $TMP_CMD = 1 ] ; then

    ifconfig -a >> $FILE_DAT 2>&1

    echo "> ifup $NIC_NAME" >> $FILE_DAT
    ./shell/LINUX/network_service.sh restart $NIC_NAME >> $FILE_DAT 2>&1

    TMP_CMD=0
else
    if [ $TMP_CMD = 0 ] ; then

        ifconfig -a >> $FILE_DAT 2>&1
        echo "no change ip info... skip" >> $FILE_DAT
        TMP_CMD=0
 
    else
    
        echo "ip update failed." >> $FILE_DAT

    fi
fi

echo "$TMP_CMD" > $IP_UPDATE_EXIT
exit $TMP_CMD
