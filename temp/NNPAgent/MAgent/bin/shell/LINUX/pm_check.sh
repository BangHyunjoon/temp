#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/ps_vdsm.dat
VDSM_CNT=../aproc/shell/ps_vdsm_cnt.dat
PM_TYPE=../aproc/shell/pm_type.dat
CMD=`echo "" > $FILE_DAT`
CMD=`echo "" > $VDSM_CNT`

PM_CNT=`ps -ef | grep "/vdsm " | grep -v grep | wc -l | awk '{print $1}'`
PM_VER=2

if [ $PM_CNT = 0 ] ; then
    PM_CNT=`ps -ef | grep "/usr/bin/python /usr/share/vdsm" | grep -v grep | wc -l | awk '{print $1}'`
    PM_VER=3
fi

if [ $PM_CNT = 0 ] ; then
    PM_CNT=`ps -ef | grep "\-kvm" | grep -v grep | wc -l | awk '{print $1}'`

    if [ $PM_CNT = 0 ] ; then
        PM_CNT=`ps -ef | grep "/qemu-dm " | grep -v grep | wc -l | awk '{print $1}'`

        if [ $PM_CNT = 0 ] ; then
            PM_CHK_CMD=`ps -ef | grep "/vdsm " | grep -v grep | wc -l | awk '{print $1}' >  $VDSM_CNT`
        else
            PM_CHK_CMD=`ps -ef | grep "/qemu-dm " | grep -v grep > $FILE_DAT 2>&1`
            PM_CHK_CMD=`ps -ef | grep "/qemu-dm " | grep -v grep | wc -l | awk '{print $1}' >  $VDSM_CNT`
            PM_CHK_CMD=`echo "QEMU" > $PM_TYPE`
        fi
    else
        PM_CHK_CMD=`ps -ef | grep "\-kvm" | grep -v grep > $FILE_DAT 2>&1`
        PM_CHK_CMD=`ps -ef | grep "\-kvm" | grep -v grep | wc -l | awk '{print $1}' >  $VDSM_CNT`
        PM_CHK_CMD=`echo "KVM" > $PM_TYPE`
    fi
else

    if [ $PM_CNT = 2 ] ; then
        PM_CHK_CMD=`ps -ef | grep "/vdsm " | grep -v grep > $FILE_DAT 2>&1`
        PM_CHK_CMD=`ps -ef | grep "/vdsm " | grep -v grep | wc -l | awk '{print $1}' >  $VDSM_CNT`
    else
        PM_CHK_CMD=`ps -ef | grep "/usr/bin/python /usr/share/vdsm" | grep -v grep > $FILE_DAT 2>&1`
        PM_CHK_CMD=`ps -ef | grep "/usr/bin/python /usr/share/vdsm" | grep -v grep | wc -l | awk '{print $1}' >  $VDSM_CNT`
    fi

    PM_CHK_CMD=`echo "RHEV" > $PM_TYPE`
fi


exit 0
