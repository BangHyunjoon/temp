#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/contrib/bin
export PATH

LANG=C
export LANG

COMMAND=`which machinfo 2> /dev/null | grep -v "no "`
if [[ -z $COMMAND ]] ; then
    exit
fi

#machinfo | grep "logical processors" | sed -e 's/(/ /g' | awk '{print int($1/$4)}'

FILE_CNT=`ls -al ../aproc/shell/CpuCntInfoHP.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    machinfo | grep "logical processors" | sed -e 's/(/ /g' | awk '{print int($1/$4)}'
else
    size=`ls -al ../aproc/shell/CpuCntInfoHP.dat | awk '{print $5}'`
    if [ $size  = 0 ] ; then
        \rm ../aproc/shell/CpuCntInfoHP.dat
	machinfo | grep "logical processors" | sed -e 's/(/ /g' | awk '{print int($1/$4)}'
    else
        cat ../aproc/shell/CpuCntInfoHP.dat
    fi
fi
