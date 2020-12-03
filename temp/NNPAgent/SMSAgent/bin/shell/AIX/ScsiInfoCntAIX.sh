#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/ScsiInfoCnt.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    lsdev -C -c adapter | grep SCSI | wc -l > ../aproc/shell/ScsiInfoCnt.dat
fi

#cat ../aproc/shell/ScsiInfoCnt.dat

