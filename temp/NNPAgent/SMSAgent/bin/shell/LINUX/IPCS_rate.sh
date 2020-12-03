#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

CMD_REAULT_FILE=../aproc/shell/ipcs_l_max.dat

l_nFileCheck=`ls -al $CMD_REAULT_FILE 2> /dev/null | wc -l`
if [ $l_nFileCheck -eq 0 ] ; then
    ipcs -l | egrep "max number of segments|max number of arrays|max queues system wide" >  $CMD_REAULT_FILE
fi

l_nMessQueMax=`grep "max queues system wide"  $CMD_REAULT_FILE | awk -F'=' '{print $2}'`
l_nSemaphoreMax=`grep "max number of arrays" $CMD_REAULT_FILE | awk -F'=' '{print $2}'`
l_nSharedMemMax=`grep "max number of segments" $CMD_REAULT_FILE | awk -F'=' '{print $2}'`

#l_nCurrentMessQueCnt=`ipcs -q | egrep -iv "IPC status|OWNER|Message Queues" | wc -l`
#l_nCurrentSemaphoreCnt=`ipcs -s | egrep -iv "IPC status|OWNER|Semaphores" | wc -l`
#l_nCurrentSharedMemCnt=`ipcs -m | egrep -iv "IPC status|OWNER|Shared Memory" | wc -l`
l_nCurrentMessQueCnt=`ipcs -q | wc -l`
l_nCurrentSemaphoreCnt=`ipcs -s | wc -l`
l_nCurrentSharedMemCnt=`ipcs -m | wc -l`

l_nCurrentMessQueCnt=`expr $l_nCurrentMessQueCnt - 4`
l_nCurrentSemaphoreCnt=`expr $l_nCurrentSemaphoreCnt - 4`
l_nCurrentSharedMemCnt=`expr $l_nCurrentSharedMemCnt - 4`

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

shem_used=`ipcs -m | grep [0-9] | awk '{ sum+=$5} END {print int(sum/1024)}'`

echo $l_nMessQueRate"|"$l_nSharedMemRate"|"$l_nSemaphoreRate"|"$l_nCurrentMessQueCnt"|"$l_nCurrentSharedMemCnt"|"$l_nCurrentSemaphoreCnt"|"$l_nMessQueMax"|"$l_nSharedMemMax"|"$l_nSemaphoreMax"|"$shem_used

