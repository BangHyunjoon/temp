#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#FILE_CNT=`ls -al ../aproc/shell/networkcard.dat 2> /dev/null | wc -l`
#if [ $FILE_CNT = 1 ] ; then
#exit
#fi

index=1
FILEPATH=./shell/LINUX/networkcard.txt
FILEPATH2=./shell/LINUX/networkcard_lspci_v.txt
#FILEPATH2=./shell/LINUX/networkcard_lspci_v2.txt

value=`lspci | grep Ethernet > $FILEPATH`
#value=`cat ./shell/LINUX/networkcard_lspci_v2.txt | grep Ethernet > $FILEPATH`
value=`lspci -v | grep -E "Ethernet|Subsystem" | grep -iv unknown > $FILEPATH2`
value=`rm -f ../aproc/shell/networkcard.dat;touch ../aproc/shell/networkcard.dat`
value=`./shell/LINUX/NICInfoLinux_2.sh $FILEPATH2`

PORT_INFO_DAT=../aproc/shell/networkcard_lspci_v.dat

index=1
while read line
do
    path=`echo $line | awk -F. '{print $1}'`
    model=`echo $line | awk '{for(a=4;a<=NF;a++)print $a}'`
    model=`echo $model | awk -F'(' '{print $1}'`
    #echo $path"|"$model >> ../aproc/shell/networkcard.dat

    REV_SET=0
    REV=
    for REV_NAME in `echo $line | awk '{for(a=4;a<=NF;a++)print $a}'`
    do
        #echo "REV_NAME=$REV_NAME"
        if [ $REV_SET = 0 ] ; then
            REV_CNT=`echo $REV_NAME | grep "(rev" | wc -l`
            #echo "REV_CNT=$REV_CNT"
            if [ $REV_CNT = 1 ] ; then
                REV_SET=1
            fi
        else
            REV=`echo $REV_NAME | cut -d')' -f1`
            #echo "REV=$REV"
            REV_SET=0
        fi
    done

    touch ../aproc/shell/networkcard.dat
    UNIQ_CK=`grep "(REV="$REV", PORT COUNT=" ../aproc/shell/networkcard.dat | wc -l`
    if [ $UNIQ_CK = 0 ] ; then
        PORT_INFO=`grep "REV="$REV", PORT COUNT=" $PORT_INFO_DAT`
        #echo "$PORT_INFO"

        SPD_CHK=0
        SPD_VALUE=0
        SPD_UNIT=" "

        SPD_CHK=`echo $model | grep -E "bps|b/s|Base|Gigabit Ethernet" | wc -l`
        if [ $SPD_CHK != 0 ] ; then
            SPD_CHK=`echo $model | grep "10" | wc -l`

            if [ $SPD_CHK = 0 ] ; then
                SPD_VALUE=0
            else
                SPD_CHK=`echo $model | grep "1000" | wc -l`
                if [ $SPD_CHK = 0 ] ; then
                    SPD_CHK=`echo $model | grep "100" | wc -l`
                    if [ $SPD_CHK = 0 ] ; then
                        SPD_VALUE=10
                    else
                        SPD_VALUE=100
                    fi
                else
                    SPD_VALUE=1000
                fi
            fi

            SPD_CHK=`echo $model | grep "Mbps" | wc -l`
            if [ $SPD_CHK = 0 ] ; then
                SPD_CHK=`echo $model | grep "Mb/s" | wc -l`
                if [ $SPD_CHK = 0 ] ; then
                    SPD_CHK=`echo $model | grep "BaseTX" | wc -l`
                    if [ $SPD_CHK = 0 ] ; then
                        SPD_CHK=`echo $model | grep "Base-TX" | wc -l`
                        if [ $SPD_CHK = 0 ] ; then
                            SPD_CHK=`echo $model | grep "Gigabit Ethernet" | wc -l`
                            if [ $SPD_CHK = 0 ] ; then
                                SPD_CHK=`echo $model | grep "Gb/s" | wc -l`
                                if [ $SPD_CHK = 0 ] ; then
                                    SPD_CHK=`echo $model | grep "Gbps" | wc -l`
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

        echo $path"|"$model"("$PORT_INFO", SPEED="$SPD_VALUE" "$SPD_UNIT")" >> ../aproc/shell/networkcard.dat
    fi

done <$FILEPATH
