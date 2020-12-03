#!/bin/sh

LD_LIBRARY_PATH=/nkia/NNPAgent/LIB
export LD_LIBRARY_PATH

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ifcfg_update.dat
NIC_NAME=""
NIC_BOOTPROT=""
NIC_IP=""
NIC_NETMASK=""
NIC_BITMASK=""
NIC_GATEWAY=""
NIC_DNS1=""
NIC_DNS2=""
TMP_CMD=0
RESULT=0
TMP_CHK=`date > $FILE_DAT`

NIC_NAME_FILE=../aproc/shell/mac_nic_mapping.dat
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
        if [ "$NIC_NETMASK" = "255.255.255.255" ] ; then
            NIC_BITMASK="32"
        else
          if [ "$NIC_NETMASK" = "255.255.255.254" ] ; then
              NIC_BITMASK="31"
          else
          if [ "$NIC_NETMASK" = "255.255.255.252" ] ; then
              NIC_BITMASK="30"
          else
          if [ "$NIC_NETMASK" = "255.255.255.248" ] ; then
              NIC_BITMASK="29"
          else
          if [ "$NIC_NETMASK" = "255.255.255.240" ] ; then
              NIC_BITMASK="28"
          else
          if [ "$NIC_NETMASK" = "255.255.255.224" ] ; then
              NIC_BITMASK="27"
          else
          if [ "$NIC_NETMASK" = "255.255.255.192" ] ; then
              NIC_BITMASK="26"
          else
          if [ "$NIC_NETMASK" = "255.255.255.128" ] ; then
              NIC_BITMASK="25"
          else
          if [ "$NIC_NETMASK" = "255.255.255.0" ] ; then
              NIC_BITMASK="24"
          else
          if [ "$NIC_NETMASK" = "255.255.254.255" ] ; then
              NIC_BITMASK="23"
          else
          if [ "$NIC_NETMASK" = "255.255.252.255" ] ; then
              NIC_BITMASK="22"
          else
          if [ "$NIC_NETMASK" = "255.255.248.255" ] ; then
              NIC_BITMASK="21"
          else
          if [ "$NIC_NETMASK" = "255.255.240.255" ] ; then
              NIC_BITMASK="20"
          else
          if [ "$NIC_NETMASK" = "255.255.224.255" ] ; then
              NIC_BITMASK="19"
          else
          if [ "$NIC_NETMASK" = "255.255.192.255" ] ; then
              NIC_BITMASK="18"
          else
          if [ "$NIC_NETMASK" = "255.255.128.255" ] ; then
              NIC_BITMASK="17"
          else
          if [ "$NIC_NETMASK" = "255.255.0.255" ] ; then
              NIC_BITMASK="16"
          else
          if [ "$NIC_NETMASK" = "255.254.255.255" ] ; then
              NIC_BITMASK="15"
          else
          if [ "$NIC_NETMASK" = "255.252.255.255" ] ; then
              NIC_BITMASK="14"
          else
          if [ "$NIC_NETMASK" = "255.248.0.0" ] ; then
              NIC_BITMASK="13"
          else
          if [ "$NIC_NETMASK" = "255.240.0.0" ] ; then
              NIC_BITMASK="12"
          else
          if [ "$NIC_NETMASK" = "255.224.0.0" ] ; then
              NIC_BITMASK="11"
          else
          if [ "$NIC_NETMASK" = "255.192.0.0" ] ; then
              NIC_BITMASK="10"
          else
          if [ "$NIC_NETMASK" = "255.128.0.0" ] ; then
              NIC_BITMASK="9"
          else
          if [ "$NIC_NETMASK" = "255.0.0.0" ] ; then
              NIC_BITMASK="8"
          else
          if [ "$NIC_NETMASK" = "254.0.0.0" ] ; then
              NIC_BITMASK="7"
          else
          if [ "$NIC_NETMASK" = "252.0.0.0" ] ; then
              NIC_BITMASK="6"
          else
          if [ "$NIC_NETMASK" = "248.0.0.0" ] ; then
              NIC_BITMASK="5"
          else
          if [ "$NIC_NETMASK" = "240.0.0.0" ] ; then
              NIC_BITMASK="4"
          else
          if [ "$NIC_NETMASK" = "224.0.0.0" ] ; then
              NIC_BITMASK="3"
          else
          if [ "$NIC_NETMASK" = "192.0.0.0" ] ; then
              NIC_BITMASK="2"
          else
          if [ "$NIC_NETMASK" = "128.0.0.0" ] ; then
              NIC_BITMASK="1"
          else
          if [ "$NIC_NETMASK" = "0.0.0.0" ] ; then
              NIC_BITMASK="0"
          fi #0
          fi #1
          fi #2
          fi #3
          fi #4
          fi #5
          fi #6
          fi #7
          fi #8
          fi #9
          fi #10
          fi #11
          fi #12
          fi #13
          fi #14
          fi #15
          fi #16
          fi #17
          fi #18
          fi #19
          fi #20
          fi #21
          fi #22
          fi #23
          fi #24
          fi #25
          fi #26
          fi #27
          fi #28
          fi #29
          fi #30
          fi #31
        fi #32
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
NIC_INFO_FILE=./shell/SOLARIS/ifcfg_set_$NIC_NAME
NIC_UPDATE_FLAG=0
#if [ -d /etc/sysconfig/network-scripts ] ; then
#    echo "RedHat Interfaces setting..." >> $FILE_DAT
#    IFCFG_NAME=/etc/sysconfig/network-scripts/ifcfg-$NIC_NAME
#    ROUTE_NAME=/etc/sysconfig/network-scripts/route-$NIC_NAME
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

            TMP_CMD=`echo "ipadm delete-addr $NIC_NAME/v4" >> $FILE_DAT 2>&1`
            TMP_CMD=`ipadm delete-addr $NIC_NAME/v4 >> $FILE_DAT 2>&1`           
            TMP_CMD=`echo "ipadm create-ip $NIC_NAME" >> $FILE_DAT 2>&1`
            TMP_CMD=`ipadm create-ip $NIC_NAME >> $FILE_DAT 2>&1`
            TMP_CMD=`echo "ipadm create-addr -T dhcp $NIC_NAME/dhcp" >> $FILE_DAT 2>&1`
            TMP_CMD=`ipadm create-addr -T dhcp $NIC_NAME/dhcp >> $FILE_DAT 2>&1`           
