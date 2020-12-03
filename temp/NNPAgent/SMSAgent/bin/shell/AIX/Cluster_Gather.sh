#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/opt/VRTS/bin:/usr/es/sbin/cluster/utilities
export PATH
LANG=C
export LANG

command=`which clRGinfo 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    #echo "NKIA|NS"
    exit 0
fi

CLUSTATFILE=../aproc/shell/clRGinfo.out
clRGinfo > $CLUSTATFILE

l_nIdx=0;
while read line
do
    l_check=`echo $line | wc -c`
    if [ $l_check -le 1 ] ; then
        continue
    fi
    l_check=`echo $line | grep "\--" | wc -l`
    if [ $l_check -eq 1 ] ; then
        continue
    fi

    l_str1st=`echo $line | awk '{print $1}'`

    if [ "$l_str1st" = "Group" ] ; then
        echo "NKIA|"$line | awk '{printf "%s %-15s %s %20s\n", $1,$2,$3,$4}'
        l_nIdx=1
        continue
    fi

    if [ $l_nIdx -eq 1 ] ; then
        l_NF=`echo $line | awk '{print NF}'`
        if [ $l_NF -eq 3 ] ; then
            echo "NKIA|-"$line | awk '{printf "%s %19s %22s\n", $1,$2,$3}'
        else
            echo "NKIA|- "$line | awk '{printf "%s %27s %21s\n", $1,$2,$3}'
        fi
    fi
done <$CLUSTATFILE

#if [ $l_nIdx -eq 0 ] ; then
    #echo "NKIA|NS"
#fi
exit 0
