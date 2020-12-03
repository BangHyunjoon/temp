#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/static_route_add.dat
S_ROUTE_EXIT=../aproc/shell/static_route_add.exit

CMD=`echo "" > $FILE_DAT`
CMD=`echo "" > $S_ROUTE_EXIT`

ROUTE_CMD=route
COMMAND=`which $ROUTE_CMD 2> /dev/null | grep -v "no "`

if [[ -z $COMMAND ]] ; then

    CMD=`echo "not found route info command($ROUTE_CMD)" > ../aproc/shell/static_route_add.dat_err`
    exit 255
fi

#echo "$0 <IP> <NetMask> <GateWay> <MAC_ADDR>"
# route add -net 10.10.10.0 netmask 255.255.255.0 gw 192.168.0.1
# /etc/rc.local adding..

S_ROUTE_IP="$1"
S_ROUTE_NM="$2"
S_ROUTE_GW="$3"
S_ROUTE_MAC="$4"

CMD=`date > $FILE_DAT`
CMD=`echo "S_ROUTE_IP=$1" >> $FILE_DAT`
CMD=`echo "S_ROUTE_NM=$2" >> $FILE_DAT`
CMD=`echo "S_ROUTE_GW=$3" >> $FILE_DAT`
CMD=`echo "S_ROUTE_MAC=$4" >> $FILE_DAT`

#NIC_NAME=""
#if [ "$S_ROUTE_MAC" ] ; then
#    NIC_NAME=`../../utils/ETC/network_mac | grep $S_ROUTE_MAC |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
#    if [ $NIC_NAME ] ; then
#        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
#    else
#        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
#        exit 255
#    fi
#    #echo "NIC_NAME=[$NIC_NAME]"
#else
#    echo "Not found interface mac addr : $S_ROUTE_MAC" >> $FILE_DAT
#    exit 255
#fi

TMP_CMD=1
if [ "$S_ROUTE_IP" ] ; then
    if [ "$S_ROUTE_NM" ] ; then
        if [ "$S_ROUTE_GW" ] ; then
#           if [ "$S_ROUTE_MAC" ] ; then
                TMP_CMD=`./shell/SOLARIS/static_route_del.sh $S_ROUTE_IP $S_ROUTE_NM $S_ROUTE_GW $S_ROUTE_MAC;echo $?`

                S_ROUTE_ADD="route add $S_ROUTE_IP $S_ROUTE_GW -netmask $S_ROUTE_NM"

                CMD=`echo "Static Route ADD command : $S_ROUTE_ADD" >> $FILE_DAT`
                TMP_CMD=`$S_ROUTE_ADD 2>&1 >> $FILE_DAT;echo $?`
                CMD=`echo "Static Route ADD result : $TMP_CMD" >> $FILE_DAT`

                if [ "$TMP_CMD" = "0" ] ; then
                    TMP_CMD=`echo $S_ROUTE_ADD >> /etc/rc2.d/S98static-routes;echo $?`
                    CMD=`chmod 744 /etc/rc2.d/S98static-routes;echo $?`
                    CMD=`echo "Static Route ADD command added(/etc/rc.local) result : $TMP_CMD" >> $FILE_DAT`
                else 
                    CMD=`echo "Static Route ADD failed." >> $FILE_DAT`
                fi
#           else 
#               echo "ERROR : Static Route MAC info not found." >> $FILE_DAT
#           fi
        else 
            CMD=`echo "ERROR : Static Route GateWay info not found." >> $FILE_DAT`
        fi
    else 
        CMD=`echo "ERROR : Static Route NetMask info not found." >> $FILE_DAT`
    fi
else 
    CMD=`echo "ERROR : Static Route Destination IP info not found." >> $FILE_DAT`
fi

CMD=`echo "$TMP_CMD" > $S_ROUTE_EXIT`

if [ "$TMP_CMD" = "0" ] ; then
    exit 0
else
    exit 255
fi

