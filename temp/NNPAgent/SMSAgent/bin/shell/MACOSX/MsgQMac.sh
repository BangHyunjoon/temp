#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/MsgQMac.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ipcs -q > ../aproc/shell/MsgQMac.dat
fi

