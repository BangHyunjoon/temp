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
SUCCESS_FILE=../aproc/shell/sensor_success.dat

prtpicl -v -c temperature-sensor > $CMD_REAULT_FILE

cat $CMD_REAULT_FILE | egrep "TEMPERATURE_SENSOR|Temperature|FaultInformation" | grep -v ":name" > $CMD_REAULT_FILE2

set OK NO_FAULT
l_strNormalStr=$*

l_nGatherStatus=0
l_nFirstFlag=0
l_nSensorCnt=0
l_strLastData=""

\rm -f $SUCCESS_FILE
while read l_strBuf
do
    l_strLastStatus=$NOTSUPPORT
    l_nCheck=`echo $l_strBuf | grep -i "TEMPERATURE_SENSOR" | wc -l`
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
            continue
        fi
    fi

    if [ $l_nGatherStatus -eq 2 ] ; then
        l_nCheck3=`echo $l_strBuf | grep -i "FaultInformation" | wc -l`
        if [ $l_nCheck3 -eq 1 ] ; then
            l_strStatus=`echo $l_strBuf | awk '{print $2}'`
            l_nGatherStatus=3
            l_nSensorCnt=`expr $l_nSensorCnt + 1`

            for l_strTok in `echo $l_strNormalStr`
            do
                l_nCheck=`echo $l_strStatus | grep $l_strTok | grep -v _$l_strTok | wc -l`
                if [ $l_nCheck -eq 1 ] ; then
                    l_strLastStatus=$NORMAL
                fi
            done

            echo "Sensor"$l_nSensorCnt"|"$l_strDescription"|"$l_strTemperature"|"$l_strLastStatus
            l_strDescription=""
            l_strTemperature=""
            l_strLastStatus=""
            touch $SUCCESS_FILE
            continue
        fi
    fi
done <$CMD_REAULT_FILE2

l_success_check=`ls -al $SUCCESS_FILE 2> /dev/null | wc -l`
if [ $l_success_check -eq 0 ] ; then
    ./SensorStatus_2.sh
fi


