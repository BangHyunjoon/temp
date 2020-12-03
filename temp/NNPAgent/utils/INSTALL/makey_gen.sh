#! /bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

HOMEPATH=`pwd`

#////////////////////////////
# GET URL(AUTO_UPGRADE_DNS)
AUTO_UPGRADE_DNS=""
AUTO_UPGRADE_DNS=`grep "^AUTO_UPGRADE_DNS=" ../conf/MasterAgent.conf | cut -d'=' -f2`

# GET IP(AUTO_UPGRADE_IP)
if [ $AUTO_UPGRADE_DNS ]; then
    TMP_CMD=`./shell/LINUX/nslookup.sh $AUTO_UPGRADE_DNS`
    if [ -f ../aproc/shell/nslookup_ip.dat ] ; then
        AUTO_UPGRADE_IP_CHK=`cat ../aproc/shell/nslookup_ip.dat | wc -c`
        if [ $AUTO_UPGRADE_IP_CHK -gt 4 ] ; then
            AUTO_UPGRADE_IP=`cat ../aproc/shell/nslookup_ip.dat`
        else
            AUTO_UPGRADE_IP=`grep "^AUTO_UPGRADE_IP=" ../conf/MasterAgent.conf | cut -d'=' -f2`
        fi
    else
        AUTO_UPGRADE_IP=`grep "^AUTO_UPGRADE_IP=" ../conf/MasterAgent.conf | cut -d'=' -f2`
    fi
else
    AUTO_UPGRADE_IP=`grep "^AUTO_UPGRADE_IP=" ../conf/MasterAgent.conf | cut -d'=' -f2`
fi

# GET PORT(AUTO_UPGRADE_PORT)
AUTO_UPGRADE_PORT=`grep "^AUTO_UPGRADE_PORT=" ../conf/MasterAgent.conf | cut -d'=' -f2`

# CONNECT TRY ==> connect ip
LOCAL_IP=`../../utils/ETC/localip $AUTO_UPGRADE_IP $AUTO_UPGRADE_PORT`

# echo "LOCAL_IP=$LOCAL_IP"
#////////////////////////////

MAC_INFO_FILE=../../utils/INSTALL/mac.info
TMP_CMD=`../../utils/ETC/network_mac 1 | grep UP > $MAC_INFO_FILE`

MAC_DATA=""
F_MAC_DATA=""
MAC_CMP=0

while read line
do

    #echo "read line=[$line]"
    IP_CHK=`echo $LOCAL_IP | wc -c`

    #echo "IP_CHK=$IP_CHK"
    if [ $IP_CHK -gt 4 ] ; then
        IP_CHK=`echo $line | grep $LOCAL_IP | wc -l`
        if [ $IP_CHK = 1 ] ; then
            MAC_INFO=`echo $line | cut -d'=' -f2`
            MAC_CHECK=`echo $MAC_INFO | wc -c`

            #echo "LOCAL IP : [$MAC_INFO]=$MAC_CHECK"

            if [ $MAC_CHECK = 13 ] ; then
                echo $MAC_INFO
                break
            fi
        fi
    else
        MAC_INFO=`echo $line | cut -d'=' -f2`
        MAC_CHECK=`echo $MAC_INFO | wc -c`

        #echo "NON LOCAL IP[$MAC_INFO]=$MAC_CHECK"

        if [ $MAC_CHECK = 13 ] ; then
            echo $MAC_INFO
            break
        fi
    fi

done <$MAC_INFO_FILE

