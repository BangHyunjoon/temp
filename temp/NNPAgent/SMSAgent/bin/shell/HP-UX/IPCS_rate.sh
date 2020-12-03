#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

CMD_REAULT_FILE=../aproc/shell/kctune_ipcs_max.dat

l_nFileCheck=`ls -al $CMD_REAULT_FILE | wc -l`
if [ $l_nFileCheck -eq 0 ] ; then
    kctune | egrep "semmni|msgmni|shmmni" >  $CMD_REAULT_FILE
fi

l_nMessQueMax=`grep msgmni $CMD_REAULT_FILE | awk '{print $2}'`
l_nSemaphoreMax=`grep semmni $CMD_REAULT_FILE | awk '{print $2}'`
l_nSharedMemMax=`grep shmmni $CMD_REAULT_FILE | awk '{print $2}'`

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

shem_used=`ipcs -ma | grep [0-9] | grep ^m | awk '{ sum+=$9} END {print int(sum/1024)}'`
echo $l_nMessQueRate"|"$l_nSharedMemRate"|"$l_nSemaphoreRate"|"$l_nCurrentMessQueCnt"|"$l_nCurrentSharedMemCnt"|"$l_nCurrentSemaphoreCnt"|"$l_nMessQueMax"|"$l_nSharedMemMax"|"$l_nSemaphoreMax"|"$shem_used 

