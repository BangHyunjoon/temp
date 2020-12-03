#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/machinfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then

TMP_DAT=`machinfo > ../aproc/shell/machinfo.dat`

fi

#CTEMP1_CNT=`machinfo | grep "Hz" | cut -d',' -f1 | cut -d'(' -f2 | grep "Hz" | wc -l`
CTEMP1_CNT=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f2 | grep "Hz" | wc -l`

if [ $CTEMP1_CNT = 0 ]; then
    CTEMP2_CNT=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f3 | grep "Hz" | wc -l`
    if [ $CTEMP2_CNT = 0 ]; then
        CTEMP2_CNT=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f4 | grep "Hz" | wc -l`
        if [ $CTEMP2_CNT = 0 ]; then
            #echo "NOT FOUND CPU CLOCK !!!"
            echo "0"
        else
            #echo "CTEMP2_CNT=$CTEMP2_CNT"
            CPUCLK=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f4 | grep "Hz" | cut -d' ' -f1`
            echo "$CPUCLK"
        fi
    else
        #echo "CTEMP2_CNT=$CTEMP2_CNT"
        CPUCLK=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f3 | grep "Hz" | cut -d' ' -f1`
        echo "$CPUCLK"
    fi
else
    #echo "$CTEMP1_CNT"
    CPUCLK=`cat ../aproc/shell/machinfo.dat | grep "Hz" | cut -d',' -f1 | cut -d'(' -f2 | grep "Hz" | cut -d' ' -f1`
    echo "$CPUCLK"
fi

