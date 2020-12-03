#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

command=`which glance 2> /dev/null | grep -v "no " | wc -l`
netoutqueue=0
if [ $command -eq 0 ]; then
    echo $netoutqueue
    exit 0
fi

adviser_name=$1
if [ "$adviser_name" = "CPU" ] ; then
    glance -adviser_only -syntax ./shell/HP-UX/GlanceCpuLoop -j 10 -iterations 1 2> /dev/null | sed -e 's/ //g'
elif [ "$adviser_name" = "MEM" ] ; then
    glance -adviser_only -syntax ./shell/HP-UX/GlanceMemLoop -j 10 -iterations 1 2> /dev/null | sed -e 's/ //g'
elif [ "$adviser_name" = "MEMCACHE" ] ; then
    glance -adviser_only -syntax ./shell/HP-UX/GlanceMemCacheLoop -j 10 -iterations 1 2> /dev/null | sed -e 's/ //g'
elif [ "$adviser_name" = "DISK" ] ; then
    if [ $2 -eq 1 ] ; then
        glance -adviser_only -syntax ./shell/HP-UX/GlanceDiskLoop -j 10 -iterations 1 2> /dev/null | sed -e 's/ //g'
    else
        glance -adviser_only -syntax ./shell/HP-UX/GlanceDiskLoop2 -j 10 -iterations 1 2> /dev/null | sed -e 's/ //g'
    fi

else
    glance -adviser_only -syntax $adviser_name -j 2 -iterations 1 2> /dev/null
fi

#glance_perform.sh CPU
#glance_perform.sh DISK 1

