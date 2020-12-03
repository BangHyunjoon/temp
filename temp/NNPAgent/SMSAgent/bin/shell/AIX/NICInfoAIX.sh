#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILEPATH=./shell/AIX/nicinfo_tmp.dat
NIC_INFO_TMP=../aproc/shell/NICInfo_2.dat
NIC_INFO=../aproc/shell/NICInfo.dat

\rm $NIC_INFO $FILEPATH 2> /dev/null

lsparent -Ck ent | grep Adapter > $FILEPATH
while read line
do
    ret=`echo $line | grep -i "Virtual I/O" | wc -l`
    if [ $ret -eq 0 ]; then
        name=`echo $line | awk '{for(a=4;a<=NF;a++)print $a}'`
    else
        name=`echo $line | awk '{for(a=3;a<=NF;a++)print $a}'`
    fi
    echo $name >> $NIC_INFO
done <$FILEPATH

exit

value=`rm -f $NIC_INFO`
value=`lsparent -Ck ent | grep Adapter > $FILEPATH`
value=`./shell/AIX/NICInfoAIX_2.sh  $NIC_INFO_TMP $FILEPATH` 

SPD_CHK=0
SPD_VALUE=0
SPD_UNIT=
DEV=

    while read line
    do
        tape=`echo $line | awk '{for(a=4;a<=NF;a++)print $a}'`
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

        SPD_CHK=`echo $DEV | grep -E "bps|b/s|Base|Gigabit Ethernet" | wc -l`
        if [ $SPD_CHK != 0 ] ; then
            SPD_CHK=`echo $DEV | grep "10" | wc -l`

            if [ $SPD_CHK = 0 ] ; then
                SPD_VALUE=0
            else
                SPD_CHK=`echo $DEV | grep "1000" | wc -l`
                if [ $SPD_CHK = 0 ] ; then
                    SPD_CHK=`echo $DEV | grep "100" | wc -l`
                    if [ $SPD_CHK = 0 ] ; then
                        SPD_VALUE=10
                    else
                        SPD_VALUE=100
                    fi
                else
                    SPD_VALUE=1000
                fi
            fi

            SPD_CHK=`echo $DEV | grep "Mbps" | wc -l`
            if [ $SPD_CHK = 0 ] ; then
                SPD_CHK=`echo $DEV | grep "Mb/s" | wc -l`
                if [ $SPD_CHK = 0 ] ; then
                    SPD_CHK=`echo $DEV | grep "BaseTX" | wc -l`
                    if [ $SPD_CHK = 0 ] ; then
                        SPD_CHK=`echo $DEV | grep "Base-TX" | wc -l`
                        if [ $SPD_CHK = 0 ] ; then
                            SPD_CHK=`echo $DEV | grep "Gigabit Ethernet" | wc -l`
                            if [ $SPD_CHK = 0 ] ; then
                                SPD_CHK=`echo $DEV | grep "Gb/s" | wc -l`
                                if [ $SPD_CHK = 0 ] ; then
                                    SPD_CHK=`echo $DEV | grep "Gbps" | wc -l`
                                    if [ $SPD_CHK = 0 ] ; then
                                        SPD_UNIT=""
                                    else
                                        SPD_UNIT="Gbps"
                                    fi
                                else
                                    SPD_UNIT="Gbps"
                                fi
                            else
                                SPD_VALUE=1
                                SPD_UNIT="Gbps"
                            fi
                        else
                            SPD_UNIT="Mbps"
                        fi
                    else
                        SPD_UNIT="Mbps"
                    fi
                else
                    SPD_UNIT="Mbps"
                fi
            else
                SPD_UNIT="Mbps"
            fi
            SPD_CHK=1
        else
            if [ "$SPD_UNIT" = " " ] ; then
                SPD_VALUE=0
            fi
        fi

        value=`touch $NIC_INFO`
        ADAPTER_UNIQ=`grep "ADAPTER=$DEV_KEY" $NIC_INFO | wc -l`
        if [ $ADAPTER_UNIQ = 0 ] ; then
            PORT_CNT=`grep "ADAPTER=$DEV_KEY" $NIC_INFO_TMP | wc -l`
            echo $DEV"(ADAPTER="$DEV_KEY", PORT COUNT="$PORT_CNT", SPEED="$SPD_VALUE" "$SPD_UNIT")" >> $NIC_INFO
        fi
    done <$FILEPATH
