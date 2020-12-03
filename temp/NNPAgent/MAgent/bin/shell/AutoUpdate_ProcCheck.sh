#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    result=`ps -Nef | grep "utils/AUTOUPDATE/AutoUpdate" | grep -v grep | wc -l`
    if [ $result = 0 ] ; then
        exit 0
    fi

    for i in `ps -Nef | grep "utils/AUTOUPDATE/AutoUpdate" | grep -v grep | awk '{print $2}'`
    do
        pid=`echo $i | cut -d' ' -f1`
        kill -9 $pid
    done
    exit 0
fi



result=`ps -ef | grep "utils/AUTOUPDATE/AutoUpdate" | grep -v grep | wc -l`
if [ $result = 0 ] ; then
    exit 0
fi

for i in `ps -ef | grep "utils/AUTOUPDATE/AutoUpdate" | grep -v grep | awk '{print $2}'`
do

    pid=`echo $i | cut -d' ' -f1`
    kill -9 $pid
done
