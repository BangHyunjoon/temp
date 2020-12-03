#!/bin/sh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG

command=`which glance 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    filelock_rate=-1
else
    filelock_rate=`glance -adviser_only -syntax ./shell/HP-UX/filelock.adviser -j 1 -iterations 1 | tail -1 | grep TBL_FILE_LOCK_UTIL | awk '{print $NF}'`
fi

SAR_V_RESULT_FILE=../aproc/shell/sar_v_result.dat

sar -v 1 2 > $SAR_V_RESULT_FILE

l_nGatherType=0
l_nGatherStatus=0
l_nReadCnt=0

while read l_strBuf
do
    l_nCheck=`echo $l_strBuf | grep proc-sz | wc -l`
    if [ $l_nCheck -eq 1 ] ; then
        l_nGatherStatus=1
        l_nCheck2=`echo $l_strBuf | grep ov | wc -l`
        if [ $l_nCheck2 -eq 1 ] ; then
            l_nGatherType=1
        fi
    fi

    if [ $l_nGatherStatus -eq 1 ] ; then
        l_nReadCnt=`expr $l_nReadCnt + 1`
    fi

    if [ $l_nReadCnt -eq 3 ] ; then
        if [ $l_nGatherType -eq 1 ] ; then
            l_strProc_sz=`echo $l_strBuf | awk '{print $4}'`
            l_strProc_ov=`echo $l_strBuf | awk '{print $5}'`
            l_strInod_sz=`echo $l_strBuf | awk '{print $6}'`
            l_strInod_ov=`echo $l_strBuf | awk '{print $7}'`
            l_strFile_sz=`echo $l_strBuf | awk '{print $8}'`
            l_strFile_ov=`echo $l_strBuf | awk '{print $9}'`

        else
            l_strProc_sz=`echo $l_strBuf | awk '{print $2}'`
            l_strProc_ov=-1
            l_strInod_sz=`echo $l_strBuf | awk '{print $3}'`
            l_strInod_ov=1
            l_strFile_sz=`echo $l_strBuf | awk '{print $4}'`
            l_strFile_ov=-1
        fi

        l_nProcUsed=`echo $l_strProc_sz | awk -F'/' '{print $1}'`
        l_nProcTotal=`echo $l_strProc_sz | awk -F'/' '{print $2}'`
        l_nProcRate=`expr $l_nProcUsed \* 100 / $l_nProcTotal `

        l_nInodUsed=`echo $l_strInod_sz | awk -F'/' '{print $1}'`
        l_nInodTotal=`echo $l_strInod_sz | awk -F'/' '{print $2}'`
        l_nInodRate=`expr $l_nInodUsed \* 100 / $l_nInodTotal`

        l_nFileUsed=`echo $l_strFile_sz | awk -F'/' '{print $1}'`
        l_nFileTotal=`echo $l_strFile_sz | awk -F'/' '{print $2}'`
        l_nFileRate=`expr $l_nFileUsed \* 100 / $l_nFileTotal`

        filelock_rate=`echo $filelock_rate | awk -F'.' '{print $1}'`

        echo "NKIANKIA|"$l_nProcRate "|" $l_strProc_ov "|" $l_nInodRate "|" $l_strInod_ov "|" $l_nFileRate "|" $l_strFile_ov "|" $filelock_rate "|" $l_nProcUsed "|" $l_nProcTotal "|" $l_nInodUsed "|" $l_nInodTotal "|" $l_nFileUsed "|" $l_nFileTotal
    fi
done <$SAR_V_RESULT_FILE

\rm -f $SAR_V_RESULT_FILE
