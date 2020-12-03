#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

HostName=`hostname`
GMT=`./shell/AIX/GMT_GTR_BIN`
Model=`uname -M`
SystemID=`lsattr -El sys0 |grep systemid |awk '{print substr($2,7,14)}'`
#OSLevel=`oslevel`
#PatchLevel=`oslevel -r`

echo "NKIA|$HostName|$GMT|$Model|$SystemID|" > ../aproc/shell/server_info.dat