#            echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
#            echo "BOOTPROTO=dhcp" >> $IFCFG_NAME
#            echo "ONBOOT=yes" >> $IFCFG_NAME

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

                TMP_CMD=`echo "ipadm delete-addr $NIC_NAME/v4" >> $FILE_DAT 2>&1`
                TMP_CMD=`ipadm delete-addr $NIC_NAME/v4 >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "ipadm create-ip $NIC_NAME" >> $FILE_DAT 2>&1`
                TMP_CMD=`ipadm create-ip $NIC_NAME >> $FILE_DAT 2>&1`
                TMP_CMD=`echo "ipadm create-addr -T static -a $NIC_IP/$NIC_BITMASK $NIC_NAME/v4" >> $FILE_DAT 2>&1`
                TMP_CMD=`ipadm create-addr -T static -a $NIC_IP/$NIC_BITMASK $NIC_NAME/v4 >> $FILE_DAT 2>&1`           
                if [ "$NIC_GATEWAY" ] ; then
                    TMP_CMD=`echo "route -p add default $NIC_GATEWAY" >> $FILE_DAT 2>&1`
                    TMP_CMD=`route -p add default $NIC_GATEWAY >> $FILE_DAT 2>&1`           
                fi
#                echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
#                echo "BOOTPROTO=none" >> $IFCFG_NAME
#                echo "ONBOOT=yes" >> $IFCFG_NAME
#                echo "IPADDR=$NIC_IP" >> $IFCFG_NAME
#                echo "NETMASK=$NIC_NETMASK" >> $IFCFG_NAME

#                BACKUP_NETCHECK=""
#                BACKUP_NETWORK=""
#                if [ "$NIC_GATEWAY" ] ; then
#                    BACKUP_NETCHECK=`grep BACKUP_NETCHECK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
#                    BACKUP_NETWORK=`grep BACKUP_NETWORK ../conf/MasterAgent.conf | grep "\." | cut -d'=' -f2 | awk '{print $1}'`
#                    if [ "$BACKUP_NETCHECK" = "" ] ; then
#                        echo "GATEWAY=$NIC_GATEWAY" >> $IFCFG_NAME
#                    else
#                        TMP_CMD=`echo "$NIC_GATEWAY" | grep "$BACKUP_NETCHECK" | wc -l | awk '{print $1}'`
#                        if [ "$TMP_CMD" = "0" ] ; then
#                            echo "GATEWAY=$NIC_GATEWAY" >> $IFCFG_NAME
#                        else
#                            TMP_CMD=`echo ADDRESS0=$BACKUP_NETWORK > $ROUTE_NAME`
#                            TMP_CMD=`echo NETMASK0=255.255.0.0 >> $ROUTE_NAME`
#                            TMP_CMD=`echo GATEWAY0=$NIC_GATEWAY > $ROUTE_NAME`
#                        fi
#                    fi
#                fi
#                echo "TYPE=Ethernet" >> $IFCFG_NAME
#                echo "USERCTL=no" >> $IFCFG_NAME
#                echo "IPV6INIT=no" >> $IFCFG_NAME
#                echo "PEERDNS=yes" >> $IFCFG_NAME
#                if [ "$NIC_DNS1" ] ; then
#                    echo "DNS1=$NIC_DNS1" >> $IFCFG_NAME
#                fi
#                if [ "$NIC_DNS2" ] ; then
#                    echo "DNS2=$NIC_DNS2" >> $IFCFG_NAME
#                fi

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

               
                    TMP_CMD=`echo "ipadm delete-addr $NIC_NAME/v4" >> $FILE_DAT 2>&1`
                    TMP_CMD=`ipadm delete-addr $NIC_NAME/v4 >> $FILE_DAT 2>&1`
#                    echo "DEVICE=$NIC_NAME" > $IFCFG_NAME
#                    echo "BOOTPROTO=none" >> $IFCFG_NAME
#                    echo "ONBOOT=no" >> $IFCFG_NAME

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
#fi

exit $UPGRADE_FLAG

