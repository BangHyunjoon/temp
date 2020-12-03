#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_CNT=`ls -al ../aproc/shell/PatchInfoHP.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    swlist -l patch | grep applied | grep -v '#' > ../aproc/shell/PatchInfoHP.dat
fi

VERSION=`uname -r`

echo "NKIA|$VERSION|" > ../aproc/shell/os_info.dat
