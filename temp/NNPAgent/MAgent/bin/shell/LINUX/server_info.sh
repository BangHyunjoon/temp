#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

l_strHostName=`hostname`
l_strGMT=`./shell/LINUX/GMT_GTR_BIN`

echo "NKIA|$l_strHostName|$l_strGMT|" > ../aproc/shell/server_info.dat
