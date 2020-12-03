#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#uptime | awk '{print $3":"$5}' | cut -d "," -f1
DAY=days,
DAY_FLAG=`uptime | awk '{print $4}'`

if [ "$DAY" = "$DAY_FLAG" ];then
    uptime | awk '{print $3":"$5}' | cut -d "," -f1
else
    uptime | awk '{print "0:"$3}' | cut -d "," -f1
fi
