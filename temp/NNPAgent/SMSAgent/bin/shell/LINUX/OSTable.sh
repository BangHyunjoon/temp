#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

#if [ -f /proc/sys/fs/file-nr ]; then
#    l_nFileUsed=`cat /proc/sys/fs/file-nr | awk '{print $1}'`
#    l_nFileTotal=`cat /proc/sys/fs/file-nr | awk '{print $3}'`
#    if [ $l_nFileUsed -eq 0 ]; then
#        l_nFileRate=0
#    else
#        l_nFileRate=`expr $l_nFileUsed \* 100 / $l_nFileTotal`
#    fi
#else
#    l_nFileRate=-1
#    l_nFileUsed=-1
#    l_nFileTotal=-1
#fi

l_nFileRate=-1
l_nFileUsed=-1
l_nFileTotal=-1

if [ -f /proc/sys/kernel/pid_max ]; then
    l_nProcUsed=`ps -ef | grep [0-9] | wc -l`
    l_nProcTotal=`cat /proc/sys/kernel/pid_max`
    if [ $l_nProcUsed -eq 0 ]; then
        l_nProcRate=0
    else
        l_nProcRate=`expr $l_nProcUsed \* 100 / $l_nProcTotal`
    fi
else
    l_nProcRate=-1
    l_nProcUsed=-1
    l_nProcTotal=-1
fi

if [ -f /proc/locks ]; then
    current_lock_num=`cat /proc/locks | wc -l`
	if [ -f /proc/sys/kernel/max_lock_depth ]; then
	    max_lock_num=`cat /proc/sys/kernel/max_lock_depth`
	    filelock_rate=`expr $current_lock_num \* 100 / $max_lock_num`
	else
	    filelock_rate=0
	fi
else
    filelock_rate=0
fi

l_strProc_ov=-1
l_nInodRate=-1
l_strInod_ov=-1
l_strFile_ov=-1
l_nInodUsed=-1
l_nInodTotal=-1

echo "NKIANKIA|"$l_nProcRate "|" $l_strProc_ov "|" $l_nInodRate "|" $l_strInod_ov "|" $l_nFileRate "|" $l_strFile_ov "|" $filelock_rate "|" $l_nProcUsed "|" $l_nProcTotal "|" $l_nInodUsed "|" $l_nInodTotal "|" $l_nFileUsed "|" $l_nFileTotal
