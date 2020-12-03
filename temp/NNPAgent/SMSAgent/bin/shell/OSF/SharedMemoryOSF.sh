#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

FILE_CNT=`ls -al ../aproc/shell/SharedMemoryOSF.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ipcs -ma > ../aproc/shell/SharedMemoryOSF.dat
fi
