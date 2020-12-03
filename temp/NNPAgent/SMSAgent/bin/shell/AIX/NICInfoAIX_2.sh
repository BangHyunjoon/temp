#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILEPATH=$2
NIC_INFO_TMP=$1
value=`rm -f $NIC_INFO_TMP`

SPD_CHK=0
SPD_VALUE=0
SPD_UNIT=
DEV=
    while read line
    do
        ret=`echo $line | grep -i "Virtual I/O" | wc -l`
        if [ $ret -eq 0 ]; then
            tape=`echo $line | awk '{for(a=4;a<=NF;a++)print $a}'`
        else
            tape=`echo $line | awk '{for(a=3;a<=NF;a++)print $a}'`
        fi
        DEV=`echo $tape`
        ITEM_INDEX=0
        SPD_CHK=0
        SPD_VALUE=0
        SPD_UNIT=" "
        for DEV_NAME in `echo $line | awk '{for(b=1;b<=NF;b++)print $b}'`
        do
            #echo "DEV_NAME[$ITEM_INDEX]=$DEV_NAME"

            if [ $ITEM_INDEX = 2 ] ; then
                DEV_KEY=`echo $DEV_NAME | cut -d'-' -f1`
            fi

            ITEM_INDEX=`expr $ITEM_INDEX + 1`
        done

        echo "$DEV(ADAPTER=$DEV_KEY)" >> $NIC_INFO_TMP
    done <$FILEPATH
