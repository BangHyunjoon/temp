#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

#http://www-01.ibm.com/support/knowledgecenter/ssw_aix_71/com.ibm.aix.genprogc/ipc_limits.htm?lang=en

bit=`bootinfo -K`
ver=`oslevel | awk -F. '{print $1$2}'`
if [ $ver -ge 53 ]; then
    if [ $bit -eq 64 ]; then
	    l_nMessQueMax=1048576
		l_nSemaphoreMax=1048576
		l_nSharedMemMax=1048576
    else
        l_nMessQueMax=131072
		l_nSemaphoreMax=131072
		l_nSharedMemMax=131072
    fi
else
    l_nMessQueMax=131072
    l_nSemaphoreMax=131072
    l_nSharedMemMax=131072
fi

l_nCurrentMessQueCnt=`ipcs -q | wc -l`
l_nCurrentSemaphoreCnt=`ipcs -s | wc -l`
l_nCurrentSharedMemCnt=`ipcs -m | wc -l`

l_nCurrentMessQueCnt=`expr $l_nCurrentMessQueCnt - 3`
l_nCurrentSemaphoreCnt=`expr $l_nCurrentSemaphoreCnt - 3`
l_nCurrentSharedMemCnt=`expr $l_nCurrentSharedMemCnt - 3`

if [ $l_nCurrentMessQueCnt -le 0 ] ; then
    l_nCurrentMessQueCnt=0
    l_nMessQueRate=0.0
else
	l_nMessQueRate=`expr $l_nCurrentMessQueCnt \* 100 / $l_nMessQueMax`
fi

if [ $l_nCurrentSemaphoreCnt -le 0 ] ; then
    l_nCurrentSemaphoreCnt=0
    l_nSemaphoreRate=0.0
else
	l_nSemaphoreRate=`expr $l_nCurrentSemaphoreCnt \* 100 / $l_nSemaphoreMax`
fi
if [ $l_nCurrentSharedMemCnt -le 0 ] ; then
    l_nCurrentSharedMemCnt=0
    l_nSharedMemRate=0.0
else
    l_nSharedMemRate=`expr $l_nCurrentSharedMemCnt \* 100 / $l_nSharedMemMax`
fi

shem_used=`ipcs -ma | grep [0-9] | grep ^m | awk '{ sum+=$10} END {print int(sum/1024)}'`
echo $l_nMessQueRate"|"$l_nSharedMemRate"|"$l_nSemaphoreRate"|"$l_nCurrentMessQueCnt"|"$l_nCurrentSharedMemCnt"|"$l_nCurrentSemaphoreCnt"|"$l_nMessQueMax"|"$l_nSharedMemMax"|"$l_nSemaphoreMax"|"$shem_used 
