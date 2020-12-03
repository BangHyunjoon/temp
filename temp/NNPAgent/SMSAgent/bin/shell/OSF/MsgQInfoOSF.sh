#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

export LANG=C

FILE_CNT=`ls -al ../aproc/shell/MsgQInfoOSF.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    ipcs -qa > ../aproc/shell/MsgQInfoOSF.dat
fi

