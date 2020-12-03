#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#echo "$0 <MAC_ADDR> <STATIC|DHCP> [STATIC | <NIC_IP> <NIC_NETMASK> <NIC_GATEWAY> <NIC_DNS1> [<NIC_DNS2>]]"

FILE_DAT=../aproc/shell/ip_update.dat
IP_UPDATE_EXIT=../aproc/shell/ip_update.exit

TMP_CMD=`date > $FILE_DAT`
EXIT_VAL=255

NIC_NAME=""
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

        EXIT_VAL=`./shell/AIX/chdev_inet.sh $*;echo $?`

        if [ $EXIT_VAL = 1 ] ; then
            ifconfig -a >> $FILE_DAT 2>&1

            #./shell/AIX/network_service_restart.sh >> $FILE_DAT 2>&1

            EXIT_VAL=0
        else
            if [ $EXIT_VAL = 0 ] ; then
                ifconfig -a >> $FILE_DAT 2>&1
                echo "no change ip info... skip" >> $FILE_DAT
                EXIT_VAL=0
            else
                echo "ip update failed." >> $FILE_DAT
            fi
        fi

    else
        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
        #exit 255
    fi
    #echo "NIC_NAME=[$NIC_NAME]"
else
    echo "Not found interface mac addr : $1" >> $FILE_DAT
    exit 255
fi

IP_CHK=`netstat -ni | grep en | grep -v "link" | grep -v "0.0.0.0" | wc -l | awk '{print $1}'`

CHK_CNT=0
while [ "$IP_CHK" = "0" ]
do
    let "CHK_CNT = $CHK_CNT + 1"
    TMP_CMD=`echo "check...[$CHK_CNT] ==> $IP_CHK" >> $FILE_DAT`

    TMP_CMD=`echo "dhcp reinit ..." >> $FILE_DAT`

    TMP_CMD=`stopsrc -s dhcpcd`

    TMP_CMD=`cp /etc/dhcpcd.ini ../aproc/shell/dhcpcd.ini_b`
    TMP_CMD=`grep -v "interface any" /etc/dhcpcd.ini > /etc/dhcpcd.ini_`
    TMP_CMD=`grep -v "{" /etc/dhcpcd.ini_ > /etc/dhcpcd.ini`
    TMP_CMD=`grep -v "}" /etc/dhcpcd.ini > /etc/dhcpcd.ini_`
    TMP_CMD=`grep -v "^ option " /etc/dhcpcd.ini_ > /etc/dhcpcd.ini`
    TMP_CMD=`\rm -f /etc/dhcpcd.ini_`

    TMP_CMD=`ifconfig en0 down`
    TMP_CMD=`ifconfig et0 down`
    TMP_CMD=`ifconfig en1 down`
    TMP_CMD=`ifconfig et1 down`
    TMP_CMD=`ifconfig en2 down`
    TMP_CMD=`ifconfig et2 down`
    TMP_CMD=`rmdev -dl en0`
    TMP_CMD=`rmdev -dl et0`
    TMP_CMD=`rmdev -dl en1`
    TMP_CMD=`rmdev -dl et1`
    TMP_CMD=`rmdev -dl en2`
    TMP_CMD=`rmdev -dl et2`
    TMP_CMD=`cfgmgr`

    TMP_CMD=`/NCIA/POLESTAR/NNPAgent/MAgent/bin/shell/AIX/set_dhcp.sh >> $FILE_DAT`
    #TMP_CMD=`/usr/sbin/mktcpip -h'localhost' -a'10.175.14.126' -m'255.255.255.128' -i'en0' -n'10.180.213.179' -d'n-cloud.ncia.com' -g'10.175.14.1' -A'no' -t'N/A' -s'' >>  $FILE_DAT`


    TMP_CMD=`sleep 60`

    TMP_CMD=`echo "IP re-setting ..." >> $FILE_DAT`
    TMP_CMD=`\rm -f ./shell/AIX/ifcfg_set_$NIC_NAME`
    EXIT_VAL=`./shell/AIX/chdev_inet.sh $*;echo $?`

    if [ $EXIT_VAL = 1 ] ; then

        ifconfig -a >> $FILE_DAT 2>&1

        #./shell/AIX/network_service_restart.sh >> $FILE_DAT 2>&1

        EXIT_VAL=0
    else
        if [ $EXIT_VAL = 0 ] ; then
            ifconfig -a >> $FILE_DAT 2>&1
            echo "no change ip info... skip" >> $FILE_DAT
            EXIT_VAL=0
        else
            echo "ip update failed." >> $FILE_DAT
        fi
    fi

    IP_CHK=`netstat -ni | grep en | grep -v "link" | grep -v "0.0.0.0" | wc -l | awk '{print $1}'`

    if [ $CHK_CNT = 5 ] ; then
        TMP_CMD=`echo "IP re-setting try count over." >> $FILE_DAT`
        break
    fi
done

TMP_CMD=`echo "check...[$CHK_CNT] ==> $IP_CHK" >> $FILE_DAT`

echo "$EXIT_VAL" > $IP_UPDATE_EXIT
exit $EXIT_VAL
