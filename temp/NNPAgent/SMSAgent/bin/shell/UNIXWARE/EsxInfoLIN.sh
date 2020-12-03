#!/bin/sh

PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin
export PATH

LANG=C
export LANG

cat /proc/vmware/version | grep ESX | awk '{print $4}' > ../aproc/shell/EsxInfo.dat
