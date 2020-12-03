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

ROUTE_FILE=""

CMD=`date > $FILE_DAT`
CMD=`echo "S_ROUTE_IP=$1" >> $FILE_DAT`
CMD=`echo "S_ROUTE_NM=$2" >> $FILE_DAT`
CMD=`echo "S_ROUTE_GW=$3" >> $FILE_DAT`
CMD=`echo "S_ROUTE_MAC=$4" >> $FILE_DAT`

NIC_NAME=""
if [ "$S_ROUTE_MAC" ] ; then
    NIC_NAME=`../../utils/ETC/network_mac | grep $S_ROUTE_MAC |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    if [ $NIC_NAME ] ; then
        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
    else
        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
        exit 255
    fi
    #echo "NIC_NAME=[$NIC_NAME]"
else
    echo "Not found interface mac addr : $S_ROUTE_MAC" >> $FILE_DAT
    exit 255
fi
ROUTE_FILE="/etc/sysconfig/network-scripts/route-$NIC_NAME"

TMP_CMD=1
if [ "$S_ROUTE_IP" ] ; then
    if [ "$S_ROUTE_NM" ] ; then
        if [ "$S_ROUTE_GW" ] ; then
#           if [ "$S_ROUTE_MAC" ] ; then
                TMP_CMD=`./shell/LINUX/static_route_del.sh $S_ROUTE_IP $S_ROUTE_NM $S_ROUTE_GW $S_ROUTE_MAC;echo $?`

                S_ROUTE_ADD="route add -net $S_ROUTE_IP netmask $S_ROUTE_NM gw $S_ROUTE_GW"

                CMD=`echo "Static Route ADD command : $S_ROUTE_ADD" >> $FILE_DAT`
                TMP_CMD=`$S_ROUTE_ADD 2>&1 >> $FILE_DAT;echo $?`
                CMD=`echo "Static Route ADD result : $TMP_CMD" >> $FILE_DAT`

                if [ "$TMP_CMD" = "0" ] ; then
                    #TMP_CMD=`echo $S_ROUTE_ADD >> /etc/rc.local;echo $?`
                    CMD=`echo "Static Route ADD command added($ROUTE_FILE)" >> $FILE_DAT`
                else 
                    CMD=`echo "Static Route ADD failed." >> $FILE_DAT`
                fi
   
                #TMP_CMD=`grep "=$S_ROUTE_IP" $ROUTE_FILE | grep ADDRESS | wc -l`
                #if [ $TMP_CMD = 0 ] ; then
                    ROUTE_INDX=0
                    while [ $ROUTE_INDX -lt 5 ]
                    do
                        TMP_CMD=`grep "^ADDRESS$ROUTE_INDX=" $ROUTE_FILE | wc -l`
                        if [ $TMP_CMD = 0 ] ; then
                            break
                        fi
                        ROUTE_INDX=`expr $ROUTE_INDX + 1`
                    done
                #else
                #    ROUTE_INDX=`grep "=$S_ROUTE_IP" $ROUTE_FILE | grep ADDRESS | cut -d'=' -f1 | cut -d'S' -f3`
                #fi

                CMD=`echo "ADDRESS$ROUTE_INDX=$S_ROUTE_IP" >> $ROUTE_FILE`
                CMD=`echo "NETMASK$ROUTE_INDX=$S_ROUTE_NM" >> $ROUTE_FILE`
                CMD=`echo "GATEWAY$ROUTE_INDX=$S_ROUTE_GW" >> $ROUTE_FILE`

                TMP_CMD=0
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

