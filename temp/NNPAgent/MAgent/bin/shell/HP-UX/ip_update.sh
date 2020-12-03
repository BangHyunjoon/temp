#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ip_update.dat
IP_UPDATE_EXIT=../aproc/shell/ip_update.exit

TMP_CMD=`date > $FILE_DAT`
EXIT_VAL=0

NIC_MAC=""
NIC_NAME=""
if [ "$1" ] ; then
    NIC_MAC=`echo $1 | awk -F':' '{print $1$2$3$4$5$6}'`
    #NIC_NAME=`../../utils/ETC/network_mac | grep $1 |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    NIC_NAME=`lanscan | grep $NIC_MAC | awk -F' ' '{print $5}'`
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

TMP_CMD=`\rm -f /etc/rc.config.d/netconf_* >> $FILE_DAT`

ifconfig $NIC_NAME down
ifconfig $NIC_NAME up 
./shell/HP-UX/network_service_restart.sh >> $FILE_DAT 2>&1
ifconfig $NIC_NAME down
ifconfig $NIC_NAME up 

EXIT_VAL=`./shell/HP-UX/netconf_update.sh $* >> $FILE_DAT;echo $?`

if [ "$EXIT_VAL" = "1" ] ; then

    ifconfig -a >> $FILE_DAT 2>&1

    ./shell/HP-UX/network_service_restart.sh >> $FILE_DAT 2>&1

    EXIT_VAL=0
else
    if [ "$EXIT_VAL" = "0" ] ; then

        ifconfig -a >> $FILE_DAT 2>&1
        echo "no change ip info... skip" >> $FILE_DAT
        EXIT_VAL=0
 
    else
    
        echo "ip update failed.(EXIT CODE:$EXIT_VAL)" >> $FILE_DAT

    fi
fi

echo "$EXIT_VAL" > $IP_UPDATE_EXIT
exit $EXIT_VAL
