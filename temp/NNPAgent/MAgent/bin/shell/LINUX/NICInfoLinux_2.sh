#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILEPATH=$1
#value=`lspci -v | egrep 'Ethernet|Subsystem' | grep -iv unknown > $FILEPATH`

echo "" > ../aproc/shell/networkcard_lspci_v.dat

REV_CHECK=0
REV=
REV_PORT=

while read line
do
    REV_LINE=`echo $line | grep "(rev " | wc -l`
    if [ $REV_LINE = 1 ] ; then
        REV_CHECK=0
    else
        REV_CHECK=1
    fi

    if [ $REV_CHECK = 0 ] ; then
        REV_SET=0
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

        REV_CHECK=1
    else
        REV_PORT_LINE=`echo $line | grep " Multifunction " | wc -l`
        if [ $REV_PORT_LINE = 0 ] ; then
            REV_PORT_LINE=`echo $line | grep " Quad " | wc -l`
            if [ $REV_PORT_LINE = 0 ] ; then
                REV_PORT=1
            else
                REV_PORT=4
            fi
        else
            REV_PORT=2
        fi
        REV_CHECK=0

        if [ $REV_PORT_LINE != 0 ] ; then
            touch ../aproc/shell/networkcard_lspci_v.dat
            REV_UNIQ=`grep "REV="$REV ../aproc/shell/networkcard_lspci_v.dat | wc -l`
            if [ $REV_UNIQ = 0 ] ; then
                echo "REV="$REV", PORT COUNT="$REV_PORT >> ../aproc/shell/networkcard_lspci_v.dat
            fi
        else
            touch ../aproc/shell/networkcard_lspci_v.dat
            REV_UNIQ=`grep "REV="$REV ../aproc/shell/networkcard_lspci_v.dat | wc -l`
            if [ $REV_UNIQ = 0 ] ; then
                echo "REV="$REV", PORT COUNT="$REV_PORT >> ../aproc/shell/networkcard_lspci_v.dat
            fi
        fi
    fi

done <$FILEPATH
