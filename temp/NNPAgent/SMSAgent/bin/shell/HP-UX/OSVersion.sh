#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/
export PATH

LANG=C
export LANG


PatchLevel=`swlist | egrep -i "GOLD|QPKBASE" | tail -1 | awk -F. '{print $4"."$5}' | awk -F' ' '{print $1}'`

echo "NKIA|"$PatchLevel"|" > ../aproc/shell/OSVersion_patch.out
