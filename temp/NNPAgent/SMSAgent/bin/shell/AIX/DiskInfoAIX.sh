#!/bin/ksh
#Add /usr/sbin to the PATH variable
PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

FILE_CNT=`ls -al ../aproc/shell/DISK_$1.* 2> /dev/null | wc -l`

if [ $FILE_CNT -eq 0 ]; then
    check=`lspv $1 2> /dev/null | wc -l`
    if [ $check -ne 0 ]; then
	    bootinfo -s $1 > ../aproc/shell/DISK_$1.SIZE
	    lscfg -v -l $1 > ../aproc/shell/DISK_TEMP
	    grep Manufacturer ../aproc/shell/DISK_TEMP > ../aproc/shell/DISK_$1.VENDOR
	    type=`grep $1 ../aproc/shell/DISK_TEMP | awk '{for(a=3;a<=NF;a++)print $a}'`
	    echo $type  > ../aproc/shell/DISK_$1.TYPE
	    grep Serial ../aproc/shell/DISK_TEMP > ../aproc/shell/DISK_$1.SERIAL
	    unlink ../aproc/shell/DISK_TEMP
    fi
fi

hardsize=`cat ../aproc/shell/DISK_$1.SIZE 2> /dev/null`
hardvendor=`cat ../aproc/shell/DISK_$1.VENDOR 2> /dev/null`
hardtype=`cat ../aproc/shell/DISK_$1.TYPE 2> /dev/null`
hardserial=`cat ../aproc/shell/DISK_$1.SERIAL 2> /dev/null`

if [ "$hardsize" = "" ]; then
    hardsize="UNKNOWN"
fi

if [ "$hardvendor" = "" ]; then
    hardvendor="UNKNOWN"
fi

if [ "$hardtype" = "" ]; then
    hardtype="UNKNOWN"
fi

if [ "$hardserial" = "" ]; then
    hardserial="UNKNOWN"
fi

echo "HARD($1)SIZE   : ${hardsize}"
echo "HARD($1)VENDOR : ${hardvendor}"
echo "HARD($1)TYPE   : ${hardtype}"
echo "HARD($1)SERIAL : ${hardserial}"