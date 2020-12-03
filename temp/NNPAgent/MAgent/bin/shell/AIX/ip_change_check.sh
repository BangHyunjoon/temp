#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/ip_change_check_$1.dat
CHK_RESULT_DAT=../aproc/shell/ip_change_check_$1.result.false
COMMAND=`echo "" > $FILE_DAT`
COMMAND=`mkdir ./shell/AIX/recovery >> $FILE_DAT 2>&1 `
EXEC_DATE=`date +%Y%m%d%H%M%S`
RECVRY_IP_NFILE1=./shell/AIX/recovery/network_mac_new_$1.dat
RECVRY_IP_OFILE1=./shell/AIX/recovery/network_mac_old_$1.dat

RECVRY_IP_DFILE1=./shell/AIX/recovery/network_mac_new_$1.dat.$EXEC_DATE

MAC_INFO=$1
NIC_NAME=""
COMMAND=`\rm -f $CHK_RESULT_DAT >> $FILE_DAT 2>&1`
if [ $1 ] ; then

    COMMAND=`echo "ip change checking[$1]..." >> $FILE_DAT` 

    COMMAND=`../../utils/ETC/network_mac | grep $1 > $RECVRY_IP_NFILE1`
    NIC_NAME=`../../utils/ETC/network_mac | grep $1 |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    if [ $NIC_NAME ] ; then
        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
        BAK_CFG_NICFILE=./shell/AIX/ifcfg_set_$NIC_NAME
    else
        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
        exit 255
    fi

    CHANGE_CHK=0
    CHANGE_CHK=`diff $RECVRY_IP_NFILE1 $RECVRY_IP_OFILE1 | wc -l 2>> $FILE_DAT`
    COMMAND=`echo "diff [$RECVRY_IP_NFILE1] [$RECVRY_IP_OFILE1] result : $CHANGE_CHK" >> $FILE_DAT` 
    if [ $CHANGE_CHK = 0 ] ; then
        COMMAND=`echo "ip change checked-1...[true:0]" >> $FILE_DAT` 
        echo "true" 
        exit 0
    else
        COMMAND=`echo "ip change checked-1...[false:255]" >> $FILE_DAT` 
        COMMAND=`echo "false" > $CHK_RESULT_DAT`
        COMMAND=`\rm -f $BAK_CFG_NICFILE`
        COMMAND=`\cp -f $RECVRY_IP_NFILE1 $RECVRY_IP_DFILE1`
        echo "false" 
        exit 255
    fi
else 
    COMMAND=`echo "ip argument intput error." >> $FILE_DAT`
    exit 255
fi
