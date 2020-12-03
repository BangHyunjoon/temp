#!/bin/sh

#PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/platform/`arch -k`/sbin
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/platform/`uname -i`/sbin
export PATH

LANG=C
export LANG

LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

FILE_CNT=`ls -al ../aproc/shell/prtdiag.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    UNAME_I=`uname -i`
    #TMP_DAT=`/usr/platform/$UNAME_I/sbin/prtdiag > ../aproc/shell/prtdiag.dat 2>&1`
    TMP_DAT=`prtdiag > ../aproc/shell/prtdiag.dat 2>&1`
fi

TMP_CHK=`cat ../aproc/shell/prtdiag.dat 2>&1 | grep "System Configuration" | wc -l`
if [ $TMP_CHK = 0 ] ; then
    TMP_CHK=`cat ../aproc/shell/prtdiag.dat 2>&1 | grep "시스템 구성" | wc -l`
    if [ $TMP_CHK = 0 ] ; then
        echo "NOT FOUND system info" > ../aproc/shell/prtdiag.dat_err
    else
        TMP_CHK=`cat ../aproc/shell/prtdiag.dat 2>&1 | grep "시스템 구성" > ../aproc/shell/NodeInfoSOL.dat`
    fi

else
    TMP_CHK=`cat ../aproc/shell/prtdiag.dat 2>&1 | grep "System Configuration" > ../aproc/shell/NodeInfoSOL.dat`
#    showrev | grep Hardware | cut -d ' ' -f3 >> ../aproc/shell/NodeInfoSOL.dat
fi

