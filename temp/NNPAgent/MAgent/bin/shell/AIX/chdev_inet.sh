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

NIC_NAME_FILE=../aproc/shell/mac_nic_mapping.dat
if [ "$1" ] ; then
    #NIC_NAME=`../../utils/ETC/network_mac | grep $1 |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    MAC_INFO_SAVE=`echo "$1" | tr -s "[:lower:]" "[:upper:]" | tr -s "." ":" | awk '{print $1}'`

    MAC_NUM=0
    MAC_TMP=0
    NUM_CHECK=0
    MAC_INFO_TMP=
    #echo $1
    MAC_INDX=0
    for MAC_NUM in `echo $MAC_INFO_SAVE | awk -F':' '{for(a=1;a<=6;a++)print $a}'`
    do
        #echo "MAC==>>>$MAC_NUM"
        NUM_CHECK=`echo $MAC_NUM | grep "[A-Z0]" | wc -l | awk '{print $1}'`
        if [ $NUM_CHECK = 0 ] ; then
           #echo "is number"
           MAC_TMP=`expr $MAC_NUM + 0`
           MAC_INFO_TMP=`echo $MAC_INFO_TMP$MAC_TMP`
        else
           #echo "is string"
           MAC_INFO_TMP=`echo $MAC_INFO_TMP$MAC_NUM`
        fi

        if [ $MAC_INDX = 5 ] ; then
           MAC_INDX=5
        else
           MAC_INFO_TMP=`echo $MAC_INFO_TMP:`
           MAC_INDX=`expr $MAC_INDX + 1`
        fi
    done

    MAC_INFO_SAVE=$MAC_INFO_TMP

    NIC_NAME=`./shell/AIX/aix_mac_info.sh | grep $MAC_INFO_SAVE | grep "\[en" | cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
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

UPGRADE_FLAG=0
NIC_INFO_FILE=./shell/AIX/ifcfg_set_$NIC_NAME
NIC_UPDATE_FLAG=0
    echo "AIX Interfaces setting..." >> $FILE_DAT
    if [ "$NIC_BOOTPROT" = "DHCP" ] ; then
        
        TMP_VAR="DEVICE-$NIC_NAME=\[$NIC_NAME\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info($TMP_CMD) : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        TMP_VAR="BOOTPROTO-$NIC_NAME=\[dhcp\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        TMP_VAR="ONBOOT-$NIC_NAME=\[yes\]"
        TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
        if [ $TMP_CMD = 0 ] ; then
            echo "change ip info : $TMP_VAR" >> $FILE_DAT
            NIC_UPDATE_FLAG=1
        fi

        if [ $NIC_UPDATE_FLAG = 1 ] ; then
            echo "DEVICE-$NIC_NAME=[$NIC_NAME]" > $NIC_INFO_FILE
            echo "BOOTPROTO-$NIC_NAME=[dhcp]" >> $NIC_INFO_FILE
            echo "ONBOOT-$NIC_NAME=[yes]" >> $NIC_INFO_FILE

            #echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
            #echo "BOOTPROTO=dhcp" >> $IFCFG_NAME
            #echo "ONBOOT=yes" >> $IFCFG_NAME

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
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="BOOTPROTO-$NIC_NAME=\[none\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="ONBOOT-$NIC_NAME=\[yes\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="IPADDR-$NIC_NAME=\[$NIC_IP\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="NETMASK-$NIC_NAME=\[$NIC_NETMASK\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            if [ "$NIC_GATEWAY" ] ; then
                TMP_VAR="GATEWAY-$NIC_NAME=\[$NIC_GATEWAY\]"
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi
            fi

            TMP_VAR="TYPE-$NIC_NAME=\[Ethernet\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="USERCTL-$NIC_NAME=\[no\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="IPV6INIT-$NIC_NAME=\[no\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            TMP_VAR="PEERDNS-$NIC_NAME=\[yes\]"
            TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
            if [ $TMP_CMD = 0 ] ; then
                echo "change ip info : $TMP_VAR" >> $FILE_DAT
                NIC_UPDATE_FLAG=1
            fi

            if [ "$NIC_DNS1" ] ; then
                TMP_VAR="DNS1-$NIC_NAME=\[$NIC_DNS1\]"
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi
            fi

            if [ "$NIC_DNS2" ] ; then
                TMP_VAR="DNS2-$NIC_NAME=\[$NIC_DNS2\]"
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi
            fi

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

                TMP_CMD=`stopsrc -s dhcpcd >> $FILE_DAT 2>&1`
                TMP_CMD=`cp /etc/dhcpcd.ini ../aproc/shell/dhcpcd.ini_b`
                TMP_CMD=`grep -v "interface any" /etc/dhcpcd.ini > /etc/dhcpcd.ini_`
                TMP_CMD=`grep -v "{" /etc/dhcpcd.ini_ > /etc/dhcpcd.ini`
                TMP_CMD=`grep -v "}" /etc/dhcpcd.ini > /etc/dhcpcd.ini_`
                TMP_CMD=`grep -v "^ option " /etc/dhcpcd.ini_ > /etc/dhcpcd.ini`
                TMP_CMD=`\rm -f /etc/dhcpcd.ini_`
                TMP_CMD=`grep -v "^start /usr/sbin/dhcpcd " /etc/rc.tcpip > /etc/rc.tcpip_`
                TMP_CMD=`grep -v "^dhcpcd_IF_check " /etc/rc.tcpip_ > /etc/rc.tcpip`
                TMP_CMD=`\rm -f /etc/rc.tcpip_`

                sleep 10
                #TMP_CMD=`startsrc -s dhcpcd >> $FILE_DAT 2>&1`

                #TMP_CMD=`stopsrc -g tcpip >> $FILE_DAT 2>&1`
                #TMP_CMD=`/etc/rc.tcpip >> $FILE_DAT 2>&1`
  
                TMP_CMD=`chdev -l $NIC_NAME -a netaddr=$NIC_IP -a netmask=$NIC_NETMASK -a state=up >> $FILE_DAT 2>&1`

                BACKUP_NETCHECK=""
                BACKUP_NETWORK=""
                if [ "$NIC_GATEWAY" ] ; then
                    BACKUP_NETCHECK=`grep BACKUP_NETCHECK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
                    BACKUP_NETWORK=`grep BACKUP_NETWORK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
                    if [ "$BACKUP_NETCHECK" = "" ] ; then
                        TMP_CMD=`route -f >> $FILE_DAT 2>&1`
                        TMP_CMD=`chdev -l inet0 -a route=0,$NIC_GATEWAY >> $FILE_DAT 2>&1`
                    else
                        TMP_CMD=`echo "$NIC_GATEWAY" | grep "$BACKUP_NETCHECK" | wc -l | awk '{print $1}'`
                        if [ "$TMP_CMD" = "0" ] ; then
                            TMP_CMD=`route -f >> $FILE_DAT 2>&1`
                            TMP_CMD=`chdev -l inet0 -a route=0,$NIC_GATEWAY >> $FILE_DAT 2>&1`
                        else
                            TMP_CMD=`./shell/AIX/aix_addroute_nas.sh $NIC_GATEWAY $BACKUP_NETWORK >> $FILE_DAT 2>&1`
                        fi
                    fi
                fi

                if [ "$NIC_DNS1" ] ; then
                    #if [ -f /etc/resolv.conf ] ; then
                    #    TMP_CMD=`cat /etc/resolv.conf | grep -v nameserver > /etc/resolv.conf_tmp`
                    #    TMP_CMD=`mv /etc/resolv.conf /etc/resolv.conf_b`
                    #    TMP_CMD=`mv /etc/resolv.conf_tmp /etc/resolv.conf`
                    #fi
                    #TMP_CMD=`echo "nameserver $NIC_DNS1" >> /etc/resolv.conf`
                    TMP_CMD=`echo "nameserver $NIC_DNS1 ADD-1" >> $FILE_DAT`
                fi
                if [ "$NIC_DNS2" ] ; then
                    #TMP_CMD=`echo "nameserver $NIC_DNS2" >> /etc/resolv.conf`
                    TMP_CMD=`echo "nameserver $NIC_DNS2 ADD-2" >> $FILE_DAT`
                fi

                TMP_CMD=`echo "rmcctrl -k" >> $FILE_DAT 2>&1`
                TMP_CMD=`rmcctrl -k >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "rmcctrl -s" >> $FILE_DAT 2>&1`
                TMP_CMD=`rmcctrl -s >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "stopsrc -g rsct_rm" >> $FILE_DAT 2>&1`
                TMP_CMD=`stopsrc -g rsct_rm >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "stopsrc -g rsct" >> $FILE_DAT 2>&1`
                TMP_CMD=`stopsrc -g rsct >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "chdev -l cluster0 -a node_uuid=\"00000000-0000-0000-0000-000000000000\"" >> $FILE_DAT 2>&1`
                TMP_CMD=`chdev -l cluster0 -a node_uuid="00000000-0000-0000-0000-000000000000" >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "/usr/sbin/rsct/bin/mknodeid -f" >> $FILE_DAT 2>&1`
                TMP_CMD=`/usr/sbin/rsct/bin/mknodeid -f >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "/usr/sbin/rsct/bin/lsnodeid" >> $FILE_DAT 2>&1`
                TMP_CMD=`/usr/sbin/rsct/bin/lsnodeid >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "/usr/sbin/rsct/install/bin/recfgct" >> $FILE_DAT 2>&1`
                TMP_CMD=`/usr/sbin/rsct/install/bin/recfgct >> $FILE_DAT 2>&1`

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
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi

                TMP_VAR="BOOTPROTO-$NIC_NAME=\[none\]"
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi

                TMP_VAR="ONBOOT-$NIC_NAME=\[no\]"
                TMP_CMD=`cat $NIC_INFO_FILE 2>> $FILE_DAT | grep "$TMP_VAR" | wc -l`
                if [ $TMP_CMD = 0 ] ; then
                    echo "change ip info : $TMP_VAR" >> $FILE_DAT
                    NIC_UPDATE_FLAG=1
                fi

                if [ $NIC_UPDATE_FLAG = 1 ] ; then
                    echo "DEVICE-$NIC_NAME=[$NIC_NAME]" > $NIC_INFO_FILE
                    echo "BOOTPROTO-$NIC_NAME=[none]" >> $NIC_INFO_FILE
                    echo "ONBOOT-$NIC_NAME=[no]" >> $NIC_INFO_FILE

                    TMP_CMD=`rmdev -dl $NIC_NAME`

                    #echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
                    #echo "BOOTPROTO=none" >> $IFCFG_NAME
                    #echo "ONBOOT=no" >> $IFCFG_NAME

                    UPGRADE_FLAG=1
                else
                    echo "no change ip info ... skip" >> $FILE_DAT
                    echo "DEVICE-$NIC_NAME=[$NIC_NAME]" >> $FILE_DAT
                    echo "BOOTPROTO-$NIC_NAME=[none]" >> $FILE_DAT
                    echo "ONBOOT-$NIC_NAME=[no]" >> $FILE_DAT
                fi
            else
                echo "Interface BOOTPROT type unknown[$NIC_BOOTPROT]." >> $FILE_DAT
            fi
        fi
    fi

exit $UPGRADE_FLAG
