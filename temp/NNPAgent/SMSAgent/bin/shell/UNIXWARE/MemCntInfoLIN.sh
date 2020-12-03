#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/MemCntInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ./shell/LINUX/mem_info > ../aproc/shell/MemCntInfo.dat
fi

