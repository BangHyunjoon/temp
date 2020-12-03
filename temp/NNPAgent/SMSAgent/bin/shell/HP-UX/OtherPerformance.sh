#!/bin/sh

PATH=/opt/perf/bin/:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

DATE=`date`
echo "[$DATE] ps checking start" > ../aproc/shell/midaemon_kill.log
ps -ef | grep bin/midaemon | grep -v grep | awk '{print $2}' > ../aproc/shell/midaemon_old.dat

../../utils/ETC/ShCmd 7 "glance -adviser_only -syntax ./shell/HP-UX/Matrix_Syntax.txt -j 2 -iterations
 1" > ../aproc/shell/OtherPerformance.dat 2> /dev/null

ps -ef | grep bin/midaemon | grep -v grep | awk '{print $2}' > ../aproc/shell/midaemon_new.dat

for i in `cat ../aproc/shell/midaemon_new.dat`
do
    ps_cnt=0
    for j in `cat ../aproc/shell/midaemon_old.dat`
    do
        if [ "$i" = "$j" ]
        then
            ps_cnt=1
        fi
    done

    if [ $ps_cnt = 0 ] ;
    then
       DATE=`date`
       echo "[$DATE] kill ps id=$i" >> ../aproc/shell/midaemon_kill.log
       kill -9 $i
    fi
done

buffer_cache_used=`sysdef | grep bufpages | awk '{print $2}'`
echo "buffer_cache_used="$buffer_cache_used >> ../aproc/shell/OtherPerformance.dat
