#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/NodeInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    uname -M > ../aproc/shell/NodeInfo.dat
fi

#cat ../aproc/shell/NodeInfo.dat

