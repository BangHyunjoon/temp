#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/CpuClkInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    procstr=`lsdev -Sa -Cc processor`

    procspeed=`lsattr -El ${procstr%% *} -a frequency -F value`

    if [[ ! -z $procspeed ]]
    then
        # Convert procspeed to MHz, and round up or down
        if (( ($procspeed%1000000) >= 500000 ))
        then
        (( procspeedMHz=($procspeed/1000000) + 1 ))
        else
        (( procspeedMHz=($procspeed/1000000) ))
        fi
    fi

echo $procspeedMHz > ../aproc/shell/CpuClkInfo.dat
fi

#cat ../aproc/shell/CpuClkInfo.dat
