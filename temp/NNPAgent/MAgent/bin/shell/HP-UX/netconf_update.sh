#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ip_update.dat
NIC_NAME=""
NIC_BOOTPROT=""
NIC_IP=""
NIC_NETMASK=""
NIC_GATEWAY=""
NIC_DNS1=""
NIC_DNS2=""
TMP_CMD=0
RESULT=0
TMP_CHK=`date > $FILE_DAT`

NIC_MAC=""
NIC_NAME_FILE=../aproc/shell/mac_nic_mapping.dat
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

if [ "$2" ] ; then
    NIC_BOOTPROT=$2
else
    echo "Not found bootprot input : $2" >> $FILE_DAT
    exit 255 
fi

if [ "$3" ] ; then
    TMP_CMD=`echo $3 | grep ^- | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        NIC_IP=$3
    else
        NIC_IP=""
    fi
else 
    if [ "$NIC_BOOTPROT" = "STATIC" ] ; then
        echo "Not found ip input : $3" >> $FILE_DAT
        exit 255
    fi
fi

if [ "$4" ] ; then
    TMP_CMD=`echo $4 | grep ^- | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        NIC_NETMASK=$4
    else
        NIC_NETMASK=""
    fi
else 
    if [ "$NIC_BOOTPROT" = "STATIC" ] ; then
        echo "Not found netmask ip input : $4" >> $FILE_DAT
        exit 255
    fi
fi

if [ "$5" ] ; then
    TMP_CMD=`echo $5 | grep ^- | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        NIC_GATEWAY=$5
    else
        NIC_GATEWAY=""
    fi
else 
    if [ "$NIC_BOOTPROT" = "STATIC" ] ; then
        echo "Not found gateway ip input : $5" >> $FILE_DAT
        exit 255
    fi
fi

if [ "$6" ] ; then
    TMP_CMD=`echo $6 | grep ^- | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        NIC_DNS1=$6
    else
        NIC_DNS1=""
    fi
fi

if [ "$7" ] ; then
    TMP_CMD=`echo $7 | grep ^- | wc -l`
    if [ $TMP_CMD = 0 ] ; then
        NIC_DNS2=$7
    else
        NIC_DNS2=""
    fi
fi

echo "NIC_NAME=[$NIC_NAME]"
echo "NIC_BOOTPROT=$2"
echo "NIC_IP=$3"
echo "NIC_NETMASK=$4"
echo "NIC_GATEWAY=$5"
echo "NIC_DNS1=$6"

