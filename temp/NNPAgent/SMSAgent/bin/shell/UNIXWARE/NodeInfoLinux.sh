#!/bin/sh
pATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
LANG=C
export LANG=C

FILE_CNT=`ls -al ../aproc/shell/NodeInfoLinux.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    uname -m > ../aproc/shell/NodeInfoLinux.dat
fi
