#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

if [ -f /proc/slabinfo ]; then
    current_lock_num=`grep file_lock_cache /proc/slabinfo | awk '{print $2}'`
    max_lock_num=`grep file_lock_cache /proc/slabinfo | awk '{print $4}'`
else
    echo "0"
    exit 0
fi

filelock_rate=`expr $current_lock_num \* 100 / $max_lock_num`
echo $filelock_rate

exit 0

if [ -f /proc/locks ]; then
    current_lock_num=`cat /proc/locks | wc -l`
else
    current_lock_num=0
    echo "0"
    exit 0
fi

if [ -f /proc/sys/kernel/max_lock_depth ]; then
    max_lock_num=`cat /proc/sys/kernel/max_lock_depth`
else
    max_lock_num=0
    echo "0"
    exit 0
fi

filelock_rate=`expr $current_lock_num \* 100 / $max_lock_num`
echo $filelock_rate