NIC_CHK=0
NIC_CHK=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME$" | wc -l | awk '{print $1}'`
if [ "$NIC_CHK" = "0" ] ; then
    NIC_CHK=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME " | wc -l | awk '{print $1}'`
    if [ "$NIC_CHK" = "0" ] ; then
        NIC_CHK=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "\"$NIC_NAME\"" | wc -l | awk '{print $1}'`
    fi
fi

NIC_INDX=0
NIC_OLD_FLAG=0
echo "nic found check ===> $NIC_CHK"
if [ "$NIC_CHK" = "0" ] ; then

    while [ $NIC_INDX -lt 30 ]
    do
        NIC_CHK=`grep "INTERFACE_NAME\[$NIC_INDX\]=" /etc/rc.config.d/netconf | wc -l | awk '{print $1}'`
        if [ "$NIC_CHK" = "0" ] ; then
            break
        fi
        let "NIC_INDX = $NIC_INDX + 1"
    done

    echo "new NIC_INDX = $NIC_INDX"
else
    NIC_CHK=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME$" | wc -l | awk '{print $1}'`
    if [ "$NIC_CHK" = "0" ] ; then
        NIC_INDX=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME " | cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2 | cut -d']' -f1 | awk '{print $1}'`
        if [ "$NIC_CHK" = "0" ] ; then
            NIC_INDX=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME\"" | cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2 | cut -d']' -f1 | awk '{print $1}'`
        fi
    else
        NIC_INDX=`grep "INTERFACE_NAME\[" /etc/rc.config.d/netconf | grep -v "^#" | grep "$NIC_NAME$" | cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2 | cut -d']' -f1 | awk '{print $1}'`
    fi

    echo "old NIC_INDX = $NIC_INDX"
    NIC_OLD_FLAG=1
fi

echo "nic index check ===> $NIC_INDX, old nic check ===> $NIC_OLD_FLAG"

ROUTE_COUNT=0
ROUTE_ADD_FLAG=0
let "ROUTE_COUNT = $NIC_INDX + 1"

#grep "\]=" /etc/rc.config.d/netconf | grep -v "ROUTE_" | grep -v "^# "

UPGRADE_FLAG=0
NIC_INFO_FILE=./shell/HP-UX/netconf_set_$NIC_NAME
NIC_UPDATE_FLAG=0

NETCONF_NAME=/etc/rc.config.d/netconf
NETCONF_NAME_TMP=../aproc/shell/netconf_tmp
if [ "$NIC_BOOTPROT" = "DHCP" ] ; then
 
    TMP_VAR="DEVICE-$NIC_NAME=\[$NIC_NAME\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info($TMP_CMD) : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="BOOTPROTO-$NIC_NAME=\[dhcp\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="ONBOOT-$NIC_NAME=\[yes\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    if [ $NIC_UPDATE_FLAG = 1 ] ; then
        echo "DEVICE-$NIC_NAME=[$NIC_NAME]" > $NIC_INFO_FILE
        echo "BOOTPROTO-$NIC_NAME=[dhcp]" >> $NIC_INFO_FILE
        echo "ONBOOT-$NIC_NAME=[yes]" >> $NIC_INFO_FILE

        echo "#" > $NETCONF_NAME_TMP

        UPGRADE_FLAG=0
        while read line
        do
            NIC_CHK=`echo $line | grep "^#" | wc -l | awk '{print $1}'`
            if [ $NIC_CHK = 1 ] ; then
                echo "$line" >> $NETCONF_NAME_TMP
            else
                NIC_CHK=`echo $line | grep "^ " | wc -l | awk '{print $1}'`
                if [ $NIC_CHK = 1 ] ; then
                  echo "$line" >> $NETCONF_NAME_TMP
                else
                  if [ $UPGRADE_FLAG = 0 ] ; then
                    NIC_CHK=`echo $line | grep "^ROUTE_DESTINATION\[" | wc -l | awk '{print $1}'`
                    if [ $NIC_CHK = 1 ] ; then
                        echo "INTERFACE_NAME[$NIC_INDX]=\"$NIC_NAME\"" >> $NETCONF_NAME_TMP
                        echo "INTERFACE_STATE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                        echo "DHCP_ENABLE[$NIC_INDX]=\"1\"" >> $NETCONF_NAME_TMP
                        echo "INTERFACE_MODULES[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                        echo " " >> $NETCONF_NAME_TMP
                        UPGRADE_FLAG=1
                    fi
                  fi
                  NIC_CHK=`echo $line | grep "^INTERFACE_NAME\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                  if [ $NIC_CHK = 1 ] ; then
                    NIC_CHK=1
                  else
                    NIC_CHK=`echo $line | grep "^DHCP_ENABLE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                    if [ $NIC_CHK = 1 ] ; then
                        NIC_CHK=1
                    else
                        NIC_CHK=`echo $line | grep "^IP_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                        if [ $NIC_CHK = 1 ] ; then
                            NIC_CHK=1
                        else
                            NIC_CHK=`echo $line | grep "^SUBNET_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                            if [ $NIC_CHK = 1 ] ; then
                                NIC_CHK=1
                            else
                                NIC_CHK=`echo $line | grep "^BROADCAST_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                if [ $NIC_CHK = 1 ] ; then
                                    NIC_CHK=1
                                else
                                    NIC_CHK=`echo $line | grep "^INTERFACE_STATE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                    if [ $NIC_CHK = 1 ] ; then
                                        NIC_CHK=1
                                    else
                                        NIC_CHK=`echo $line | grep "^INTERFACE_MODULES\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                        if [ $NIC_CHK = 1 ] ; then
                                            NIC_CHK=1
                                        else
                                            NIC_CHK=`echo $line | grep "^ROUTE_DESTINATION\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                            if [ $NIC_CHK = 1 ] ; then
                                                NIC_CHK=1
                                            else
                                                NIC_CHK=`echo $line | grep "^ROUTE_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                if [ $NIC_CHK = 1 ] ; then
                                                    NIC_CHK=1
                                                else
                                                    NIC_CHK=`echo $line | grep "^ROUTE_GATEWAY\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                    if [ $NIC_CHK = 1 ] ; then
                                                        NIC_CHK=1
                                                    else
                                                        NIC_CHK=`echo $line | grep "^ROUTE_COUNT\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                        if [ $NIC_CHK = 1 ] ; then
                                                            NIC_CHK=1
                                                        else
                                                            NIC_CHK=`echo $line | grep "^ROUTE_ARGS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                            if [ $NIC_CHK = 1 ] ; then
                                                                NIC_CHK=1
                                                            else
                                                                NIC_CHK=`echo $line | grep "^ROUTE_SOURCE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                if [ $NIC_CHK = 1 ] ; then
                                                                    NIC_CHK=1
                                                                else
                                                                    NIC_CHK=`echo $line | grep "^ROUTE_SKIP\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                    if [ $NIC_CHK = 1 ] ; then
                                                                        NIC_CHK=1
                                                                    else
                                                                        echo "$line" >> $NETCONF_NAME_TMP
                                                                    fi
                                                                fi
                                                            fi
                                                        fi
                                                    fi
                                                fi
                                            fi
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    fi
                  fi
                fi
            fi
        done <$NETCONF_NAME

        if [ $UPGRADE_FLAG = 0 ] ; then
            echo "INTERFACE_NAME[$NIC_INDX]=\"$NIC_NAME\"" >> $NETCONF_NAME_TMP
            echo "INTERFACE_STATE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            echo "DHCP_ENABLE[$NIC_INDX]=\"1\"" >> $NETCONF_NAME_TMP
            echo "INTERFACE_MODULES[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            echo " " >> $NETCONF_NAME_TMP
            UPGRADE_FLAG=1
        fi

        TMP_CMD=`cp -f $NETCONF_NAME_TMP $NETCONF_NAME`

        UPGRADE_FLAG=1
    else
            echo "no change ip info ... skip" >> $FILE_DAT
            echo "DEVICE-$NIC_NAME=[$NIC_NAME]" >> $FILE_DAT
            echo "BOOTPROTO-$NIC_NAME=[dhcp]" >> $FILE_DAT
            echo "ONBOOT-$NIC_NAME=[yes]" >> $FILE_DAT
    fi
else
  if [ "$NIC_BOOTPROT" = "STATIC" ] ; then

    TMP_VAR="DEVICE-$NIC_NAME=\[$NIC_NAME\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="BOOTPROTO-$NIC_NAME=\[none\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="ONBOOT-$NIC_NAME=\[yes\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="IPADDR-$NIC_NAME=\[$NIC_IP\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="NETMASK-$NIC_NAME=\[$NIC_NETMASK\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    if [ "$NIC_GATEWAY" ] ; then
        TMP_VAR="GATEWAY-$NIC_NAME=\[$NIC_GATEWAY\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi
    fi

    TMP_VAR="TYPE-$NIC_NAME=\[Ethernet\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="USERCTL-$NIC_NAME=\[no\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="IPV6INIT-$NIC_NAME=\[no\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    TMP_VAR="PEERDNS-$NIC_NAME=\[yes\]"
    TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
    if [ $TMP_CMD = 0 ] ; then
        echo "change ip info : $TMP_VAR" >> $FILE_DAT
        NIC_UPDATE_FLAG=1
    fi

    if [ "$NIC_DNS1" ] ; then
        TMP_VAR="DNS1-$NIC_NAME=\[$NIC_DNS1\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
            #TMP_CMD=`cat /etc/resolv.conf | grep -v "nameserver $NIC_DNS1" > /etc/resolv.conf_`
            #TMP_CMD=`echo "nameserver $NIC_DNS1" >> /etc/resolv.conf_`
            #TMP_CMD=`cat /etc/resolv.conf_ > /etc/resolv.conf`
            #TMP_CMD=`rm -f cat /etc/resolv.conf_`
        fi
    fi

    if [ "$NIC_DNS2" ] ; then
        TMP_VAR="DNS2-$NIC_NAME=\[$NIC_DNS2\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
            #TMP_CMD=`cat /etc/resolv.conf | grep -v "nameserver $NIC_DNS2" > /etc/resolv.conf_`
            #TMP_CMD=`echo "nameserver $NIC_DNS2" >> /etc/resolv.conf_`
            #TMP_CMD=`cat /etc/resolv.conf_ > /etc/resolv.conf`
            #TMP_CMD=`rm -f cat /etc/resolv.conf_`
        fi
    fi

echo "nic update flag check............. : $NIC_UPDATE_FLAG"
    if [ $NIC_UPDATE_FLAG = 1 ] ; then
        echo "DEVICE-$NIC_NAME=[$NIC_NAME]" > $NIC_INFO_FILE
        echo "BOOTPROTO-$NIC_NAME=[none]" >> $NIC_INFO_FILE
        echo "ONBOOT-$NIC_NAME=[yes]" >> $NIC_INFO_FILE
        echo "IPADDR-$NIC_NAME=[$NIC_IP]" >> $NIC_INFO_FILE
        echo "NETMASK-$NIC_NAME=[$NIC_NETMASK]" >> $NIC_INFO_FILE
        if [ "$NIC_GATEWAY" ] ; then
            echo "GATEWAY-$NIC_NAME=[$NIC_GATEWAY]" >> $NIC_INFO_FILE
        fi
        echo "TYPE-$NIC_NAME=[Ethernet]" >> $NIC_INFO_FILE
        echo "USERCTL-$NIC_NAME=[no]" >> $NIC_INFO_FILE
        echo "IPV6INIT-$NIC_NAME=[no]" >> $NIC_INFO_FILE
        echo "PEERDNS-$NIC_NAME=[yes]" >> $NIC_INFO_FILE
        if [ "$NIC_DNS1" ] ; then
            echo "DNS1-$NIC_NAME=[$NIC_DNS1]" >> $NIC_INFO_FILE
        fi
        if [ "$NIC_DNS2" ] ; then
            echo "DNS2-$NIC_NAME=[$NIC_DNS2]" >> $NIC_INFO_FILE
        fi

        # UPDATE  or ADD
        echo "#" > $NETCONF_NAME_TMP

        UPGRADE_FLAG=0
echo "netconf read............."
        while read line
        do
            NIC_CHK=`echo $line | grep "^#" | wc -l | awk '{print $1}'`
            if [ $NIC_CHK = 1 ] ; then
                echo "$line" >> $NETCONF_NAME_TMP
            else
                NIC_CHK=`echo $line | grep "^ " | wc -l | awk '{print $1}'`
                if [ $NIC_CHK = 1 ] ; then
                    echo "$line" >> $NETCONF_NAME_TMP
                else
                  if [ $UPGRADE_FLAG  = 0 ] ; then
                    NIC_CHK=`echo $line | grep "^ROUTE_DESTINATION\[" | wc -l | awk '{print $1}'`
                    if [ $NIC_CHK = 1 ] ; then
                        echo "INTERFACE_NAME[$NIC_INDX]=\"$NIC_NAME\"" >> $NETCONF_NAME_TMP
                        echo "IP_ADDRESS[$NIC_INDX]=\"$NIC_IP\"" >> $NETCONF_NAME_TMP
                        echo "SUBNET_MASK[$NIC_INDX]=\"$NIC_NETMASK\"" >> $NETCONF_NAME_TMP
                        echo "BROADCAST_ADDRESS[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                        echo "INTERFACE_STATE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                        echo "DHCP_ENABLE[$NIC_INDX]=\"0\"" >> $NETCONF_NAME_TMP
                        echo "INTERFACE_MODULES[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                        echo " " >> $NETCONF_NAME_TMP
                        UPGRADE_FLAG=1
                    fi
                  fi

                  NIC_CHK=`echo $line | grep "^INTERFACE_NAME\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                  if [ $NIC_CHK = 1 ] ; then
                    NIC_CHK=1
                  else
                    NIC_CHK=`echo $line | grep "^DHCP_ENABLE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                    if [ $NIC_CHK = 1 ] ; then
                        NIC_CHK=1
                    else
                        NIC_CHK=`echo $line | grep "^IP_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                        if [ $NIC_CHK = 1 ] ; then
                            NIC_CHK=1
                        else
                            NIC_CHK=`echo $line | grep "^SUBNET_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                            if [ $NIC_CHK = 1 ] ; then
                                NIC_CHK=1
                            else
                                NIC_CHK=`echo $line | grep "^BROADCAST_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                if [ $NIC_CHK = 1 ] ; then
                                    NIC_CHK=1
                                else
                                    NIC_CHK=`echo $line | grep "^INTERFACE_STATE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                    if [ $NIC_CHK = 1 ] ; then
                                        NIC_CHK=1
                                    else
                                        NIC_CHK=`echo $line | grep "^INTERFACE_MODULES\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                        if [ $NIC_CHK = 1 ] ; then
                                            NIC_CHK=1
                                        else
                                            NIC_CHK=`echo $line | grep "^ROUTE_DESTINATION\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                            if [ $NIC_CHK = 1 ] ; then
                                                NIC_CHK=1
                                            else
                                                NIC_CHK=`echo $line | grep "^ROUTE_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                if [ $NIC_CHK = 1 ] ; then
                                                    NIC_CHK=1
                                                else
                                                    NIC_CHK=`echo $line | grep "^ROUTE_GATEWAY\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                    if [ $NIC_CHK = 1 ] ; then
                                                        NIC_CHK=1
                                                    else
                                                        NIC_CHK=`echo $line | grep "^ROUTE_COUNT\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                        if [ $NIC_CHK = 1 ] ; then
                                                            NIC_CHK=1
                                                        else
                                                            NIC_CHK=`echo $line | grep "^ROUTE_ARGS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                            if [ $NIC_CHK = 1 ] ; then
                                                                NIC_CHK=1
                                                            else
                                                                NIC_CHK=`echo $line | grep "^ROUTE_SOURCE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                if [ $NIC_CHK = 1 ] ; then
                                                                    NIC_CHK=1
                                                                else
                                                                    NIC_CHK=`echo $line | grep "^ROUTE_SKIP\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                    if [ $NIC_CHK = 1 ] ; then
                                                                        NIC_CHK=1
                                                                    else
                                                                        echo "$line" >> $NETCONF_NAME_TMP
                                                                    fi
                                                                fi
                                                            fi
                                                        fi
                                                    fi
                                                fi
                                            fi
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
echo "netconf read [$NIC_CHK] : $line"
        done <$NETCONF_NAME

        if [ $UPGRADE_FLAG = 0 ] ; then
            echo "INTERFACE_NAME[$NIC_INDX]=\"$NIC_NAME\"" >> $NETCONF_NAME_TMP
            echo "IP_ADDRESS[$NIC_INDX]=\"$NIC_IP\"" >> $NETCONF_NAME_TMP
            echo "SUBNET_MASK[$NIC_INDX]=\"$NIC_NETMASK\"" >> $NETCONF_NAME_TMP
            echo "BROADCAST_ADDRESS[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            echo "INTERFACE_STATE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            echo "DHCP_ENABLE[$NIC_INDX]=\"0\"" >> $NETCONF_NAME_TMP
            echo "INTERFACE_MODULES[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            echo " " >> $NETCONF_NAME_TMP
        fi

        
        BACKUP_NETCHECK=""
        BACKUP_NETWORK=""
        if [ "$NIC_GATEWAY" ] ; then
            BACKUP_NETCHECK=`grep BACKUP_NETCHECK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
            BACKUP_NETWORK=`grep BACKUP_NETWORK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
            if [ "$BACKUP_NETCHECK" = "" ] ; then
                echo "ROUTE_DESTINATION[$NIC_INDX]=\"default\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_MASK[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_GATEWAY[$NIC_INDX]=\"$NIC_GATEWAY\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_COUNT[$NIC_INDX]=\"1\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_ARGS[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_SOURCE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                echo "ROUTE_SKIP[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
            else
                TMP_CMD=`echo "$NIC_GATEWAY" | grep "$BACKUP_NETCHECK" | wc -l | awk '{print $1}'`
                if [ "$TMP_CMD" = "0" ] ; then
                    echo "ROUTE_DESTINATION[$NIC_INDX]=\"default\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_MASK[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_GATEWAY[$NIC_INDX]=\"$NIC_GATEWAY\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_COUNT[$NIC_INDX]=\"1\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_ARGS[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_SOURCE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_SKIP[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                else
                    echo "ROUTE_DESTINATION[$NIC_INDX]=\"net $BACKUP_NETWORK\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_MASK[$NIC_INDX]=\"255.255.0.0\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_GATEWAY[$NIC_INDX]=\"$NIC_GATEWAY\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_COUNT[$NIC_INDX]=\"1\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_ARGS[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_SOURCE[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                    echo "ROUTE_SKIP[$NIC_INDX]=\"\"" >> $NETCONF_NAME_TMP
                fi
            fi
        fi


        TMP_CMD=`cp -f $NETCONF_NAME_TMP $NETCONF_NAME`
        echo "cp -f $NETCONF_NAME_TMP $NETCONF_NAME"

        UPGRADE_FLAG=1
    else
        echo "no change ip info ... skip" >> $FILE_DAT
        echo "DEVICE-$NIC_NAME=[$NIC_NAME]" >> $FILE_DAT
        echo "BOOTPROTO-$NIC_NAME=[none]" >> $FILE_DAT
        echo "ONBOOT-$NIC_NAME=[yes]" >> $FILE_DAT
        echo "IPADDR-$NIC_NAME=[$NIC_IP]" >> $FILE_DAT
        echo "NETMASK-$NIC_NAME=[$NIC_NETMASK]" >> $FILE_DAT
        echo "GATEWAY-$NIC_NAME=[$NIC_GATEWAY]" >> $FILE_DAT
        echo "TYPE-$NIC_NAME=[Ethernet]" >> $FILE_DAT
        echo "USERCTL-$NIC_NAME=[no]" >> $FILE_DAT
        echo "IPV6INIT-$NIC_NAME=[no]" >> $FILE_DAT
        echo "PEERDNS-$NIC_NAME=[yes]" >> $FILE_DAT
        if [ "$NIC_DNS1" ] ; then
            echo "DNS1-$NIC_NAME=[$NIC_DNS1]" >> $FILE_DAT
        fi
        if [ "$NIC_DNS2" ] ; then
            echo "DNS2-$NIC_NAME=[$NIC_DNS2]" >> $FILE_DAT
        fi
    fi
  else
    if [ "$NIC_BOOTPROT" = "NONE" ] ; then

        TMP_VAR="DEVICE-$NIC_NAME=\[$NIC_NAME\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        TMP_VAR="BOOTPROTO-$NIC_NAME=\[none\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        TMP_VAR="ONBOOT-$NIC_NAME=\[no\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l | awk '{print $1}'`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        echo "DEVICE-$NIC_NAME=[$NIC_NAME]" > $NIC_INFO_FILE
        echo "BOOTPROTO-$NIC_NAME=[none]" >> $NIC_INFO_FILE
        echo "ONBOOT-$NIC_NAME=[no]" >> $NIC_INFO_FILE

        echo "#" > $NETCONF_NAME_TMP

        while read line
        do
            NIC_CHK=`echo $line | grep "^#" | wc -l | awk '{print $1}'`
            if [ $NIC_CHK = 1 ] ; then
                echo "$line" >> $NETCONF_NAME_TMP
            else
                NIC_CHK=`echo $line | grep "^ " | wc -l | awk '{print $1}'`
                if [ $NIC_CHK = 1 ] ; then
                    echo "$line" >> $NETCONF_NAME_TMP
                else
                    NIC_CHK=`echo $line | grep "^INTERFACE_NAME\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                    if [ $NIC_CHK = 1 ] ; then
                        NIC_CHK=1
                    else
                        NIC_CHK=`echo $line | grep "^DHCP_ENABLE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                        if [ $NIC_CHK = 1 ] ; then
                            NIC_CHK=1
                        else
                            NIC_CHK=`echo $line | grep "^IP_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                            if [ $NIC_CHK = 1 ] ; then
                                NIC_CHK=1
                            else
                                NIC_CHK=`echo $line | grep "^SUBNET_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                if [ $NIC_CHK = 1 ] ; then
                                    NIC_CHK=1
                                else
                                    NIC_CHK=`echo $line | grep "^BROADCAST_ADDRESS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                    if [ $NIC_CHK = 1 ] ; then
                                        NIC_CHK=1
                                    else
                                        NIC_CHK=`echo $line | grep "^INTERFACE_STATE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                        if [ $NIC_CHK = 1 ] ; then
                                            NIC_CHK=1
                                        else
                                            NIC_CHK=`echo $line | grep "^INTERFACE_MODULES\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                            if [ $NIC_CHK = 1 ] ; then
                                                NIC_CHK=1
                                            else
                                              NIC_CHK=`echo $line | grep "^ROUTE_DESTINATION\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                              if [ $NIC_CHK = 1 ] ; then
                                                NIC_CHK=1
                                              else
                                                NIC_CHK=`echo $line | grep "^ROUTE_MASK\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                if [ $NIC_CHK = 1 ] ; then
                                                    NIC_CHK=1
                                                else
                                                    NIC_CHK=`echo $line | grep "^ROUTE_GATEWAY\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                    if [ $NIC_CHK = 1 ] ; then
                                                        NIC_CHK=1
                                                    else
                                                        NIC_CHK=`echo $line | grep "^ROUTE_COUNT\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                        if [ $NIC_CHK = 1 ] ; then
                                                            NIC_CHK=1
                                                        else
                                                            NIC_CHK=`echo $line | grep "^ROUTE_ARGS\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                            if [ $NIC_CHK = 1 ] ; then
                                                                NIC_CHK=1
                                                            else
                                                                NIC_CHK=`echo $line | grep "^ROUTE_SOURCE\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                if [ $NIC_CHK = 1 ] ; then
                                                                    NIC_CHK=1
                                                                else
                                                                    NIC_CHK=`echo $line | grep "^ROUTE_SKIP\[$NIC_INDX\]=" | wc -l | awk '{print $1}'`
                                                                    if [ $NIC_CHK = 1 ] ; then
                                                                        NIC_CHK=1
                                                                    else
                                                                        echo "$line" >> $NETCONF_NAME_TMP
                                                                    fi
                                                                fi
                                                            fi
                                                        fi
                                                    fi
                                                fi
                                              fi
                                            fi
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        done <$NETCONF_NAME

        UPGRADE_FLAG=1
        TMP_CMD=`cp -f $NETCONF_NAME_TMP $NETCONF_NAME`
    else
        echo "Interface BOOTPROT type unknown[$NIC_BOOTPROT]." >> $FILE_DAT
    fi
  fi
fi

exit $UPGRADE_FLAG
