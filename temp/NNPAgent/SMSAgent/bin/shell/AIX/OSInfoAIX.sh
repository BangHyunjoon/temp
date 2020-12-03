#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/OSInfoAIX.dat 2> /dev/null | wc -l`
FILE_SIZE=`ls -al ../aproc/shell/OSInfoAIX.dat 2> /dev/null | awk '{print $5}'`

if [[ $FILE_SIZE -eq 0 ]] || [[ $FILE_SIZE -le 1 ]] ; then
    echo $FILE_SIZE
    oslevel > ../aproc/shell/OSInfoAIX.dat
fi
