#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

NORMAL="Normal"
ABNORMAL="Abnormal"

CMD_REAULT_FILE=./prtdiag_v_result.dat

prtdiag -v | grep _FAN | grep -v DISABLED > $CMD_REAULT_FILE

set OK NO_FAULT
l_strNormalStr=$*
l_nSensorCnt=0

while read l_strBuf
do
    l_strLastStatus="-"
    l_nFoundFlag=0
    l_nFieldCnt=`echo $l_strBuf | awk '{print NF}'`
    if [ $l_nFieldCnt -eq 4 ] ; then
        l_strRpm=`echo $l_strBuf | awk '{print $3}'`
        l_strStatus=`echo $l_strBuf | awk '{print $4}'`
        l_strDescription=`echo $l_strBuf | awk '{print $2}'`
        l_nSensorCnt=`expr $l_nSensorCnt + 1`

        for l_strTok in `echo $l_strNormalStr`
        do
            l_nCheck=`echo $l_strStatus | grep $l_strTok | grep -v _$l_strTok | wc -l`
            if [ $l_nCheck -eq 1 ] ; then
                l_strLastStatus=$NORMAL
                l_nFoundFlag=1
                break
            fi
        done

        if [ $l_nFoundFlag -ne 1 ] ; then
            l_strLastStatus=$ABNORMAL
        fi

        echo "FAN"$l_nSensorCnt"|"$l_strDescription"|"$l_strRpm"|"$l_strLastStatus
    fi
done <$CMD_REAULT_FILE

\rm -f $CMD_REAULT_FILE
