#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/ip_bakup_$1.dat
CMD=`echo "" > $FILE_DAT`
COMMAND=`mkdir ../bin/shell/LINUX/recovery >> $FILE_DAT 2>&1 `
RECVRY_SHELL=../bin/shell/LINUX/recovery/ip_recovery_$1.sh
RECVRY_IP_FILE1=../bin/shell/LINUX/recovery/network_mac_old_$1.dat
RECVRY_IP_FILE2=../bin/shell/LINUX/recovery/ifcfg_file_old_$1.dat
MAC_INFO=$1
NIC_NAME=""
if [ $1 ] ; then

    COMMAND=`echo "ip recovery shell creating[$*]..." >> $FILE_DAT` 

    COMMAND=`echo \#\!/bin/sh > $RECVRY_SHELL`
    COMMAND=`echo "PATH=\\\$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin" >> $RECVRY_SHELL`
    COMMAND=`echo "export PATH" >> $RECVRY_SHELL`
    COMMAND=`echo "LANG=C" >> $RECVRY_SHELL`
    COMMAND=`echo "export LANG" >> $RECVRY_SHELL`
    COMMAND=`echo "FILE_DAT=../aproc/shell/ip_recovery_$1.dat" >> $RECVRY_SHELL`
    COMMAND=`echo "CMD=\\\`echo \"\" > \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "MAC_INFO=$1" >> $RECVRY_SHELL`
    COMMAND=`echo "if [ \\\$MAC_INFO ] ; then" >> $RECVRY_SHELL`
    COMMAND=`echo "    CMD=\\\`./shell/LINUX/ip_update.sh $* >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "else" >> $RECVRY_SHELL`
    COMMAND=`echo "    CMD=\\\`echo \"ip recovery info not found.\" >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "    exit 255" >> $RECVRY_SHELL`
    COMMAND=`echo "fi" >> $RECVRY_SHELL`
    COMMAND=`echo "CMD=\\\`echo \"ip recovery success.\" >> \\\$FILE_DAT\\\`" >> $RECVRY_SHELL`
    COMMAND=`echo "exit 0" >> $RECVRY_SHELL`
    COMMAND=`chmod +x $RECVRY_SHELL`

    COMMAND=`../../utils/ETC/network_mac | grep $1 > $RECVRY_IP_FILE1`
    NIC_NAME=`../../utils/ETC/network_mac | grep $1 |  cut -d'=' -f1 | cut -d',' -f1 | cut -d'[' -f2`
    if [ $NIC_NAME ] ; then
        echo "interface name : [$NIC_NAME]" >> $FILE_DAT
    else
        echo "Not found interface name : [$NIC_NAME]" >> $FILE_DAT
        exit 255
    fi
    COMMAND=`cat /etc/sysconfig/network-scripts/ifcfg-$NIC_NAME > $RECVRY_IP_FILE2`

    COMMAND=`echo "ip recovery shell created[$*]..." >> $FILE_DAT` 
else 
    COMMAND=`echo "ip argument intput error." >> $FILE_DAT`
    exit 255
fi

exit 0
