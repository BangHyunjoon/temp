#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/psrinfo_p.dat
SH_CMD=/usr/sbin/psrinfo
COMMAND=`which $SH_CMD 2> /dev/null | grep -v "no "`

CPU_CORE_CNT=0
if [[ -z $COMMAND ]] ; then
    CMD=`echo "not found command($SH_CMD -p)" > ../aproc/shell/psrinfo_p.dat_err`
    exit 255
fi

if [ $CPU_CORE_CNT = 0 ] ; then
    CPU_CORE_CNT=`/usr/sbin/psrinfo -p 2> /dev/null`
fi

if [ $CPU_CORE_CNT = 0 ] ; then
    CMD=`echo "not found cpu core info" > ../aproc/shell/psrinfo_p.dat_err`
    exit 255
fi

EXIT_VAL=`\\rm -f ../aproc/shell/psrinfo_p.dat`
EXIT_VAL=`echo $CPU_CORE_CNT > ../aproc/shell/psrinfo_p.dat`
#echo $EXIT_VAL

exit 0
