#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/SysidInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    lsattr -El sys0 |grep systemid |awk '{print substr($2,7,14)}' > ../aproc/shell/SysidInfo.dat
fi


