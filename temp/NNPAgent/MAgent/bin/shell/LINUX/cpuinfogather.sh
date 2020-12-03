#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

FILE_DAT=../aproc/shell/cpudata.out

    cpuvmcheck=`grep 'physical id' /proc/cpuinfo | wc -l`
    if [ $cpuvmcheck -ge 1 ]; then
        cpuvmcheck=`grep 'cpu cores' /proc/cpuinfo | wc -l`
        if [ $cpuvmcheck -ge 1 ]; then
            cpuvmcheck=`grep 'siblings' /proc/cpuinfo | wc -l`
            if [ $cpuvmcheck -ge 1 ]; then
                vmcheck=1 
            else
                vmcheck=0 
            fi
        else
            vmcheck=0 
        fi
    else
        vmcheck=0
    fi

    if [ $vmcheck -eq 1 ]; then    
        ##'sibling' stands for Hyperthreaded Core Count Per CPUs
        siblingchk=`grep siblings /proc/cpuinfo | tail -1 | awk -F: '{print $2}'`
        #dedicated server(There are no duplicated lines, if 1core/1cpu)
        physicalCPUCntchk1=`grep -i 'physical id' /proc/cpuinfo | sort | uniq -d | wc -l`
        if [ $physicalCPUCntchk1 -eq 0 ]; then
            physicalCPUCntchk2=`grep -i 'physical id' /proc/cpuinfo | sort | uniq -u | wc -l`
            if [ $physicalCPUCntchk2 -eq 0 ]; then
                physicalCPUCnt="-"
            else
                physicalCPUCnt=$physicalCPUCntchk2
            fi               
        else
            physicalCPUCnt=$physicalCPUCntchk1
        fi
        ##check core information
        physicalcpucorecntPerCPUchk=`grep "^cpu cores" /proc/cpuinfo | wc -l`
        if [ $physicalcpucorecntPerCPUchk -eq 0 ]; then
            physicalcpucorecntPerCPU="-"
        else
            physicalcpucorecntPerCPU=`grep "^cpu cores" /proc/cpuinfo | tail -1 | awk -F: '{print $2}' | tr -d ' '`
        fi
        #count all physicalcpucorecnt
        if [ "$physicalCPUCnt" = "-" -o "$physicalcpucorecntPerCPU" = "-" ]; then
            physicalcpucorecnt="-"
        else
            physicalcpucorecnt=`expr $physicalCPUCnt \* $physicalcpucorecntPerCPU`
        fi
        logicalcpucorecnt=`grep -w "processor" /proc/cpuinfo | wc -l`       
    else
        physicalcpucorecnt="-"
        logicalcpucorecnt=`grep processor /proc/cpuinfo | wc -l`
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
