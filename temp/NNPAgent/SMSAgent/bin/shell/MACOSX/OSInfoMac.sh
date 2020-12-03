#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
LANG=C
export LANG=C

system_profiler SPSoftwareDataType | grep "System Version" > ../aproc/shell/OSInfoMac.dat
