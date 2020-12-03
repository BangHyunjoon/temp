#!/bin/sh
LANG=C;export LANG
VALUE=`which dmidecode 2> /dev/null |  wc -l`
if [ $VALUE -eq 0 ]; then
    speed=`grep -i Mhz /proc/cpuinfo | egrep -v "model|fsb" | sort -u | awk '{print $4}' | awk -F. '{print $1}' | sort -rn | head -1`
else
    speedchk=`dmidecode 2> /dev/null | grep -i "current speed" | head -1 | awk '{print $3}' | wc -l`
    if [ $speedchk -eq 0 ]; then
        speed=`grep -i Mhz  /proc/cpuinfo | egrep -v "model|fsb" | sort -u | awk '{print $4}' | awk -F. '{print $1}' | sort -rn | head -1`
    else
        speed=`dmidecode 2> /dev/null | grep -i "current speed" | head -1 | awk '{print $3}'`
    fi
fi
fpu=`grep -i "^fpu" /proc/cpuinfo | grep -v "fpu_exception" | tail -1 | awk -F: '{print $2}'`
if [ -z "$fpu" ]; then
    fpu="false"
else
    fpu="true"
fi
model=`grep -i "model name" /proc/cpuinfo | tail -1 | awk -F: '{print $2}'`
vendor=`egrep -i "vendor_id|vendor" /proc/cpuinfo | tail -1 | awk -F: '{print $2}'`
value=`echo $vendor | grep -i Intel | wc -l`
if [ $value -eq 1 ]; then
    type="Intel"
fi
value=`echo $vendor | grep -i AMD | wc -l`
if [ $value -eq 1 ]; then
    type="AMD"
fi

machine=`uname -m`
value=`echo $machine | grep -i ia | wc -l`
if [ $value -eq 1 ]; then
    if [ -z "$model" ]; then
        model=`grep -i "^arch" /proc/cpuinfo | egrep -iv "archrev" | tail -1 | awk -F: '{print $2}'`
    fi
fi
value=`echo $machine | grep -i ppc | wc -l`
if [ $value -eq 1 ]; then
    if [ -z "$model" ]; then
        model=`grep -i "^machine" /proc/cpuinfo | tail -1 | awk -F: '{print $2}'`
    fi
fi

if [ -f /etc/SuSE-release ]; then
    dmesgpath="/var/log/boot.msg"
else
    dmesgpath="/var/log/dmesg"
fi

##'sibling' stands for Hyperthreaded Core Count Per CPUs
siblingchk=`grep siblings /proc/cpuinfo | tail -1 | awk -F: '{print $2}'`

#virtualchk=`grep -i "model name" /proc/cpuinfo | grep -i virtual | wc -l`
#if [ $virtualchk -eq 0 ]; then    
    #virtualchkagain=`egrep -i "vmware|hypervisor" $dmesgpath | wc -l`
    #if [ $virtualchkagain -eq 0 ]; then
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
       if [ "$physicalCPUCnt" = "-" ] || [ "$physicalcpucorecntPerCPU" = "-" ]; then
           allphysicalcpucorecnt="-"
           thread=0
           hyperthreading=off
       else
           allphysicalcpucorecnt=`expr $physicalCPUCnt \* $physicalcpucorecntPerCPU`
           thread=`expr $siblingchk \/ $physicalcpucorecntPerCPU`
             if [ $siblingchk -gt $physicalcpucorecntPerCPU ]; then
                  hyperthreading=on
            else
                hyperthreading=off
             fi                           
        fi
        logicalcpucorecnt=`grep -w "^processor" /proc/cpuinfo | wc -l`       
    #else
    #    physicalCPUCnt="-"
    #    physicalcpucorecntPerCPU="-"
    #    allphysicalcpucorecnt="-"
    #    logicalcpucorecnt=`grep ^processor /proc/cpuinfo | wc -l`
    #    hyperthreading=off
    #    thread=1
    #fi        
#else
#      physicalCPUCnt="-"
#      physicalcpucorecntPerCPU="-"
#      allphysicalcpucorecnt="-"
#      logicalcpucorecnt=`grep ^processor /proc/cpuinfo | wc -l`
#      hyperthreading=off
#      thread=1
#fi

if [ -z "$model" ] ; then
    model="-"
fi
if [ -z "$type" ] ; then
    type="-"
fi
if [ -z "$speed" ] ; then
    speed="-"
fi
echo $vendor"|"$model"|"$type"|"$speed"|"$physicalCPUCnt"|"$allphysicalcpucorecnt"|"$logicalcpucorecnt"|"$hyperthreading"|"$fpu
