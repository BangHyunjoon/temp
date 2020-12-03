#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/top_info.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 1 ] ; then
    cat ../aproc/shell/top_info.dat | grep java | grep $1 | awk '{print $2}'
else
    echo "0.0" 
fi


