#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

IP=$1 
TIMEOUT=$2

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    l_RespTime=`ping -c 2 -w $TIMEOUT $IP | grep avg | tail -1 | awk -F'=' '{print $2}' | awk -F'/' '{print $2}'| awk -F'.' '{print $1}'`
fi

if [ $OS_TYPE = "HP-UX" ] ; then
    l_RespTime=`ping $IP -n 2 -m $TIMEOUT | grep avg | tail -1 | awk -F'=' '{print $2}' | awk -F'/' '{print $2}'| awk -F'.' '{print $1}'`
fi

if [ $OS_TYPE = "Linux" ] ; then
    l_RespTime=`ping -c 2 $IP -W $TIMEOUT | grep avg | tail -1 | awk -F'=' '{print $2}' | awk -F'/' '{print $2}'`
fi

if [ $OS_TYPE = "SunOS" ] ; then
    l_RespTime=`ping -s $IP 56 $TIMEOUT | grep avg | tail -1 | awk -F'=' '{print $2}' | awk -F'/' '{print $2}'| awk -F'.' '{print $1}'`
fi


l_check=`echo $l_RespTime | wc -w`

#if [ $l_check -eq 1 ] ; then
#    l_status=1
#else
#    l_status=-1
#    l_RespTime=-99999
#fi

if [ $l_check -ne 1 ] ; then
    l_RespTime=-1
fi

echo "NKIA|"$l_RespTime
exit 0



