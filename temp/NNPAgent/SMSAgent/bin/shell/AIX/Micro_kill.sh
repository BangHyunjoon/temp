#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ] ; then
    for i in `ps -ef | grep Micro_nk_lpar | grep -v grep | awk '{print $2}'`
    do
	pid=`echo $i | cut -d' ' -f1`
	#echo "kill -9 $pid"
	kill -9 $pid
    done

    for i in `ps -ef | grep nk_Perfstat | grep -v grep | awk '{print $2}'`
    do
	pid=`echo $i | cut -d' ' -f1`
	#echo "kill -9 $pid"
	kill -9 $pid
    done
    exit 0
fi

for i in `ps -ef | grep Micro_nk_lpar | grep -v grep | awk '{print $2}'`
do
	pid=`echo $i | cut -d' ' -f1`
	#echo "kill -9 $pid"
	kill -9 $pid
done

for i in `ps -ef | grep nk_Perfstat | grep -v grep | awk '{print $2}'`
do
	pid=`echo $i | cut -d' ' -f1`
	#echo "kill -9 $pid"
	kill -9 $pid
done

exit 0

