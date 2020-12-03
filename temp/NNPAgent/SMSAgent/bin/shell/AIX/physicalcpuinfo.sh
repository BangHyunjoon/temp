#!/bin/sh

LANG=C;export LANG
if [ -f ./result.txt ] ; then
    unlink ./result.txt 2> /dev/null
fi

model=`uname -p`
../../utils/ETC/ShCmd 5 prtconf > ./result.txt
type=`cat ./result.txt | grep -i "Processor Type" | awk '{print $NF}'`
speed=`cat ./result.txt | grep -i "Processor Clock Speed" | awk '{print $(NF-1)}'`
cpusocketcnt=`cat ./result.txt | grep -i "Number Of Processors" | awk '{print $NF}'`

aix53=`oslevel | awk -F. '{print $1$2}'`

if [ $aix53 -ge 53 ]; then
    smtchk=`smtctl | grep -i "SMT is currently enabled." | wc -l`
    if [ $smtchk -eq 1 ]; then
        smt=ON
    else
        smt=OFF
    fi
    logicalcpucorecnt=`lparstat | grep -i "System configuration" | awk -F'lcpu' '{print $2}' | awk -F' ' '{print $1}' | awk -F'=' '{print $2}'`
    lsattr -El proc0 > ./result.txt
    val=`cat ./result.txt | grep -i ^smt_threads | awk '{print $2}'`
    physicalcpucorecnt=`expr $val \* $cpusocketcnt`
elif [ $aix53 -lt 53 ]; then
    lscfg -vp > ./result.txt
    physicalcpucorecnt=`cat ./result.txt | grep proc | wc -l | awk '{print $1}'`
    logicalcpucorecnt=`cat ./result.txt | grep proc | wc -l | awk '{print $1}'`
    smt=OFF
fi

echo "MODEL="$model
echo "TYPE="$type
echo "SPEED="$speed
echo "CPUSOCKETCOUNT="$cpusocketcnt
echo "PHYSICALCPUCORECOUNT="$physicalcpucorecnt
echo "LOGICALCPUCORECOUNT="$logicalcpucorecnt
echo "SMTCHECK="$smt
unlink ./result.txt 2> /dev/null
