#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/ScsiInfo.dat 2> /dev/null | wc -l`

if [ $FILE_CNT -eq 0 ] ; then
    lsdev -C -c adapter | grep -i scsi > ../aproc/shell/scsitmp
    ret=`grep -i "Virtual SCSI" ../aproc/shell/scsitmp | wc -l`
    if [ $ret -eq 0 ]; then
        cat ../aproc/shell/scsitmp > ../aproc/shell/ScsiInfo.dat
    else
        while read line
        do
            echo "vio" $line > ../aproc/shell/ScsiInfo.dat
        done <../aproc/shell/scsitmp
    fi
fi