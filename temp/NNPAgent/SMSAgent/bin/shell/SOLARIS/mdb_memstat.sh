#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

MB_SIZE=1024

FREE=`echo ::memstat | mdb -k | grep "ZFS File Data"| awk '{print $(NF-1)}'`

check1=`echo $FREE | wc -c`

if [ $check1 -le 1 ] ; then
    echo "mdb failed"
else
    check2=`echo $FREE | grep G | wc -l`
    if [ $check2 -eq 1 ] ; then
        FREE=`echo $FREE | awk -F'G' '{print $1}`
        FREE=`echo $FREE $MB_SIZE | awk  '{printf "%.0f", $1 * $2}'` 
    else
        FREE=`echo $FREE | awk -F'M' '{print $1}`
    fi
    echo "NKIA|"$FREE
fi
