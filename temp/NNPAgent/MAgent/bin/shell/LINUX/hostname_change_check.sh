#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname_change_check.dat
CHK_RESULT_DAT=../aproc/shell/hostname_change_check.result.false
EXEC_DATE=`date +%Y%m%d%H%M%S`
RECVRY_HOSTNAME_NFILE1=./shell/LINUX/recovery/hostname_new.dat
RECVRY_HOSTNAME_NFILE2=./shell/LINUX/recovery/hostname_set_file_new.dat
RECVRY_HOSTNAME_OFILE1=./shell/LINUX/recovery/hostname_old.dat
RECVRY_HOSTNAME_OFILE2=./shell/LINUX/recovery/hostname_set_file_old.dat

RECVRY_HOSTNAME_DFILE1=./shell/LINUX/recovery/hostname_new.dat.$EXEC_DATE
RECVRY_HOSTNAME_DFILE2=./shell/LINUX/recovery/hostname_set_file_new.dat.$EXEC_DATE

COMMAND=`echo "" > $FILE_DAT`
COMMAND=`mkdir ./shell/LINUX/recovery >> $FILE_DAT 2>&1 `

COMMAND=`\rm -f $CHK_RESULT_DAT >> $FILE_DAT 2>&1`

COMMAND=`echo "hostname change checking..." >> $FILE_DAT` 

COMMAND=`hostname > $RECVRY_HOSTNAME_NFILE1`
COMMAND=`grep HOSTNAME= /etc/sysconfig/network > $RECVRY_HOSTNAME_NFILE2`

CHANGE_CHK=0
CHANGE_CHK=`diff $RECVRY_HOSTNAME_NFILE1 $RECVRY_HOSTNAME_OFILE1 | wc -l 2>> $FILE_DAT`
COMMAND=`echo "diff [$RECVRY_HOSTNAME_NFILE1] [$RECVRY_HOSTNAME_OFILE1] result : $CHANGE_CHK" >> $FILE_DAT` 
if [ $CHANGE_CHK = 0 ] ; then
    CHANGE_CHK=`diff $RECVRY_HOSTNAME_NFILE2 $RECVRY_HOSTNAME_OFILE2 | wc -l 2>> $FILE_DAT`
    COMMAND=`echo "diff [$RECVRY_HOSTNAME_NFILE2] [$RECVRY_HOSTNAME_OFILE2] result : $CHANGE_CHK" >> $FILE_DAT` 

    if [ $CHANGE_CHK = 0 ] ; then
        COMMAND=`echo "hostname change checked-2...[true:0]" >> $FILE_DAT` 
        echo "true"
        exit 0
    else
        COMMAND=`echo "hostname change checked-2...[false:255]" >> $FILE_DAT` 
        COMMAND=`echo "false" > $CHK_RESULT_DAT`
        echo "false"
        COMMAND=`\cp -f $RECVRY_HOSTNAME_NFILE1 $RECVRY_HOSTNAME_DFILE1`
        COMMAND=`\cp -f $RECVRY_HOSTNAME_NFILE2 $RECVRY_HOSTNAME_DFILE2`
        exit 255
    fi
else
    COMMAND=`echo "hostname change checked-1...[false:255]" >> $FILE_DAT` 
    COMMAND=`echo "false" > $CHK_RESULT_DAT`
    echo "false"
    COMMAND=`\cp -f $RECVRY_HOSTNAME_NFILE1 $RECVRY_HOSTNAME_DFILE1`
    COMMAND=`\cp -f $RECVRY_HOSTNAME_NFILE2 $RECVRY_HOSTNAME_DFILE2`
    exit 255
fi
