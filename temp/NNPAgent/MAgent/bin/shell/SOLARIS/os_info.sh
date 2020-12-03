#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

FILE_CNT=`ls -al ../aproc/shell/PatchInfoSOL.dat 2> /dev/null | wc -l`

if [ $FILE_CNT = 0 ] ; then
    showrev -p 2> /dev/null > ../aproc/shell/PatchInfoSOL.dat
fi

OSLevel=`oslevel`
PatchLevel=`oslevel -r`

echo "NKIA|$OSLevel|$PatchLevel|" > ../aproc/shell/os_info.dat
