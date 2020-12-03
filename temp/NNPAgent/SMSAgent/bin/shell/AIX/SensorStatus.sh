#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

NORMAL="Normal"
ABNORMAL="Abnormal"

UESENSOR_RESULT_FILE=../aproc/shell/uesensor_l_result.dat

set Normal 
l_strNormalStr=$*

/usr/lpp/diagnostics/bin/uesensor -l > $UESENSOR_RESULT_FILE

l_nGatherStatus=0
l_nFoundFlag=0
l_nFirstFlag=0
l_nSensorCnt=0
l_strLastStatus="-"
l_strStatus="-"
l_strTemperature="-"
l_strDescription="-"

while read l_strBuf
do
    l_nCheck=`echo $l_strBuf | grep -i "thermal sensor" | wc -l`
    if [ $l_nCheck -eq 1 ] ; then
        l_nGatherStatus=1
        continue 
    fi

    if [ $l_nGatherStatus -eq 1 ] ; then
        l_nCheck2=`echo $l_strBuf | grep -i "Status" | wc -l`
        if [ $l_nCheck2 -eq 1 ] ; then
            l_strStatus=`echo $l_strBuf | awk -F'=' '{print $2}'`
            l_nGatherStatus=2
            continue
        fi
    fi

    if [ $l_nGatherStatus -eq 2 ] ; then
        l_nCheck3=`echo $l_strBuf | grep -i "Value" | wc -l`
        if [ $l_nCheck3 -eq 1 ] ; then
            l_strTemperature=`echo $l_strBuf | awk -F'=' '{print $2}' | awk '{print $1}'`
            l_nTypeCheck=`echo $l_strBuf | grep -i celsius | wc -l`
            if [ $l_nTypeCheck -eq 1 ] ; then
                l_strTemperature=$l_strTemperature
            else
                l_strTemperature=`echo "$l_strTemperature * 1.8 + 32"|bc`
            fi
            l_nGatherStatus=4
            continue
        fi
    fi

    if [ $l_nGatherStatus -eq 4 ] ; then
        l_nCheck4=`echo $l_strBuf | grep -i "Physical Location" | wc -l`
        if [ $l_nCheck4 -eq 1 ] ; then
            l_strDescription=`echo $l_strBuf | awk -F'=' '{print $2}'`
            l_nGatherStatus=5
            l_nSensorCnt=`expr $l_nSensorCnt + 1`

            l_nFoundFlag=0
            for l_strTok in `echo $l_strNormalStr`
            do
                l_nCheck=`echo $l_strStatus | grep ^$l_strTok | wc -l`
                if [ $l_nCheck -eq 1 ] ; then
                    l_strLastStatus=$NORMAL
                    l_nFoundFlag=1
                    break
                fi
            done

            if [ $l_nFoundFlag -ne 1 ] ; then
                l_strLastStatus=$ABNORMAL

            fi

            echo "Sensor"$l_nSensorCnt"|"$l_strDescription "|" $l_strTemperature "|" $l_strLastStatus

            l_strLastStatus="-"
            l_strStatus="-"
            l_strTemperature="-"
            l_strDescription="-"
            continue
        fi
    fi
done <$UESENSOR_RESULT_FILE

\rm -f $UESENSOR_RESULT_FILE
