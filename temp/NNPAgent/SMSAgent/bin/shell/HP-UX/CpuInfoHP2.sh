#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/CpuInfoHP2.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then

    MACHINFO_CHK=`ls -al ../aproc/shell/machinfo.dat 2> /dev/null | wc -l`

    if [ $MACHINFO_CHK = 0 ] ; then

        TMP_DAT=`machinfo > ../aproc/shell/machinfo.dat`

    fi

    CPUCLK=`cat ../aproc/shell/machinfo.dat | grep "Clock speed" | awk '{print $4}'`
    if [[ -z $CPUCLK ]] ; then
        #echo "0" > ../aproc/shell/CpuInfoHP2.dat
        ./shell/HP-UX/CpuInfoHP3.sh > ../aproc/shell/CpuInfoHP2.dat
    else
        echo $CPUCLK > ../aproc/shell/CpuInfoHP2.dat
    fi
fi

