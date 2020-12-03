#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

NORMAL="Normal"
ABNORMAL="Abnormal"
NOTSUPPORT="N/S"

CMD_REAULT_FILE=../aproc/shell/prtpicl_v_c.dat
CMD_REAULT_FILE2=../aproc/shell/prtpicl_v_c_2.dat

cat $CMD_REAULT_FILE | egrep "temperature-sensor|Temperature" | egrep -v "_class|:Description" > $CMD_REAULT_FILE2

set OK NO_FAULT
l_strNormalStr=$*

l_nGatherStatus=0
l_nFirstFlag=0
l_nSensorCnt=0
l_strLastData=""


while read l_strBuf
do
    l_strLastStatus=$NOTSUPPORT
    l_nCheck=`echo $l_strBuf | grep -i "temperature-sensor" | wc -l`
    if [ $l_nCheck -eq 1 ] ; then
        l_nGatherStatus=1
        l_strDescription=`echo $l_strBuf | awk '{print $1}'`
        continue
    fi

    if [ $l_nGatherStatus -eq 1 ] ; then
        l_nCheck2=`echo $l_strBuf | grep -i "Temperature" | wc -l`
        if [ $l_nCheck2 -eq 1 ] ; then
            l_strTemperature=`echo $l_strBuf | awk '{print $2}'`
            l_nGatherStatus=2
            l_nSensorCnt=`expr $l_nSensorCnt + 1`
            echo "Sensor"$l_nSensorCnt"|"$l_strDescription"|"$l_strTemperature"|"$l_strLastStatus
            continue
        fi
    fi
done <$CMD_REAULT_FILE2

#\rm -f $CMD_REAULT_FILE



