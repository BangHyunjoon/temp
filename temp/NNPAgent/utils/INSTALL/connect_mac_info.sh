#! /bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

HOMEPATH=`pwd`

FILE_DAT=../aproc/shell/connect_mac_info.dat
ERR_DAT=../aproc/shell/connect_mac_info.dat.err

echo "" > $FILE_DAT
TMP_CMD=`date`
echo "$TMP_CMD" > $ERR_DAT

#////////////////////////////
if [ $1 ]; then
    AUTO_UPGRADE_IP=$1
else 
    echo "usage : $0 <server ip> <server port>" >> $ERR_DAT
    exit 255
fi

if [ $2 ]; then
    AUTO_UPGRADE_PORT=$2
else
    echo "usage : $0 <server ip> <server port>" >> $ERR_DAT
    exit 255
fi

# CONNECT TRY ==> connect ip
LOCAL_IP=`../../utils/ETC/localip $AUTO_UPGRADE_IP $AUTO_UPGRADE_PORT 2>> $ERR_DAT`

echo "LOCAL_IP=$LOCAL_IP" >> $ERR_DAT
#////////////////////////////

if [ $LOCAL_IP ]; then

    MAC_INFO_FILE=../../utils/INSTALL/mac.info
    TMP_CMD=`../../utils/ETC/network_mac | grep UP > $MAC_INFO_FILE`

else
    echo "connect failed.($AUTO_UPGRADE_IP:$AUTO_UPGRADE_PORT)" >> $ERR_DAT
    exit 255
fi

MAC_DATA=""
F_MAC_DATA=""
MAC_CMP=0

while read line
do

    echo "read line=[$line]" >> $ERR_DAT
    IP_CHK=`echo $LOCAL_IP | wc -c | awk '{print $1}'`

    echo "IP_CHK(wc -c)=[$IP_CHK]" >> $ERR_DAT
    if [ $IP_CHK -gt 4 ] ; then
        IP_CHK=`echo $line | grep $LOCAL_IP | wc -l | awk '{print $1}'`
        echo "IP_CHK(wc -l)==>[$IP_CHK]" >> $ERR_DAT
        if [ $IP_CHK = 1 ] ; then
            MAC_INFO=`echo $line | cut -d'=' -f2`
            MAC_CHECK=`echo $MAC_INFO | wc -c | awk '{print $1}'`

            echo "LOCAL IP : [$MAC_INFO]=$MAC_CHECK" >> $ERR_DAT

            if [ $MAC_CHECK = 18 ] ; then
                echo "$LOCAL_IP=$MAC_INFO" > $FILE_DAT
                break
            fi
        fi
    else
        echo "connect failed.($AUTO_UPGRADE_IP:$AUTO_UPGRADE_PORT)-error local ip($LOCAL_IP)" >> $ERR_DAT
        exit 255
    fi

done <$MAC_INFO_FILE

exit 0
