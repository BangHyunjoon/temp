#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/opt/VRTS/bin
export PATH

LANG=C
export LANG
command=`which cmviewcl 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    #echo "NKIA|NS"
    exit 0
fi

CMVIEWFILE=../aproc/shell/cmviewcl.out
cmviewcl > $CMVIEWFILE

l_nIdx=0;
while read line
do
    l_check=`echo $line | wc -c`
    if [ $l_check -le 1 ] ; then
        continue
    fi
    l_str1st=`echo $line | awk '{print $1}'`
    if [ "$l_str1st" = "CLUSTER" ] ; then
        l_nIdx=1
    fi
    if [ "$l_str1st" = "NODE" ] ; then
        l_nIdx=3
    fi
    if [ "$l_str1st" = "PACKAGE" ] ; then
        l_nIdx=5
    fi

    if [ $l_nIdx -eq 1 ] ; then
        echo "NKIA|"$line | awk '{printf " %-20s %-15s %-15s %-15s %-15s\n", $1, $2, $3, $4, $5}'
    fi
    if [ $l_nIdx -eq 3 ] ; then
        echo "NKIA|-"$line | awk '{printf " %-20s %-15s %-15s %-15s %-15s\n", $1, $2, $3, $4, $5}'
    fi
    if [ $l_nIdx -eq 5 ] ; then
        echo "NKIA|--"$line | awk '{printf " %-20s %-15s %-15s %-15s %-15s\n", $1, $2, $3, $4, $5}'
    fi
done <$CMVIEWFILE

#if [ $l_nIdx -eq 0 ] ; then
    #echo "NKIA|NS"
#fi
exit 0
