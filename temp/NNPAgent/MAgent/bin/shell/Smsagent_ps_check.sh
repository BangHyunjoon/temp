#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin
export PATH
LANG=C
export LANG

smspath="../../SMSAgent/bin/smsagent_status_*"
pid=`ls -al $smspath 2> /dev/null | awk '{print $NF}' | awk -F'_' '{print $NF}'`

if [ -z $pid ]; then
    echo 1
fi

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    ps -e -o pid -o args | grep "$1" | grep $pid | grep -v grep | grep -v "Smsagent_ps_check.sh" | wc -l
fi

if [ $OS_TYPE = "HP-UX" ] ; then
    export UNIX95=ps;ps -e -o pid -o args | grep "$1" | grep $pid | grep -v grep | grep -v "Smsagent_ps_check.sh" | wc -l
fi

if [ $OS_TYPE = "Linux" ] ; then
    ps -e -o pid -o args | grep "$1" | grep $pid | grep -v grep | grep -v "Smsagent_ps_check.sh" | wc -l
fi

if [ $OS_TYPE = "SunOS" ] ; then
    ps -e -o pid -o args | grep "$1" | grep $pid | grep -v grep | grep -v "Smsagent_ps_check.sh" | wc -l
fi