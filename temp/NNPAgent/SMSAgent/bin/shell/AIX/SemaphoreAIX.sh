#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/SemaphoreAIX.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ipcs -sa > ../aproc/shell/SemaphoreAIX.dat
fi

