#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

day=0
hour=0
minute=0
boot_time=`uptime`
daychk=`echo $boot_time | grep -i day | wc -l`
if [ $daychk -eq 0 ]; then
    chk=`echo $boot_time | awk '{print $3}' | grep : | wc -l`
    if [ $chk -eq 0 ]; then
        hour=`echo $boot_time | awk '{print $3}'`
    else
        hour=`echo $boot_time | awk '{print $3}' | cut -d "," -f1 |  awk -F: '{print $1}'`
        minute=`echo $boot_time | awk '{print $3}' | cut -d "," -f1 |  awk -F: '{print $2}'`
    fi
else
    day=`echo $boot_time | awk '{print $3}'`
    chk=`echo $boot_time | awk '{print $5}' | grep : | wc -l`
    if [ $chk -eq 0 ]; then
        hour=`echo $boot_time | awk '{print $5}'`
    else
        hour=`echo $boot_time | awk '{print $5}' | cut -d "," -f1 |  awk -F: '{print $1}'`
        minute=`echo $boot_time | awk '{print $5}' | cut -d "," -f1 |  awk -F: '{print $2}'`
    fi
fi
echo $day"|"$hour"|"$minute

#2014-12-09 edit
#uptime | awk '{print $3":"$5}' | cut -d "," -f1
#DAY=days,
#DAY_FLAG=`uptime | awk '{print $4}'`

#if [ "$DAY" = "$DAY_FLAG" ];then
#    uptime | awk '{print $3":"$5}' | cut -d "," -f1
#else
#    uptime | awk '{print "0:"$3}' | cut -d "," -f1
#fi
