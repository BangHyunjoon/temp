#!/bin/sh

UNIX95=1
export UNIX95

scriptname=$0
procname=$1
ps -e -o pid -o args | grep $procname | egrep -v "grep|$scriptname"  > ./procchk.txt

while read line
do
    name=`echo $line | awk '{print $2}'`
    if [ "$procname" = "$name" ]; then
        echo $line | awk '{print $1}'
        #echo $line
    fi
done <./procchk.txt
\rm  ./procchk.txt
