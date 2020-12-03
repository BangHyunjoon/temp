#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

DAY_STR="days"

UPTIME_STR=`uptime`
#UPTIME_STR=" 16:30:50  up 36 min,  1 user,  load average: 0.00, 0.02, 0.00"
l_day=`echo $UPTIME_STR | awk '{print $4}' | sed -e 's/,//g'`

l_check=`echo $l_day | grep day | wc -l`
#if [ "$l_day" = "$DAY_STR" ] ; then
if [ $l_check -eq 1 ] ; then
    DAYS=`uptime | awk -F'day' '{print $1}' | awk '{print $NF}'`
    echo "NKIA|"$DAYS 
fi

exit 0




