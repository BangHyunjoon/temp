#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

NTPQ_OUT=../aproc/shell/ntpq_p.out
ntpq -p > $NTPQ_OUT 2> /dev/null

l_check=`grep \^\* $NTPQ_OUT | wc -l`
if [ $l_check -ge 1 ] ; then
    l_offset=`grep \^\* $NTPQ_OUT | awk '{print $9}'`
    echo "NKIA|"$l_offset
else
    OS_TYPE=`uname`
    if [ $OS_TYPE = "Linux" ] ; then
        value=`./shell/ntpq_chronyc.sh`
        echo $value
    fi

    exit 0
fi
exit 0
