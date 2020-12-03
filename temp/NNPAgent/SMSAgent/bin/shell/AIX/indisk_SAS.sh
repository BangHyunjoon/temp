#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=en
export LANG

for sasname in `lsdev -C | grep hdisk | grep SAS | awk '{print $1}'`
do
    #inexdata=`lscfg -vl $sasname | grep "Hardware Location Code" | egrep "P3-D1|P3-D2|P3-D3|P3-D4|P3-D5|P3-D6"`
    #if [ ! -z $inexdata ]; then
        echo $sasname >> ../aproc/shell/indisk.dat
    #fi
done


