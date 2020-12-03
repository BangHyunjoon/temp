#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/GroupName.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    awk -F: '{print $3, $1}' /etc/group > ../aproc/shell/GroupName.dat
fi

