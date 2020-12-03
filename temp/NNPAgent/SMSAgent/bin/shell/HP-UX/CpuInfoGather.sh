#!/bin/sh
LANG=C;export LANG

model=`model`
command=`which machinfo 2> /dev/null | grep -v "no " | wc -l`
if [ $command -gt 0 ]; then
    machinfo > ./result.txt
    logicalcpucorecnt=`/usr/sbin/ioscan -kf | grep processor | wc -l`
    #These cases are devided by the difference of the form of 'mchinfo' .   
    #Case. there is a statement of Processor model
    IS_PM=`cat ./result.txt | grep "processor model" | wc -l`
    if [ $IS_PM -ge 1 ]; then
        type=`cat ./result.txt | grep "processor model:" | awk -F":" '{print $NF}' | awk -F"   " '{print $NF}'`      
        #Two Types of machinfo showing "Number of enabled sockets" or nothing.      
         cpusocketcntchk=`cat ./result.txt | grep -i "Number of enabled sockets" | wc -l`
         if [ $cpusocketcntchk -eq 0 ]; then
             cpusocketcnt="-"
         else
             cpusocketcnt=`cat ./result.txt | grep -i "Number of enabled sockets" | awk '{print $NF}'`
         fi      
         #Cannot determine 'physicalcpucorecnt' because there is no information about LCPU.
         physicalcpucorecnt="-"
         #Also, followings cannot be determined.
         hyperthreading="-"
         thread="-"
    else    
        #Case. there is a number followed by processor name.
        processornamechk=`cat ./result.txt | grep -i "processor" | head -1 | awk '{print $1}' | wc -c`
        #lt 5 validation is reasonable.
        if [ $processornamechk -lt 5 ]; then
            type=`cat ./result.txt | grep -i "processor" | head -1 | awk '{$1=""; print}'`
        else
            type=`cat ./result.txt | grep -i "processor" | head -1`
        fi        
        physicalcpucorecntchk=`cat ./result.txt | grep core | wc -l`
        if [ $physicalcpucorecntchk -eq 0 ]; then
            cpusocketcntchk1=`cat ./result.txt | grep -i "logical" | head -1 | awk '{print $1}'`
            cpusocketcntchk2=`cat ./result.txt | grep -i "logical" | head -1 | awk -F"(" '{print $2}' | awk '{print $1}'`
            ##Case. there is no information of sockets
            cpusocketcntchk3=`cat ./result.txt | grep -i "logical" | head -1 | grep -i "socket" | wc -l`
            if [ $cpusocketcntchk3 -eq 0 ]; then
                cpusocketcnt="-"
            else
                cpusocketcnt=`expr $cpusocketcntchk1 / $cpusocketcntchk2`
            fi
            physicalcpucorecnt="-"
            thread="-"
            hyperthreading="-"            
        else
            cpusocketcnt=`cat ./result.txt | grep -i socket | head -2 | tail -1 | awk '{print $1}'`
            physicalcpucorecnt=`cat ./result.txt | grep core | tail -1 | awk '{print $1}'` 
            hyperthreadingchk=`expr  $logicalcpucorecnt / $physicalcpucorecnt`
            thread=$hyperthreadingchk            
            if [ $hyperthreadingchk -gt 1 ]; then
               hyperthreading=on
            else
               hyperthreading=off
            fi                                       
        fi
    fi
    #type=Itanium
    speedchk1=`cat ./result.txt | grep Hz | head -1 | awk -F"(" '{print $NF}' | awk -F"," '{print $1}' | awk -F"= " '{print $NF}' | awk '{print $1}'`
    speedchk2=`cat ./result.txt | grep Hz | head -1 | awk -F"(" '{print $NF}' | awk -F"," '{print $1}' | awk -F"= " '{print $NF}' | awk '{print $2}'`   
    if [ $speedchk2 = "MHz" ]; then
        speed=$speedchk1
    else
        speed=`echo "scale=3;$speedchk1 * 1000" | bc`
    fi
    vendor="GenuineIntel"        
else
    class=`echo $model | tr "/" " " | awk '{print $NF}'`
    model=`grep -i $class  /usr/sam/lib/mo/sched.models | awk '{print $NF}'`
    if [ -z "$model" ]; then
        type="-"
        model="-"
    else
        type="-"   
    fi
    #Case. option 'D' is sometimes error. Use option 'd'
    #speed=`echo "itick_per_usec/d" | adb /stand/vmunix /dev/kmem | tail -1 | awk '{print $1}'`
    speedchk=`echo "itick_per_usec/d" | adb /stand/vmunix /dev/kmem | grep -i "itick_per_usec:" | tail -1 | awk -F: '{print $NF}'`
    if [ $speedchk -eq 0 ]; then
        speed=`echo "itick_per_usec/D" | adb /stand/vmunix /dev/kmem | grep -i "itick_per_usec:" | tail -1 | awk -F: '{print $NF}'`
    else
        speed=$speedchk
    fi
    cpusocketcnt="-"
    physicalcpucorecnt=`/usr/sbin/ioscan -kf | grep processor | wc -l`
    logicalcpucorecnt=$physicalcpucorecnt
    hyperthreading=off
    thread="-"
    vendor="HP"
fi
fpu="-"
echo $vendor"|"$model"|"$type"|"$speed"|"$cpusocketcnt"|"$physicalcpucorecnt"|"$logicalcpucorecnt"|"$hyperthreading"|"$fpu
\rm ./result.txt 2> /dev/null
