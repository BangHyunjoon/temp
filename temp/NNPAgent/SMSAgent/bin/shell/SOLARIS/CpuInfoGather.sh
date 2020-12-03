#!/bin/sh
LANG=C;export LANG

LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH

chk=`uname -a | grep -i sparc | wc -l`
if [ $chk -eq 0 ]; then
    vendor="Intel"
else
    vendor="SUN"
fi
cpusocketcnt=`psrinfo -p 2> /dev/null`
if [ -z "$cpusocketcnt" ]; then
    cpusocketcnt="-"
fi
command=`which kstat 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    #echo "kstat command not found"
    ./CpuInfoCollect > ./result.txt
    value=`grep -i failed ./result.txt | wc -l`
    if [ $value -eq 1 ]; then
        model="-"
        type="-"
        speed="-"
        logicalcpucorecnt="-"
        physicalcpucorecnt=$logicalcpucorecnt
        hyperthreading="-"
    else
        model=`grep -i NKIACPU ./result.txt | awk -F"|" '{print $2}'`
        type=`grep -i NKIACPU ./result.txt | awk -F"|" '{print $3}'`
        speed=`grep -i NKIACPU ./result.txt | awk -F"|" '{print $4}'`
        logicalcpucorecnt=`grep -i NKIACPU ./result.txt | awk -F"|" '{print $5}'`
        physicalcpucorecnt=$logicalcpucorecnt
        hyperthreading=off
    fi
else
    LD_LIBRARY_PATH=/lib:/usr/lib
    export LD_LIBRARY_PATH
    /usr/bin/kstat -m cpu_info > ./result.txt
    model=`cat ./result.txt | grep -i implementation | head -1 | awk '{print $2}'`
    type=`cat ./result.txt | grep -i fpu_type | head -1 | awk '{print $2}'`
    speed=`cat ./result.txt | grep -i clock_MHz | head -1 | awk '{print $2}'`
    
    virtualchk=`cat ./result.txt | grep core_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
    if [ $virtualchk -eq 0 ]; then
        ##dedicated server       
        l_check=`cat ./result.txt | grep chip_id | wc -l`
        if [ $l_check -ge 1 ] ; then
            physicalcpucorecnt=`cat ./result.txt | grep chip_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
            logicalcpucorecnt=$physicalcpucorecnt
            thread=`expr $logicalcpucorecnt \/ $physicalcpucorecnt`   
        else
            physicalcpucorecnt=`cat ./result.txt | grep module | grep cpu_info | wc -l`
            logicalcpucorecnt=$physicalcpucorecnt
        fi
    else        
        ##zoned server        
        physicalcpucorecnt=`cat ./result.txt | grep core_id | awk '{print $2}' | sort -u | wc -l | tr -d ' '`
        logicalcpucorecnt=`cat ./result.txt | grep module | awk '{print $4}' | wc -l | tr -d ' '`
        thread=`expr $logicalcpucorecnt \/ $physicalcpucorecnt`
    fi
    if [ $logicalcpucorecnt -gt $physicalcpucorecnt ]; then
        hyperthreading=on
    else
        hyperthreading=off
    fi
fi
if [ -z "$type" ]; then
    fpu=false
else
    fpu=true
fi

if [ -z "$model" ]; then
    model="-"
fi
if [ -z "$type" ]; then
    type="-"
fi
if [ -z "$speed" ]; then
    speed="-"
fi


echo $vendor"|"$model"|"$type"|"$speed"|"$cpusocketcnt"|"$physicalcpucorecnt"|"$logicalcpucorecnt"|"$hyperthreading"|"$fpu
\rm ./result.txt 2> /dev/null
