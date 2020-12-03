#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/MsgQIrix.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ipcs -q | grep Message > ../aproc/shell/MsgQIrix.dat
fi

