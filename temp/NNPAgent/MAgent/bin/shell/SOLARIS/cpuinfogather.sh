#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

FILE_DAT=../aproc/shell/cpudata.out
RESULT_FILE=../aproc/shell/c_result.txt

    command=`which kstat 2> /dev/null | grep -v "no " | wc -l`
    if [ $command -eq 0 ]; then
        ./CpuInfoCollect > $RESULT_FILE
        value=`grep -i failed $RESULT_FILE | wc -l`
        if [ $value -eq 1 ]; then
            logicalcpucorecnt="-"
            physicalcpucorecnt=$logicalcpucorecnt
        else
            logicalcpucorecnt=`grep -i NKIACPU $RESULT_FILE | awk -F"|" '{print $5}'`
            physicalcpucorecnt=$logicalcpucorecnt
        fi
    else
        LD_LIBRARY_PATH=/lib:/usr/lib
        export LD_LIBRARY_PATH
        /usr/bin/kstat -m cpu_info > $RESULT_FILE
    
        virtualchk=`cat $RESULT_FILE | grep core_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
        if [ $virtualchk -eq 0 ]; then
            ##dedicated server       
            l_check=`cat $RESULT_FILE | grep chip_id | wc -l`
            if [ $l_check -ge 1 ] ; then
                physicalcpucorecnt=`cat $RESULT_FILE | grep chip_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
                logicalcpucorecnt=$physicalcpucorecnt
            else
                physicalcpucorecnt=`cat $RESULT_FILE | grep module | grep cpu_info | wc -l` 
                logicalcpucorecnt=$physicalcpucorecnt
            fi
        else        
            ##zoned server        
            physicalcpucorecnt=`cat $RESULT_FILE | grep core_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
            logicalcpucorecnt=`cat $RESULT_FILE | grep module | awk '{print $4}' | wc -l | tr -d ' '`
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
