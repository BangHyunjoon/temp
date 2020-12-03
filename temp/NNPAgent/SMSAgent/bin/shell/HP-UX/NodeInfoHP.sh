#!/bin/ksh
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/NodeInfoHP.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    model > ../aproc/shell/NodeInfoHP.dat
fi

