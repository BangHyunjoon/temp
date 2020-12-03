#!/bin/sh

PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

CURRENTDATE=$1
ls -alt ../log/ | egrep -v "total|^d" | grep -v "\.gz$" | grep -v "\.Z$" 2> /dev/null | grep -i AGENT | grep $CURRENTDATE 2> /dev/null | head -1 2> /dev/null | awk '{print $NF}' 2> /dev/null > ../aproc/shell/recentlogfile.dat
