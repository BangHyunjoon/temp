#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

OSLevel=`oslevel`
PatchLevel=`oslevel -r`

echo "NKIA|$OSLevel|$PatchLevel|" > ../aproc/shell/os_info.dat
