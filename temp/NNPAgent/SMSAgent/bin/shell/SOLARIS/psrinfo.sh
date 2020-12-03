#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/psrinfo.dat
SH_CMD=/usr/sbin/psrinfo
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

CPU_CORE_CNT=0
if [[ -z $COMMAND ]] ; then
    COMMAND=`uname -X 2> /dev/null | grep "NumCPU =" | awk -F'=' '{print $2}'`
    if [[ -z $COMMAND ]] ; then
        CMD=`echo "not found command($SH_CMD, [uname -X])" > ../aproc/shell/psrinfo.dat_err`
        exit 255
    fi
    CPU_CORE_CNT=$COMMAND
fi

if [ $CPU_CORE_CNT = 0 ] ; then
    CPU_CORE_CNT=`/usr/sbin/psrinfo | wc -l`
fi

if [ $CPU_CORE_CNT = 0 ] ; then
    CMD=`echo "not found cpu core info" > ../aproc/shell/psrinfo.dat_err`
    exit 255
fi

EXIT_VAL=`echo $CPU_CORE_CNT > ../aproc/shell/psrinfo.dat`

exit 0
