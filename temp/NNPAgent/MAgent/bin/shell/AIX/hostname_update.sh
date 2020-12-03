#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

FILE_DAT=../aproc/shell/hostname.dat
CMD=`echo "" > $FILE_DAT`
if [ $1 ] ; then

    COMMAND=`echo "hostname setting[$1]..." > ../aproc/shell/hostname.dat` 

    COMMAND=`chdev -l inet0 -a hostname=$1 >> ../aproc/shell/hostname.dat 2>&1`
    COMMAND=`uname -S $1 >> ../aproc/shell/hostname.dat 2>&1`
else 
    COMMAND=`echo "hostname argument intput error." >> ../aproc/shell/hostname.dat 2>&1`
    exit 255
fi

exit 0
