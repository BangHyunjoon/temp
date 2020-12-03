#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# function : get disk hw path, datafile name : disk_path.dat #
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

for diskpath in `ioscan -fkCdisk | grep disk | awk '{print $3}`
do
    echo $diskpath >> ../aproc/shell/disk_path.dat
done


#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# function : get disk hw path, datafile name : disk_path.dat #
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

FIRST_FLAG=1
for fcsname in `ioscan -fkCfc | grep fc | awk '{print $3}'`
do
#    echo $fcsname
    if [ $FIRST_FLAG -eq 1 ]; then
        cat ../aproc/shell/disk_path.dat | grep -v $fcsname > ../aproc/shell/indisk_path.dat
        FIRST_FLAG=0
    else
        DISKBUF=`cat ../aproc/shell/indisk_path.dat`
        echo "$DISKBUF" | grep -v $fcsname > ../aproc/shell/indisk_path.dat
    fi
done

if [ ! -f ../aproc/shell/indisk_path.dat ]; then
    `cp -f ../aproc/shell/disk_path.dat ../aproc/shell/indisk_path.dat`
fi

