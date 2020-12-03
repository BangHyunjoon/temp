#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/CpuCntInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    numproc=`lsdev -Cc processor | grep Available | wc -l`
    numproc=${numproc##* }

    echo $numproc > ../aproc/shell/CpuCntInfoPhy.dat
fi

#cat ../aproc/shell/CpuCntInfoPhy.dat
