#!/bin/sh
PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
LANG=C
export LANG=C

system_profiler SPSerialATADataType > ../aproc/shell/DiskInfoMac.dat
