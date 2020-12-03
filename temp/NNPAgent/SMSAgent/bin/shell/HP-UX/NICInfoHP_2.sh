#!/bin/ksh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH
export LANG=C

RST_FILE=$1

index=1
FILEPATH=./shell/HP-UX/networkcard_v.txt
#FILEPATH=./shell/HP-UX/networkcard_v2.txt
value=`ioscan -kC lan | grep lan > $FILEPATH`

value=`rm -f ../aproc/shell/networkcard_v.dat;touch ../aproc/shell/networkcard_v.dat`
index=1
while read line
do
    path=`echo $line | awk -F/ '{print $1$2$3}'` 
    model=`echo $line | awk '{for(a=3;a<=NF;a++)print $a}'`
    echo $path":"$model >> $RST_FILE
done <$FILEPATH
