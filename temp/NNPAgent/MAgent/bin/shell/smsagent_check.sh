#!/bin/sh

exit 0
PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

DATE=`date +%y%m%d%H%S`
PID=`ls -al ../../SMSAgent/bin/smsagent_status_* | awk '{print $NF}' | awk -F'_' '{print $3}'`

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    ../../utils/ETC/ShCmd 10 "truss -p $PID" > ./truss.out 2>&1
fi

if [ $OS_TYPE = "HP-UX" ] ; then
    ../../utils/ETC/ShCmd 10 "truss -p $PID" > ./truss.out 2>&1
fi

if [ $OS_TYPE = "Linux" ] ; then
    ../../utils/ETC/ShCmd 10 "strace -p $PID" > ./truss.out 2>&1
fi

if [ $OS_TYPE = "SunOS" ] ; then
    ../../utils/ETC/ShCmd 10 "truss -p $PID" > ./truss.out 2>&1
fi


