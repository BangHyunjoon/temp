#!/bin/sh

rm -f fcs.dat
rm -f disk.dat
rm -f indisk.dat

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# function : get fcs adapter name, datafile name : fcs.dat   #
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

for fcsname in `lsdev -Cc adapter -s pci -F name | grep fcs`
do
#    echo $fcsname
    echo `lscfg -vl $fcsname | grep fcs | awk '{print $2}'` >> ../aproc/shell/fcs.dat
done

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# function : get disk info, datafile name : disk.dat
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
for diskname in `lsdev -Cc disk | awk '{print $1}'`
do
#    echo $diskname
    echo $diskname" >=< "`lscfg -vl $diskname | grep "$diskname" | awk '{print $2}'` >> ../aproc/shell/disk.dat
done 

