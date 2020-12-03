#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

KCUSAGE_OUT=../aproc/shell/kcusage_cmd.out
kcusage | egrep -v "filecache_max|dbc_max_pct" > $KCUSAGE_OUT

l_gatherflag=0
while read line
do
     l_check=`echo $line | grep "======" | wc -l`
    if [ $l_check -eq 1 ] ; then
        l_gatherflag=1
        continue
    fi

    if [ $l_gatherflag -eq 1 ] ; then
        strName=`echo $line | awk '{print $1}'`
        l_nValue=`echo $line | awk '{print $2}'`
        l_nSetting=`echo $line | awk '{print $4}'`
        l_nUsage=$(echo "$l_nValue * 100 / $l_nSetting" | bc)
        #l_nUsage=$(echo "scale=2;$l_nValue * 100 / $l_nSetting " | bc -l)

        l_nRCheck=`echo $strName | wc -c`
        if [ $l_nRCheck -le 0 ] ; then
            strName="error"
        fi
        l_nRCheck=`echo $l_nValue| wc -c`
        if [ $l_nRCheck -le 0 ] ; then
            l_nValue="error"
        fi
        l_nRCheck=`echo $l_nSetting| wc -c`
        if [ $l_nRCheck -le 0 ] ; then
            l_nSetting="error"
        fi
        l_nRCheck=`echo $l_nUsage| wc -c`
        if [ $l_nRCheck -le 0 ] ; then
            l_nUsage="error"
        fi
        echo "NKIA|"$strName"|"$l_nValue"|"$l_nSetting"|"$l_nUsage"|"
    fi
done <$KCUSAGE_OUT
