#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=C
export LANG


Version=`oslevel`

chk=`echo $Version | awk -F. '{print $1$2}'`
if [ $chk -gt 53 ]; then
    result=`oslevel -s`
elif [ $chk -lt 53 ]; then
    result=`oslevel -r`
elif [ $chk -eq 53 ]; then
    result=`oslevel -s | grep Usage | wc -l`
    if [ $result -eq 1 ]; then
        result=`oslevel -r`
    else
        result=`oslevel -s`
    fi
fi
PatchLevel=`echo $result | awk -F- '{if(NF>2){print $2"-"$3}else{print$2}}'`


echo "NKIA|"$Version"|"$PatchLevel
