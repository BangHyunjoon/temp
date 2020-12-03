#!/bin/sh
PATH=$PATH:/usr/sbin:/sbin:/usr/bin:/bin
export PATH
LANG=C
export LANG=C

if [ -f ../aproc/shell/CpuInfoIrix.dat ]; then
    `/sbin/rm ../aproc/shell/CpuInfoIrix.dat`
fi

COUNT=`hinv -c processor | grep Processors | awk '{print $1}'`
SPEED=`hinv -c processor | grep Processors | awk '{print $2" "$3}'`
MODEL=`hinv -c processor | grep CPU | awk '{print $2" "$3}'`
FPU=`hinv -c processor | grep FPU | awk '{print $2" "$3" "$4" "$5" "$6}'`

if [ "$COUNT" = "" ]; then
    echo "UNKNOWN" >> ../aproc/shell/CpuInfoIrix.dat
    #echo "COUNT=COUNT"
else
    echo "COUNT="$COUNT >> ../aproc/shell/CpuInfoIrix.dat
    #echo "COUNT="$COUNT
fi

if [ "$SPEED" = "" ]; then
    echo "UNKNOWN" >> ../aproc/shell/CpuInfoIrix.dat
    #echo "SPEED=UNKNOWN"
else
    echo "SPEED="$SPEED >> ../aproc/shell/CpuInfoIrix.dat
    #echo "SPEED="$SPEED
fi

if [ "$MODEL" = "" ]; then
    echo "UNKNOWN" >> ../aproc/shell/CpuInfoIrix.dat
    #echo "MODEL=UNKNOWN" 
else
    echo "MODEL="$MODEL >> ../aproc/shell/CpuInfoIrix.dat
    #echo "MODEL="$MODEL
fi
if [ "$FPU" = "" ]; then
    echo "UNKNOWN" >> ../aproc/shell/CpuInfoIrix.dat
    #echo "FPU=UNKNOWN" 
else
    echo "FPU="$FPU >> ../aproc/shell/CpuInfoIrix.dat
    #echo "FPU="$FPU
fi
