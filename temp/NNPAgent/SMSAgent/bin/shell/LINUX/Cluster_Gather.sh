#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/opt/VRTS/bin
export PATH

LANG=C
export LANG
command=`which clustat 2> /dev/null | grep -v "no " | wc -l`
if [ $command -eq 0 ]; then
    #echo "NKIA|NS"
    exit 0
fi

CLUSTATFILE=../aproc/shell/clustat.out
clustat > $CLUSTATFILE

l_strCluName=" "
l_strCluStat=" "
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

    if [ "$l_str1st" = "Cluster" ] ; then
        l_strCluName=`echo $line | awk '{print $4}'`
        l_nIdx=1
        continue
    fi
    if [ "$l_str1st" = "Service" ] ; then
        l_nIdx=4
        echo
        echo "NKIA|--"$line | awk '{printf "%s %-24s %s %s %18s\n", $1,$2,$3,$4,$5}'
        continue
    fi
    if [ $l_nIdx -eq 1 ] ; then
        l_strCluStat=`echo $line | awk '{print $3}'`
        echo "NKIA|CLUSTER STATUS" | awk '{printf "%-38s %-15s\n", $1,$2}'
        echo "NKIA|"$l_strCluName $l_strCluStat | awk '{printf "%-38s %-15s\n\n", $1,$2}'
        l_nIdx=2
        continue
    fi


    if [ "$l_str1st" = "Member" ] ; then
        l_nIdx=3
        echo "NKIA|-"$line | awk '{printf "%s %-25s %-10s %s\n", $1,$2,$3,$4}'
        continue
    fi
    if [ $l_nIdx -eq 3 ] ; then
        t_msg=`echo $line | awk '{for(a=3;a<=NF;a++)print $a}'`
        echo "NKIA|-"$line | awk '{printf "%-39s %-7s", $1,$2}'
        echo $t_msg
    fi

    if [ $l_nIdx -eq 4 ] ; then
        echo "NKIA|--"$line | awk '{printf "%-39s %-25s %s\n", $1,$2,$3}'
    fi

done <$CLUSTATFILE

#if [ $l_nIdx -eq 0 ] ; then
    #echo "NKIA|NS"
#fi
exit 0
