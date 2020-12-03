#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

PRSTAT_RESULT_FILE=../aproc/shell/prstat_z.dat
PRSTAT_USEMEM_SIZE_FIEL=../aproc/shell/prstat_usemem_size.dat

PS_RESULT=`ps -e -o rss | grep -iv rss | awk '{total += $1} END {print total}'`
echo "NKIA|"$PS_RESULT

exit

prstat -Z 1 2 

l_nCnt=0
l_nFoundFlag=0
while read l_strBuf
do
    l_strSizeStr=`echo $l_strBuf | awk '{print $4}'`
    if [ "$l_strSizeStr" = "RSS" ] ; then
        l_nCnt=`expr $l_nCnt + 1`
        if [ $l_nCnt -eq 2 ] ; then
            l_nFoundFlag=1
            continue
        fi
    fi

    if [ $l_nFoundFlag -eq 1 ] ; then
        l_strFirstSize=`echo $l_strBuf | awk '{print $4}'`
        l_nCheck=`echo $l_strFirstSize | grep G | wc -l`
        if [ $l_nCheck -eq 1 ] ; then
            l_strSize=`echo $l_strFirstSize | awk -F'G' '{print $1}'`
            l_strSize=`expr $l_strSize \* 1024 \* 1024`
        else
            l_strSize=`echo $l_strFirstSize | awk -F'M' '{print $1}'`
            l_strSize=`expr $l_strSize \* 1024`
        fi
        echo "NKIA|"$l_strSize 
        #echo $l_strSize
        break
    fi
  
done <$PRSTAT_RESULT_FILE

