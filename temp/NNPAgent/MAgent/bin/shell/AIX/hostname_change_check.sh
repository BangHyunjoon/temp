#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname_change_check.dat
CHK_RESULT_DAT=../aproc/shell/hostname_change_check.result.false
EXEC_DATE=`date +%Y%m%d%H%M%S`
RECVRY_HOSTNAME_NFILE1=./shell/AIX/recovery/hostname_new.dat
RECVRY_HOSTNAME_OFILE1=./shell/AIX/recovery/hostname_old.dat

RECVRY_HOSTNAME_DFILE1=./shell/AIX/recovery/hostname_new.dat.$EXEC_DATE

COMMAND=`echo "" > $FILE_DAT`
COMMAND=`mkdir ./shell/AIX/recovery >> $FILE_DAT 2>&1 `

COMMAND=`\rm -f $CHK_RESULT_DAT >> $FILE_DAT 2>&1`

COMMAND=`echo "hostname change checking..." >> $FILE_DAT` 

COMMAND=`hostname > $RECVRY_HOSTNAME_NFILE1`

CHANGE_CHK=0
CHANGE_CHK=`diff $RECVRY_HOSTNAME_NFILE1 $RECVRY_HOSTNAME_OFILE1 | wc -l 2>> $FILE_DAT`
COMMAND=`echo "diff [$RECVRY_HOSTNAME_NFILE1] [$RECVRY_HOSTNAME_OFILE1] result : $CHANGE_CHK" >> $FILE_DAT` 
if [ $CHANGE_CHK = 0 ] ; then
    COMMAND=`echo "hostname change checked-1...[true:0]" >> $FILE_DAT` 
    echo "true"
    exit 0
else
    COMMAND=`echo "hostname change checked-1...[false:255]" >> $FILE_DAT` 
    COMMAND=`echo "false" > $CHK_RESULT_DAT`
    echo "false"
    COMMAND=`\cp -f $RECVRY_HOSTNAME_NFILE1 $RECVRY_HOSTNAME_DFILE1`
    exit 255
fi
