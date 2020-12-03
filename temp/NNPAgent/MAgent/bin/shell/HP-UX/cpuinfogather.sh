#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

FILE_DAT=../aproc/shell/cpudata.out
RESULT_FILE=../aproc/shell/c_result.txt

    command=`which machinfo 2> /dev/null | grep -v "no " | wc -l`
    if [ $command -gt 0 ]; then
        machinfo > $RESULT_FILE
        logicalcpucorecnt=`/usr/sbin/ioscan -kf | grep processor | wc -l`
        IS_PM=`cat $RESULT_FILE | grep "processor model" | wc -l`
        if [ $IS_PM -ge 1 ]; then
            type=`cat $RESULT_FILE | grep "processor model:" | awk -F":" '{print $NF}' | awk -F"   " '{print $NF}'` 
            cpusocketcntchk=`cat $RESULT_FILE | grep -i "Number of enabled sockets" | wc -l`
            if [ $cpusocketcntchk -eq 0 ]; then
                 cpusocketcnt="-"
            else
                 cpusocketcnt=`cat $RESULT_FILE | grep -i "Number of enabled sockets" | awk '{print $NF}'`
            fi      
            physicalcpucorecnt="-"
        else    
            processornamechk=`cat $RESULT_FILE | grep -i "processor" | head -1 | awk '{print $1}' | wc -c`
            if [ $processornamechk -lt 5 ]; then
                type=`cat $RESULT_FILE | grep -i "processor" | head -1 | awk '{$1=""; print}'`
            else
                type=`cat $RESULT_FILE | grep -i "processor" | head -1`
            fi            
            physicalcpucorecntchk=`cat $RESULT_FILE | grep cores | wc -l`
            if [ $physicalcpucorecntchk -eq 0 ]; then
                cpusocketcntchk1=`cat $RESULT_FILE | grep -i "logical" | head -1 | awk '{print $1}'`
                cpusocketcntchk2=`cat $RESULT_FILE | grep -i "logical" | head -1 | awk -F"(" '{print $2}' | awk '{print $1}'`
                cpusocketcntchk3=`cat $RESULT_FILE | grep -i "logical" | head -1 | grep -i "socket" | wc -l`
                if [ $cpusocketcntchk3 -eq 0 ]; then
                    cpusocketcnt="-"
                else
                    cpusocketcnt=`expr $cpusocketcntchk1 / $cpusocketcntchk2`
                fi
                physicalcpucorecnt="-"
            else
                cpusocketcnt=`cat $RESULT_FILE | grep -i socket | head -2 | tail -1 | awk '{print $1}'`
                physicalcpucorecnt=`cat $RESULT_FILE | grep cores | tail -1 | awk '{print $1}'` 
            fi
        fi
    else
        physicalcpucorecnt=`/usr/sbin/ioscan -kf | grep processor | wc -l`
        logicalcpucorecnt=$physicalcpucorecnt
    fi

    if [ "$physicalcpucorecnt" = "-" ] ; then
        smtmodecheck=`kctune | grep lcpu_attr | awk '{print $2}'`
        if [ $smtmodecheck -eq 1 ] ; then #Hyperthread on
            physicalcpucorecnt="-"
        else
            physicalcpucorecnt=$logicalcpucorecnt
        fi
    fi


#echo $physicalcpucorecnt"|"$logicalcpucorecnt

last_cpu_cnt="-"
if [ "$physicalcpucorecnt" = "-" ] ; then
    if [ $logicalcpucorecnt -eq 1 ] ; then
        last_cpu_cnt=$logicalcpucorecnt
    else
        last_cpu_cnt=`expr $logicalcpucorecnt \/ 2`
    fi
else
    last_cpu_cnt=$physicalcpucorecnt 
fi

echo "CNT="$last_cpu_cnt > $FILE_DAT
