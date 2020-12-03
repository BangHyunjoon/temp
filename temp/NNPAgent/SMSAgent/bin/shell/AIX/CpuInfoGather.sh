#!/bin/sh
LANG=C;export LANG
LC_ALL=C;export LC_ALL

##Sockets are not counted on. No way, No need.
cpusocketcnt="-"
fpu="-"

##Sometimes, error occurs on the command below(prtconf > ./result.txt). Ignore this massege.
##0516-010 : Volume group must be varied on; use varyonvg command.
##See this, http://www-01.ibm.com/support/docview.wss?uid=isg1IV00910
prtconf > ./result.txt

#'grepchk' is to check characters whether they are broken or not in  'result.txt' file.
grepchk=`cat ./result.txt | grep -i "System Model" | awk '{print $3}' | wc -l`
if [ $grepchk -eq 0 ]; then 
    model=`cat ./result.txt | head -n 1 | awk '{print $3}'`
    type=`cat ./result.txt | head -n 3 | tail -n 1 | awk '{print $NF}'`    
    line=`cat ./result.txt | grep -n Hz | awk -F: '{print $1}'`
    cpulinenum=`expr $line \- 1`
    cpucorecnt=`cat ./result.txt | head -n $cpulinenum | tail -n 1 | awk -F: '{print $NF}'`
    #cpucorecnt=`lsdev -C | grep proc | wc -l`
else
    model=`cat ./result.txt | grep -i "System Model" | awk '{print $3}'`
    type=`cat ./result.txt | grep -i "Processor Type" | awk '{print $NF}'`
    cpucorecnt=`cat ./result.txt | grep -i "Number Of Processors" | awk '{print $NF}'`
fi
#speedchk is the number of cpu clock speed. 
speedchk1=`cat ./result.txt | grep "Hz" | head -n 1 | awk '{print $(NF-1)}'`
speedchk2=`cat ./result.txt | grep "Hz" | head -n 1 | awk '{print $(NF)}'`
if [ $speedchk2 = "MHz" ]; then
     speed=$speedchk1
else     
    #Change GHz to MHz
    speed=`echo "scale=3;$speedchk1 * 1000" | bc`
fi

aixchk=`oslevel | awk -F. '{print $1$2}'`
if [ $aixchk -ge 53 ]; then
    proc=`lsdev -C | grep proc | head -n 1 | awk '{print $1}'` ##head -1 error -> head -n 1    
    #'smtlevel' is for checking the number of smtlevel
    #smtlevel=`lsattr -El $proc | grep smt_threads| awk '{print $2}'`
    smtlevel=`smtctl | grep ^proc | grep thread | head -1 | awk '{print $3}'`
    if [ -z "$smtlevel" ]; then
        smtlevel=`lsattr -El $proc | grep smt_threads| awk '{print $2}'`
    fi
    if [ $smtlevel -eq 0 ]; then
       smtlevel=1
    fi

    #'lpared' is to check the systems whether they are lpared or not.
    lpared=`lparstat -i | head -n 4 | tail -n 1 | grep -i shared | wc -l`

    if [ $smtlevel -le 1 ]; then
    	hyperthreading=off
    else
    	hyperthreading=on
    fi   
    if [ $lpared -eq 0 ]; then
       physicalcpucorecnt=$cpucorecnt
       logicalcpucorecnt=`expr $cpucorecnt \* $smtlevel`
    else
       #physicalcpucorecnt=LPARED
       ## If servers are Lpared, they share Physical Cores. So, Logical Cores are calculated with 'shared physcial cores'.
       ## Logical Cores are far more then Physical Cores on each servers.
       ##physicalcpucorecnt=`lparstat -i | grep "Entitled Capacity" | head -n 1 | awk '{print $NF}' | awk -F. '{print $1}'`
       physicalcpucorecnt=$cpucorecnt
       ##sharedphysicalcpucorecnt=`lparstat -i | grep "Online Virtual CPUs" | head -n 1 | awk '{print $NF}'`
       ##logicalcpucorecnt=`expr $sharedphysicalcpucorecnt \* $smtlevel`
       logicalcpucorecnt=`expr $cpucorecnt \* $smtlevel`
    fi
elif [ $aixchk -lt 53 ]; then      
    #In Lower AIX version then AIX 5300, smt and logical partitioning are not embeded. 
    smtlevel=1
    hyperthreading=off
    physicalcpucorecnt=$cpucorecnt
    logicalcpucorecnt=$cpucorecnt
fi
vendor=IBM
if [ -z "$speed" ]; then
     speed="0"
fi
echo $vendor"|"$model"|"$type"|"$speed"|"$cpusocketcnt"|"$physicalcpucorecnt"|"$logicalcpucorecnt"|"$hyperthreading"|"$fpu
\rm ./result.txt 2> /dev/null
