#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=C
export LANG

result=`showrev 2> /dev/null | grep "Kernel version:"`
value=`echo $result | grep Generic_ | wc -l`
if [ $value -eq 1 ]; then
    PatchLevel=`echo $result | awk -F_ '{print $2}'`
else
    PatchLevel=`echo $result | awk '{print $6}'`
fi

echo $PatchLevel
echo "NKIA|"$PatchLevel"|" > ../aproc/shell/OSVersion_patch.out
