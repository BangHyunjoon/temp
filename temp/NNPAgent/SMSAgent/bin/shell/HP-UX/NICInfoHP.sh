#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
export LANG=C

#FILE_CNT=`ls -al ../aproc/shell/networkcard.dat 2> /dev/null | wc -l`
#if [ $FILE_CNT = 1 ] ; then
#exit
#fi

FILEPATH=./shell/HP-UX/networkcard.txt
#FILEPATH=./shell/HP-UX/networkcard2.txt

value=`ioscan -kC lan | grep lan > $FILEPATH`
value=`rm -f ../aproc/shell/networkcard.dat;touch ../aproc/shell/networkcard.dat`

RST_FILE=../aproc/shell/networkcard_v.dat
value=`./shell/HP-UX/NICInfoHP_2.sh $RST_FILE`

while read line
do
    path=`echo $line | awk -F/ '{print $1$2$3}'` 
    model=`echo $line | awk '{for(a=3;a<=NF;a++)print $a}'`

    UNIQ_CK=`grep "^$path" ../aproc/shell/networkcard.dat | wc -l`
    if [ $UNIQ_CK = 0 ] ; then
        PORT_INFO=`grep "^$path" $RST_FILE | wc -l`
        if [ $PORT_INFO != 0 ] ; then

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

            echo $path":"$model"(PORT COUNT="$PORT_INFO", SPEED="$SPD_VALUE" "$SPD_UNIT")" >> ../aproc/shell/networkcard.dat
        fi
    fi
done <$FILEPATH
