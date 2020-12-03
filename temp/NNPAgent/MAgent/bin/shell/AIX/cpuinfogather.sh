#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

FILE_DAT=../aproc/shell/cpudata.out
RESULT_FILE=../aproc/shell/c_result.txt

    prtconf > $RESULT_FILE
    grepchk=`cat $RESULT_FILE | grep -i "System Model" | awk '{print $3}' | wc -l`
    if [ $grepchk -eq 0 ]; then
        line=`cat $RESULT_FILE | grep -n Hz | awk -F: '{print $1}'`
        cpulinenum=`expr $line \- 1`
        cpucorecnt=`cat $RESULT_FILE | head -n $cpulinenum | tail -n 1 | awk -F: '{print $NF}'`
    else
        cpucorecnt=`cat $RESULT_FILE | grep -i "Number Of Processors" | awk '{print $NF}'`
    fi

    aixchk=`oslevel | awk -F. '{print $1$2}'`
    if [ $aixchk -ge 53 ]; then
        proc=`lsdev -C | grep proc | head -n 1 | awk '{print $1}'` ##head -1 error -> head -n 1
        smtlevel=`lsattr -El $proc | grep smt_threads| awk '{print $2}'`
        if [ $smtlevel -eq 0 ]; then
           smtlevel=1
        fi
        physicalcpucorecnt=$cpucorecnt
        logicalcpucorecnt=`expr $cpucorecnt \* $smtlevel`
    elif [ $aixchk -lt 53 ]; then
        physicalcpucorecnt=$cpucorecnt
        logicalcpucorecnt=$cpucorecnt
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
